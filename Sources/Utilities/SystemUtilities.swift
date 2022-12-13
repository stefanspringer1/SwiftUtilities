/*
 Some definitions useful e.g. to find out about the current platform.
 */

import Foundation

/// The path separator of the current platform ("/" or "\\").
#if os(Windows)
public let pathSeparator = "\\"
#else
public let pathSeparator = "/"
#endif

/// Make an optional URL from an optional path.
public func makeURL(fromPath path: String?) -> URL? {
    if let path = path {
        return URL(fileURLWithPath: path)
    }
    else {
        return nil
    }
}

/// Generate and return a temporary folder using an application name.
///
/// On Windows, use the value of the environment variable TEMP
/// as the path of the grandparent folder of the temporary folder.
///
/// Else, the home directory is used as the path of the grandparent folder of the temporary folder.
///
/// For the actual temporary directory, ".\<application name>" and then "temp" are used
/// as subdirectories (replace "<application name>" by the application name).
public func getTemporaryFolder(forApplication applicationName: String) throws -> URL {
    
    var generalTemporaryFolder: URL? = nil
    
    #if os(macOS) || os(Linux)
    generalTemporaryFolder = FileManager.default.homeDirectoryForCurrentUser
    generalTemporaryFolder?.appendPathComponent(".\(applicationName)")
    generalTemporaryFolder?.appendPathComponent("temp")
    #elseif os(Windows)
    if let tempEnv = ProcessInfo.processInfo.environment["TEMP"] {
        generalTemporaryFolder = URL(fileURLWithPath: tempEnv)
    }
    #endif
    
    guard let tempFolder = generalTemporaryFolder else {
        throw ErrorWithDescription("Could not find your temporary directory.")
    }
    
    if !tempFolder.isDirectory {
        try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
    }
    
    return tempFolder
}

/// Return a temporary folder using an application name, using as grandparent directory the according argument
/// or completely continues as in `getTemporaryFolder(forApplication:)`.
/// The folder will not (!) be created.
public func determineTemporaryFolderForProcess(
    forApplication applicationName: String,
    usingTemporaryFolderForApplication temporaryFolderForApplication: URL? = nil
) throws -> URL {
    let temporaryFolderForProcess = try (temporaryFolderForApplication ?? getTemporaryFolder(forApplication: applicationName))
        .appendingPathComponent("\(applicationName)_\(formattedTime(forFilename: true))_\(UUID())")
    if temporaryFolderForProcess.exists {
        throw ErrorWithDescription("temporary folder for process already exists: [\(temporaryFolderForProcess)]")
    }
    return temporaryFolderForProcess
}

/// Create and return a temporary folder using an application name, using as grandparent directory the according argument
/// or completely continues as in `etTemporaryFolder(forApplication:)`.
public func generateTemporaryFolderForProcess(
    forApplication applicationName: String,
    usingTemporaryFolderForApplication temporaryFolderForApplication: URL? = nil
) throws -> URL {
    let temporaryFolderForProcess = try determineTemporaryFolderForProcess(forApplication: applicationName, usingTemporaryFolderForApplication: temporaryFolderForApplication)
    try FileManager.default.createDirectory(at: temporaryFolderForProcess, withIntermediateDirectories: false)
    return temporaryFolderForProcess
}
