/*
 Some definitions to be useful when working with files.
*/

import Foundation
import ArgumentParser
import AutoreleasepoolShim

/// This class can be used to print to standard error output using `print("hello", to: &StandardError.instance)`.
public final class StandardError: TextOutputStream, Sendable {
    
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

public struct FileCheckFailure: LocalizedError, CustomStringConvertible {

    public let url: URL

    public init(_ url: URL) {
        self.url = url
    }
    
    public var description: String { "check of file failed: \(url.osPath)" }
    
    public var errorDescription: String? { description }
}

public extension URL {
    
    /// Get files from an URL.
    ///
    /// - Parameters:
    ///     - withPattern: Regular expression matching the file name (be sure to use a beginning `^` and
    ///       a closing `$` when the whole match is desired).
    ///     - excluding: If not `nil`: Regular expression that must not match the file name (be sure to use a beginning `^` and
    ///       a closing `$` when the whole match is desired).
    ///     - recursively: If the search should be done recursively. Else, only direct child files are searched.
    ///
    /// - Returns: The URLs of the found files as array.
    func files(withPattern pattern: Regex<AnyRegexOutput>, excluding excludePattern: Regex<AnyRegexOutput>? = nil, findRecursively: Bool) throws -> [URL] {
        
        func toAdd(file: URL) throws -> Bool {
            if file.isFile {
                if let excludePattern {
                    file.lastPathComponent.contains(pattern) && !file.lastPathComponent.contains(excludePattern)
                } else {
                    file.lastPathComponent.contains(pattern)
                }
            } else {
                false
            }
        }
        
        var files = [URL]()
        if self.isDirectory {
            let propertiesForKeys: [URLResourceKey] = [.isRegularFileKey, .fileSizeKey]
            let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]
            if findRecursively {
                if let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: propertiesForKeys, options: options) {
                    for case let fileURL as URL in enumerator {
                        if try toAdd(file: fileURL) {
                            files.append(fileURL)
                        }
                    }
                }
            } else {
                try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: propertiesForKeys, options: options).forEach { fileURL in
                    if try toAdd(file: fileURL) {
                        files.append(fileURL)
                    }
                }
            }
        } else if try toAdd(file: self) {
            files.append(self)
        }
        return files
    }
    
    /// Get files from an URL.
    ///
    /// - Parameters:
    ///     - withPattern: Regular expression matching the file name (the pattern will will enclosed by a beginning `^` and
    ///       a closing `$` before its application).
    ///     - excluding: If not `nil`: Regular expression that must not match the file name (the pattern will will enclosed by a beginning `^` and
    ///       a closing `$` before its application).
    ///     - recursively: If the search should be done recursively. Else, only direct child files are searched.
    ///
    /// - Returns: The URLs of the found files as array.
    func files(withPattern _pattern: String, excluding _excludePattern: String? = nil, findRecursively: Bool) throws -> [URL] {
        let pattern = "^\(_pattern)$"
        let excludePattern: String?
        if let _excludePattern {
            excludePattern = "^\(_excludePattern)$"
        } else {
            excludePattern = nil
        }
        let excludePatternRegex: Regex<AnyRegexOutput>? = if let excludePattern { try Regex(excludePattern) } else { nil }
        return try files(withPattern: try Regex(pattern), excluding: excludePatternRegex, findRecursively: findRecursively)
    }
    
    /// Get the path as used on the current platform (with separator either `/` or `\` between the path components).
    var osPath: String {
        get {
            var newPathComponents = [String]()
            for pathComponent in self.pathComponents {
                if pathComponent == "/" {
                    if pathComponent == fileSeparator {
                        newPathComponents.append("")
                    }
                } else {
                    newPathComponents.append(pathComponent)
                }
//                if (pathComponent == "/" || pathComponent.hasSuffix(":")), newPathComponents.count == 1, let last = newPathComponents.last, last == "/" {
//                    newPathComponents.removeLast()
//                }
//                newPathComponents.append(pathComponent)
            }
            return newPathComponents.joined(separator: fileSeparator)
        }
    }
    
    /// Check if a file or directory exists.
    var exists: Bool {
        FileManager.default.fileExists(atPath: self.osPath)
    }
    
    /// Check if it is a regular file, i.e. a file but not a symbolic link.
    var isRegularFile: Bool {
        // use a new instance so we are not using cached values:
        (try? URL(fileURLWithPath: self.path).resourceValues(forKeys:[.isRegularFileKey]))?.isRegularFile == true
    }
    
    /// Check if it is a symbolic link.
    var isSymbolicLink: Bool {
        // use a new instance so we are not using cached values:
        (try? URL(fileURLWithPath: self.path).resourceValues(forKeys:[.isSymbolicLinkKey]))?.isSymbolicLink == true
    }
    
    /// Check if it is a regular file or a link.
    var isFile: Bool {
        // use a new instance so we are not using cached values:
        guard let resourceValues = (try? URL(fileURLWithPath: self.path).resourceValues(forKeys:[.isRegularFileKey, .isSymbolicLinkKey])) else { return false }
        return resourceValues.isRegularFile == true || resourceValues.isSymbolicLink == true
    }
    
    /// Check if it is an executable.
    var isExecutable: Bool {
        // use a new instance so we are not using cached values:
        (try? URL(fileURLWithPath: self.path).resourceValues(forKeys:[.isExecutableKey]))?.isExecutable == true
    }

    /// Check if it is a directory.
    var isDirectory: Bool {
        // use a new instance so we are not using cached values:
        (try? URL(fileURLWithPath: self.path).resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    /// Check if the file's device is connected to an internal bus.
    var isInternal: Bool {
        // use a new instance so we are not using cached values:
        (try? self.resourceValues(forKeys: [.volumeIsInternalKey]))?.volumeIsInternal == true
    }
    
    /// The name of the file's volume.
    var volumeName: String? {
        (try? self.resourceValues(forKeys: [.volumeNameKey]))?.volumeName
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
    
    #if os(Linux) || os(Android) || os(Windows)
    /// Append one path component.
    func appending(component newComponent: String) -> URL {
        return self.appending(components: newComponent)
    }
    #endif
    
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
    
    /// Test if the file has the same content as another file.
    func hasSameContent(as other: URL) throws -> Bool {
        try autoreleasepool {
            let content1 = try Data(contentsOf: self)
            let content2 = try Data(contentsOf: other)
            return content1 == content2
        }
    }
    
    /// Test if the file or directory is contained at another place.
    /// The success case contains the URL of the other place.
    /// The failure case contains the URL that is missing or different.
    /// The names ".DS\_Store" and "Thumbs.db" are ignored by default, else specify ignored names via `ignoringNames:`.
    func isContained(inFileTree other: URL, ignoringNames ignore: [String] = [".DS_Store", "Thumbs.db"]) throws -> Result<URL,FileCheckFailure> {
        if self.isFile {
            if try self.hasSameContent(as: other) {
                return .success(self)
            } else {
                return .failure(FileCheckFailure(self))
            }
        } else if self.isDirectory {
            
            func otherURL(for url: URL) throws -> URL {
                other.appending(components: try url.relativePathComponents(to: self))
            }
            
            if let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil) {
                for case let file as URL in enumerator {
                    if ignore.contains(file.lastPathComponent) {
                        continue
                    }
                    let otherFile = try otherURL(for: file)
                    if file.isDirectory {
                        guard otherFile.isDirectory else { return .failure(FileCheckFailure(otherFile)) }
                    } else if file.isRegularFile {
                        guard otherFile.isRegularFile else { return .failure(FileCheckFailure(otherFile)) }
                        if try !file.hasSameContent(as: otherFile) {
                            return .failure(FileCheckFailure(file))
                        }
                    } else if file.isSymbolicLink {
                        guard otherFile.isSymbolicLink else { return .failure(FileCheckFailure(otherFile)) }
                        let fileTarget = file.resolvingSymlinksInPath()
                        let otherFileTarget = otherFile.resolvingSymlinksInPath()
                        do {
                            // assuming link points to inside of directory:
                            let otherFileTargetShould = try otherURL(for: fileTarget)
                            if otherFileTargetShould != otherFileTarget {
                                return .failure(FileCheckFailure(otherFile))
                            }
                        } catch {
                            // link points to outside of directory:
                            if fileTarget == otherFileTarget {
                                return .failure(FileCheckFailure(otherFile))
                            }
                        }
                    } else {
                        return .failure(FileCheckFailure(otherFile)) // "strange" file
                    }
                }
            }
        }
        return .success(other)
    }
    
    /// Create a directory, optionally with certain file attributes.
    ///
    /// If `withIntermediateDirectories` is true, the intermediate directories are also created.
    func createDirectory(withIntermediateDirectories: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        try FileManager.default.createDirectory(at: self, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }

    /// Removing a file "safely", i.e. try to remove it sevaral times if necessary and throw an error if not finally removed.
    func removeSafely(maxTries: Int = 5, secBeforeRetry: TimeInterval = 1, errorIfNotExists: Bool = true) throws {
        var exists = self.exists
        guard exists else {
            if errorIfNotExists {
                throw CopyError.notAFileError(self.description + " does not exist")
            } else {
                return
            }
        }
        var tries = 0
        while exists {
            tries += 1
            do {
                try FileManager.default.removeItem(at: self)
            } catch {
                // -
            }
            exists = self.exists
            if isFile {
                if tries < maxTries {
                    Thread.sleep(forTimeInterval: secBeforeRetry)
                } else {
                    throw CopyError.fileExistsError("Removing failed at \(self.description).")
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
    func copySafely(to destination: URL, ignore: [String] = [".DS_store", "Thumbs.db"], overwrite: Bool = false, tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1, testMode : TestMode = TestMode.normalRun) throws {

        if overwrite && (destination.isDirectory || destination.isFile) {
            try destination.removeSafely()
        }
        
        guard !destination.exists else {
            throw CopyError.fileExistsError("The target already exists at \(destination.description).")
        }
        
        var tries = 0
        while !destination.exists {
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
        
        var checkContent: Bool
#if os(Windows) || os(Linux)
        checkContent = true
#else
        checkContent = !(self.isInternal && destination.isInternal) || (self.volumeName != destination.volumeName)
#endif
        
        if checkContent {
            if case .failure(let failedFile) = try self.isContained(inFileTree: destination) {
                throw CopyError.differentResultError("the contents of \(self.osPath) and \(destination.osPath) are not equal (check failed on \(failedFile)")
            }
        }
        
    }
    
    /// For debugging purposes: "corrupting" a file content by changing it.
    private func corrupt() throws {
        try autoreleasepool {
            var data = try Data(contentsOf: self)
            data = data.dropFirst(1)
            try data.write(to: self)
        }
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
    func moveSafely(to destination: URL, overwrite: Bool = false, tries: Int = 0, maxTries: Int = 5, secBeforeRetry: TimeInterval = 1) throws {
        if !self.isInternal || (self.volumeName != destination.deletingLastPathComponent().volumeName) {
            try self.copySafely(to: destination, overwrite: overwrite, tries: 0, maxTries: maxTries, secBeforeRetry: secBeforeRetry)
            try self.removeSafely()
        } else {
            try FileManager.default.moveItem(at: self, to: destination)
        }
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

public extension URL {
    
    /// Removing "." and ".." from the path.
    var cleaningUpPath: URL {
        var newPathComponents = [String]()
        for pathComponent in self.pathComponents {
            switch pathComponent {
            case ".": continue
            case "..":
                if newPathComponents.isEmpty {
                    newPathComponents = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).deletingLastPathComponent().pathComponents
                } else {
                    newPathComponents.removeLast()
                }
            default: 
                if pathComponent.hasSuffix(":"), newPathComponents.count == 1, let last = newPathComponents.last, last == "/" {
                    newPathComponents.removeLast()
                }
                newPathComponents.append(pathComponent)
            }
        }
        return URL(pathComponents: newPathComponents)
    }
}
