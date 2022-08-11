/*
 Some definitions for working with key-value properties lists in files.
*/

import Foundation

/// Escpape characters in a text that is to be saved as a value in a property file.
fileprivate func escapeInSimplePropertiesList(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "=", with: "\\=")
        .replacingOccurrences(of: ":", with: "\\:")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "#", with: "\\#")
}

/// Unescpape characters in a text that is being read from a property file.
fileprivate func unescapeInSimplePropertiesList(_ text: String) -> String {
    return text.components(separatedBy: "\\\\").map { $0
        .replacingOccurrences(of: "\\#", with: "#")
        .replacingOccurrences(of: "\\n", with: "\n")
        .replacingOccurrences(of: "\\:", with: ":")
        .replacingOccurrences(of: "\\=", with: "=")
        .replacingOccurrences(of: "\\\\", with: "\\")
    }.joined(separator: "\\")
}

/// Read a properties file (with "...=..." lines).
///
/// Comments ("# ...") are only considered when the (whitespace trimmed) line is started by "#" or there is a whitespace before it!
public func readSimplePropertiesList(path: String, errorHandler: ((String) -> ())? = nil) -> [String:String] {
    var result = [String:String]()
    var lineNumber = 0
    do {
        try String(contentsOfFile: path, encoding: .utf8).enumerateLines { (_line, _) in
            lineNumber += 1
            if !_line.starts(with: "#"), let line = _line.components(separatedBy: " #").first?.trimmingCharacters(in: .whitespaces),
               !line.isEmpty,
               !line.hasPrefix("#")
            {
                if let firstEqual = line.firstIndex(of: "=") {
                    let key = String(line[..<firstEqual]).trimmingCharacters(in: .whitespaces)
                    if !key.isEmpty {
                        result[unescapeInSimplePropertiesList(key)] =
                            unescapeInSimplePropertiesList(
                                String(line[line.index(firstEqual, offsetBy: 1)...])
                                    .trimmingCharacters(in: .whitespaces)
                            )
                    }
                }
                else {
                    let errorMessage = "\(path):\(lineNumber):E: missing equal sign"
                    if let theErrorHandler = errorHandler {
                        theErrorHandler(errorMessage)
                    }
                    else {
                        print(errorMessage)
                    }
                }
            }
        }
    }
    catch {
        let errorMessage = "\(path):E: \(error.localizedDescription)"
        if let theErrorHandler = errorHandler {
            theErrorHandler(errorMessage)
        }
        else {
            print(errorMessage)
        }
    }
    return result
}

/// Write a properties file (with "...=..." lines).
public func writeSimplePropertiesList(properties: [String:String], path: String, title: String? = nil, lineEnding: String = "\n", errorHandler: ((String) -> ())? = nil) {
    do {
        let fileManager = FileManager.default
        
        // If file exists, remove it
        if fileManager.fileExists(atPath: path)
        {
            try fileManager.removeItem(atPath: path)
        }
        
        // Create file and open it for writing
        fileManager.createFile(atPath: path,  contents:Data(" ".utf8), attributes: nil)
        let fileHandle = FileHandle(forWritingAtPath: path)
        if fileHandle == nil
        {
            throw ErrorWithDescription("\(path):E: could not open file for writing")
        }
        else
        {
            if let theTitle = title {
                try fileHandle!.write("# \(theTitle)\(lineEnding)")
            }
            try properties.keys.sorted{
                let caseInsensitive = $0.compare($1, options: .caseInsensitive)
                if caseInsensitive == ComparisonResult.orderedSame {
                    return $0.compare($1) == .orderedAscending
                }
                else {
                 return caseInsensitive == .orderedAscending
                }
            }.forEach { key in
                try fileHandle!.write("\(escapeInSimplePropertiesList(key))=\(escapeInSimplePropertiesList(properties[key]!))\(lineEnding)")
            }
            
            fileHandle!.closeFile()
        }
    }
    catch {
        let errorMessage = "\(path):E: \(error.localizedDescription)"
        if let theErrorHandler = errorHandler {
            theErrorHandler(errorMessage)
        }
        else {
            print(errorMessage)
        }
    }
}
