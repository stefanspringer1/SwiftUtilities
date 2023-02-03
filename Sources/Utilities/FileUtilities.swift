/*
 Some definitions to be useful when working with files.
*/

import Foundation
import ArgumentParser

/// This class can be used to print to standard error output using `print("hello", to: &StandardError.instance)`.
public class StandardError: TextOutputStream {
    
    private static let standardError = FileHandle.standardError
    public static var instance = StandardError()
    
    public func write(_ text: String) {
        StandardError.standardError.write(Data(text.utf8))
    }
}

extension FileHandle {
    
    /// Try to write text to a file handle.
    func write(_ text: String) throws {
        if #available(macOS 10.15.4, *) {
            try self.write(contentsOf: text.data(using: .utf8)!)
        } else {
            self.write(text.data(using: .utf8)!)
        }
    }
    
}

/// This is how a file size is described.
public typealias FileSize = UInt64

extension Array where Element == URL {
    
    /// Get the sizes for a list of files and put them in an according dictionary.
    public func addingSizes() throws -> [URL:FileSize] {
        var fileSizes = [URL:FileSize]()
        try self.forEach { file in
            fileSizes[file] = try file.getSize()
        }
        return fileSizes
    }
    
}

/// An error occurring with the copy operations defined in this library.
public enum CopyError: Error {
    case notAFileError(String)
    case notADirectoryError(String)
    case emptyFileError(String)
    case differentResultError(String)
    case fileExistsError(String)
    case directoryExistsError(String)
}

/// An error occurring with the copy operations defined in this library.
public enum FileUtilExceptions: Error {
    case assertionError(String)
}

/// A marker to know if we are testing and want to produce certain errors deliberately.
public enum TestMode: String, ExpressibleByArgument {
    case normalRun
    case corruptBackup // corrupt backup to test that that gets noticed
}

/// Test a string if it is an absolute path.
extension String {
        public var isAbsolutePath: Bool { contains(regex: #"(\/|[A-Za-z]:).*"#) }
}

public extension URL {
    
    /// Get files from an URL.
    ///
    /// - Parameters:
    ///     - withPattern: Regular expression matching the file name (the pattern will will enclosed by a beginning `^` and
    ///       a closing `$` before its application).
    ///     - recursively: If the search should be done recursively. Else, only direct child files are searched.
    ///
    /// - Returns: The URLs of the found files as array.
    func files(withPattern _pattern: String, findRecursively: Bool) throws -> [URL] {
        
        func toAdd(file: URL, pattern: String) throws -> Bool {
            if file.isFile {
                var match: Range<String.Index>?
                autoreleasepool {
                    match = file.lastPathComponent.range(of: pattern, options: .regularExpression)
                }
                return match != nil
                //return file.lastPathComponent.contains(regex: pattern) // if you do this instead here, memory usage will go up!
            } else {
                return false
            }
        }
        
        let pattern = "^\(_pattern)$"
        var files = [URL]()
        if self.isDirectory {
            let propertiesForKeys: [URLResourceKey] = [.isRegularFileKey, .fileSizeKey]
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
            if findRecursively {
                if let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: propertiesForKeys, options: options) {
                    for case let fileURL as URL in enumerator {
                        if try toAdd(file: fileURL, pattern: pattern) {
                            files.append(fileURL)
                        }
                    }
                }
            } else {
                try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: propertiesForKeys, options: options).forEach { fileURL in
                    if try toAdd(file: fileURL, pattern: pattern) {
                        files.append(fileURL)
                    }
                }
            }
        } else if try toAdd(file: self, pattern: pattern) {
            files.append(self)
        }
        return files
    }
    
    /// Get the path as used on the current platform (with separator either `/` or `\` between the path components).
    var osPath: String {
        get {
            self.path.replacingOccurrences(of: "/", with: pathSeparator)
        }
    }
    
    /// Check if a file or directory exists.
    var exists: Bool {
        FileManager.default.fileExists(atPath: self.osPath)
    }
    
