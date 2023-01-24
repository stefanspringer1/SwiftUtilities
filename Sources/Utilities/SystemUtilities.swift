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
    } else {
        return nil
    }
}

/// Generate and return a data folder using path components as subpath.
///
/// On macOS and Linux, use the home folder of the user as
/// the starting point for appending the components, but the first
/// path part to append get a leading dot.
///
/// On Windows, use the value of the environment variable APPDATA as
/// the starting point for appending the components.
public func getDataFolder(withComponents components: [String]) throws -> URL {
    
    var generalDataFolder: URL? = nil
    
    #if os(macOS) || os(Linux)
    generalDataFolder = FileManager.default.homeDirectoryForCurrentUser
    #elseif os(Windows)
    if let appDataEnv = ProcessInfo.processInfo.environment["APPDATA"] {
        generalDataFolder = URL(fileURLWithPath: appDataEnv)
    }
    #endif
    
    guard let generalDataFolder else {
        throw ErrorWithDescription("Could not find the general data directory of your system.")
    }
    
    var dataFolder: URL? = nil
    
    #if os(macOS) || os(Linux)
    dataFolder = generalDataFolder
    if let firstPathComponent = components.first {
        dataFolder = dataFolder?.appendingPathComponent(".\(firstPathComponent)")
        dataFolder = dataFolder?.appendingPathComponents(components.dropFirst())
    }
    #elseif os(Windows)
    dataFolder = generalDataFolder.appendingPathComponents(path)
    #endif
    
    guard let dataFolder else {
        throw ErrorWithDescription("Could not find your temporary directory.")
    }
    
    if !dataFolder.isDirectory {
        try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true)
    }
    
    return dataFolder
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
    
    var temporaryFolder: URL? = nil
    
    #if os(macOS) || os(Linux)
    temporaryFolder = FileManager.default.homeDirectoryForCurrentUser
    temporaryFolder?.appendPathComponent(".\(applicationName)")
    temporaryFolder?.appendPathComponent("temp")
    #elseif os(Windows)
    if let tempEnv = ProcessInfo.processInfo.environment["TEMP"] {
        temporaryFolder = URL(fileURLWithPath: tempEnv)
    }
    #endif
    
    guard let temporaryFolder else {
        throw ErrorWithDescription("Could not find your temporary directory.")
    }
    
    if !temporaryFolder.isDirectory {
        try FileManager.default.createDirectory(at: temporaryFolder, withIntermediateDirectories: true)
    }
    
    return temporaryFolder
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