    /// Check if it is a file.
    var isFile: Bool {
        // use a new instance so we are not using cached values:
        (try? URL(fileURLWithPath: self.path).resourceValues(forKeys:[.isRegularFileKey]))?.isRegularFile == true
    }

    /// Check if it is a directory.
    var isDirectory: Bool {
        // use a new instance so we are not using cached values:
        (try? URL(fileURLWithPath: self.path).resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    /// Check if it is an empty directory.
    var isEmpty: Bool {
        guard isDirectory else { return false }
        var enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.makeIterator()
        return enumerator?.next() == nil
    }
    
    /// Check if it its path an absolute one.
    var isAbsolute: Bool {
        path.isAbsolutePath
    }
    
    /// Get the file size. If teh fiel sdoes not exist, the return value is 0.
    var size: FileSize? {
        // use a new instance so we are not using cached values:
        (try? UInt64(URL(fileURLWithPath: self.path).resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0))
    }
    
    /// Get the file size. If teh fiel sdoes not exist, an error is thrown.
    func getSize() throws -> FileSize {
        let attr = try FileManager.default.attributesOfItem(atPath: self.path)
        return attr[FileAttributeKey.size] as! UInt64
    }
    
    /// Copy the file. Use `force` to overwrite an existing target.
    func copy(to target: URL, force: Bool = false) throws {
        let fm = FileManager.default
        if force && fm.fileExists(atPath: target.osPath) {
            try fm.removeItem(at: target)
        }
        try fm.copyItem(at: self, to: target)
    }
    
    /// Initialize with path components.
    init(pathComponents: [String]) {
        self.init(fileURLWithPath: pathComponents.joined(separator: "/"))
    }
    
    /// Append path components.
    func appending(components newComponents: String...) -> URL {
        return self.appending(components: newComponents)
    }
    
    /// Append path components.
    func appending(components newComponents: [String]) -> URL {
        var newURL = self
        newComponents.forEach { newURL.appendPathComponent($0) }
        return newURL
    }
    
    /// Append path components.
    func appending(components newComponents: ArraySlice<String>) -> URL {
        var newURL = self
        newComponents.forEach { newURL.appendPathComponent($0) }
        return newURL
    }
    
    /// Add a postifx between the basename and the extension, separated by `.`, and
    /// maybe another additional extension.
    func adding(postfix: String?, withAdditionalExtension additionalExtension: String? = nil) -> URL {
        return URL(fileURLWithPath: [
            self.deletingPathExtension().path,
            postfix,
            self.pathExtension,
            additionalExtension
        ].compactMap { $0 }.filter{ !$0.isEmpty }.joined(separator: "."))
    }
    
    /// Test if the files has teh same content as another file.
    func fileEqual(to file: URL) throws -> Bool {
        let fileA = try Data(contentsOf: self).lazy
        let fileB = try Data(contentsOf: file).lazy
        return zip(fileA, fileB).allSatisfy{$0==$1}
    }
    
    /// Create a directory, optionally with certain file attributes.
    ///
    /// If `withIntermediateDirectories` is true, the intermediate directories are also created.
    func createDirectory(withIntermediateDirectories: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        try FileManager.default.createDirectory(at: self, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }

    /// Removing a file "safely", i.e. try to remove it sevaral times if necessary and throw an error if not finally removed.
    func removeSafely(maxTries: Int = 5, secBeforeRetry: TimeInterval = 1) throws {
        var isFile = self.isFile
        guard isFile else {
            throw CopyError.notAFileError(self.description + " is not a file")
        }
        var tries = 0
        while isFile {
            tries += 1
            do {
                try FileManager.default.removeItem(at: self)
            } catch {
                // -
            }
            isFile = self.isFile
            if isFile {
                if tries < maxTries {
                    Thread.sleep(forTimeInterval: secBeforeRetry)
                } else {
                    throw CopyError.fileExistsError("There already exists a file at \(self.description).")
                }
            }
        }
    }

    /// Removing a directory "safely", i.e. try to remove it sevaral times if necessary and throw an error if not finally removed.
    func removeDirectorySafely(maxTries: Int = 5, secBeforeRetry: TimeInterval = 1) throws {
        var isDirectory = self.isDirectory
        guard isDirectory else {
            throw CopyError.notADirectoryError(self.description + " is not a directory")
        }
        var tries = 0
        while isDirectory {
            tries += 1
            do {
                try FileManager.default.removeItem(at: self)
            } catch {
                // -
            }
            isDirectory = self.isDirectory
            if isDirectory {
                if tries < maxTries {
                    Thread.sleep(forTimeInterval: secBeforeRetry)
                } else {
                    throw CopyError.directoryExistsError(self.description + " still exists after " + tries.description + " to remove it")
                }
            }
        }
    }
    
    /// Forcing the recursive removal of files with names according to a pattern.
    ///
    /// The pattern will will enclosed by a beginning `^` and a closing `$` before its application.
    func removeRecursivelyForce(pattern: String, tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1) throws -> [URL] {
        let files = try self.files(withPattern: pattern, findRecursively: true)
        let notRemovableFiles = files.filter { $0.isFile }.compactMap{ file -> URL? in
            do {
                try file.removeSafely()
                return nil
            } catch {
                return file
            }
        }
        
        if notRemovableFiles.isEmpty {
            try FileManager.default.removeItem(at: self)
        }
        return notRemovableFiles as [URL]
    }
    
    /// Find the components of the relative path relative to the argument as base, assuming `self` starts with the path to base.
    func relativePathComponents(to base: URL) throws -> [String] {
        let basePath = base.pathComponents
        let selfPath = self.pathComponents
        guard basePath == Array(selfPath[..<basePath.count]) else {
            throw FileUtilExceptions.assertionError("self does not start with base")
        }
        return Array(selfPath[basePath.count...])
    }
    
    /// Copying a file or a directory "safely", i.e. try to copy it sevaral times if necessary and throw an error if not finally copied.
    ///
    /// Files with name in `ignore` are ignored. The default for `ignore` is `[".DS_store", "Thumbs.db"]`.
    func copySafely(destination: URL, ignore: [String] = [".DS_store", "Thumbs.db"], overwrite: Bool = false, tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1, testMode : TestMode = TestMode.normalRun) throws {
        let source = self
        
        if overwrite && (destination.isDirectory || destination.isFile) {
            try destination.removeSafely()
        }
        
        guard !destination.isDirectory && !destination.isFile else {
            throw CopyError.fileExistsError("There already is a file or directory at \(destination.description).")
        }
        
        if self.isFile {
            return try fileCopySafely(destination: destination, overwrite: overwrite, testMode: testMode)
        } else if source.isDirectory {
            if let enumerator = FileManager.default.enumerator(at: source, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    if fileURL.isFile {
                        let fileName = fileURL.lastPathComponent
                        if !ignore.contains(fileName) {
                            let relativePath = try fileURL.relativePathComponents(to: self)
                            let dest = URL(pathComponents: destination.pathComponents + relativePath)
                            var dir = dest
                            dir.deleteLastPathComponent()
                            try dir.createDirectory()
                            try fileURL.fileCopySafely(destination: dest, testMode: testMode)
                        }
                    }
                }
            }
        } else {
            throw CopyError.fileExistsError(self.description)
        }
    }
    
    /// Copying a file "safely", i.e. try to copy it sevaral times if necessary and throw an error if not finally copied.
    private func fileCopySafely(destination: URL, overwrite: Bool = false, tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1, testMode: TestMode = TestMode.normalRun) throws {
        if overwrite && destination.isFile {
            try destination.removeSafely(maxTries: maxTries, secBeforeRetry: secBeforeRetry)
        }
        
        guard !destination.isFile else {
            throw CopyError.fileExistsError(destination.description)
        }
                
        var tries = 0
        while !destination.isFile {
            do {
                try FileManager.default.copyItem(at: self, to: destination)
            } catch {
                if tries < maxTries {
                    Thread.sleep(forTimeInterval: secBeforeRetry)
                    tries += 1
                } else {
                    throw error
                }
            }
        }
        
        if testMode == TestMode.corruptBackup {
            try destination.corrupt()
        }
        
        guard try self.fileEqual(to: destination) else {
            try destination.removeSafely()
            throw CopyError.differentResultError("\(self.description) and \(destination) are different after copying. removing \(destination).")
        }
        
    }
    
    /// For debugging purposes: "corrupting" a file content by changing it.
    private func corrupt() throws {
        var data = try Data(contentsOf: self)
        data = data.dropFirst(1)
        try data.write(to: self)
    }
    
    /// Ensures that a file is non-empty. Ff it is not a file or is empty, an error is thrown.
    func checkNonEmpty(tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1) throws {
        guard try self.isFile && self.getSize() != 0 else {
            for _ in 0...tries {
                if try !self.isFile || self.getSize() == 0 {
                    Thread.sleep(forTimeInterval: secBeforeRetry)
                } else {
                    return
                }
            }
            if !self.isFile {
                throw CopyError.notAFileError("\(self) is not a file")
            } else {
                throw CopyError.emptyFileError("\(self) has size zero")
            }
        }
    }

    /// Moves a file.
    func move(destination: URL, overwrite: Bool = false, tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1) throws {
        try self.copySafely(destination: destination, overwrite: overwrite, tries: 0, maxTries: maxTries, secBeforeRetry: secBeforeRetry)
        try self.removeSafely()
    }
    
    /// Append a text line to a file:
    func append(text: String) throws {
        let fileHandle = try FileHandle(forWritingTo: self)
        defer {
            fileHandle.closeFile()
        }
        fileHandle.seekToEndOfFile()
        if let data = text.data(using: String.Encoding.utf8) {
            fileHandle.write(data)
        }
        else {
            throw ErrorWithDescription("could not get data to write to \(self.osPath)")
        }
    }
    
    /// Append a line of text to a file:
    func append(line: String, lineBreak: String = "\n") throws {
        try self.append(text: line + lineBreak)
    }

}

/// A file that can be opened, closed, and reopened, and text can be written to it.
public class WritableFile {
    
    public let path: String
    public let blocking: Bool
    var fileHandle: FileHandle?
    
    public func open(append: Bool = false) throws {
        let fileManager = FileManager.default
        if !append && fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path, contents: nil)
        }
        let maybeFileHandle = FileHandle(forWritingAtPath: path)
        if let theFileHandle = maybeFileHandle {
            fileHandle = theFileHandle
            if append {
                if #available(macOS 10.15.4, *) {
                    try fileHandle?.seekToEnd()
                } else {
                    throw ErrorWithDescription("wrong macOS version for \(#function)")
                }
            }
        } else {
            throw ErrorWithDescription("could not open \(path) \(append ? "to append" : "to write")")
        }
    }
    
    public func close() throws {
        if #available(macOS 10.15, *) {
            try fileHandle?.close()
        }
        fileHandle = nil
    }
    
    public func reopen() throws {
        if fileHandle == nil {
            try open(append: true)
        }
    }
    
    public init(path: String, append: Bool = false, blocking: Bool = true) throws {
        //blocking==true: keeps the log file open for performance reasons.
        //blocking==false: reopens and closes file every time it writes to it.
        self.path = path
        self.blocking = blocking
        if blocking {
            try self.open(append: append)
        }
    }
    
    private let NEWLINE = "\n".data(using: .utf8)!
    
    public func write(_ message: String, newline: Bool = true) throws {
        try self.reopen()
        fileHandle?.write(message.data(using: .utf8)!)
        if newline {
            fileHandle?.write(NEWLINE)
        }
        if !self.blocking {
            try self.close()
        }
    }
    
    public func flush() throws {
        if #available(macOS 10.15, *) {
            try fileHandle?.synchronize()
        } else {
            fileHandle?.synchronizeFile()
        }
    }

}
