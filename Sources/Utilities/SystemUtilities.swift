/*
 Some definitions useful e.g. to find out about the current platform.
 */

import Foundation

/// The file separator of the current platform ("/" or "\\").
#if os(Windows)
public let fileSeparator = "\\"
#else
public let fileSeparator = "/"
#endif

/// The path separator for collection of paths (":" or ";").
#if os(Windows)
public let pathSeparator = ";"
#else
public let pathSeparator = ":"
#endif

/// Make an optional URL from an optional path.
public func makeURL(fromPath path: String?) -> URL? {
    if let path = path {
        return URL(fileURLWithPath: path)
    } else {
        return nil
    }
}

/// Return a data folder URL using path components as subpath.
///
/// On macOS and Linux, use the home folder of the user as
/// the starting point for appending the components, but the first
/// path part to append get a leading dot.
///
/// On Windows, use the value of the environment variable APPDATA as
/// the starting point for appending the components.
@available(macOS 13.0, *)
public func determineDataFolder(withSubPathComponents subPathComponents: [String]) throws -> URL {
    
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
    if let firstPathComponent = subPathComponents.first {
        dataFolder = dataFolder?.appendingPathComponent(".\(firstPathComponent)")
        dataFolder = dataFolder?.appending(components: subPathComponents.dropFirst())
    }
    #elseif os(Windows)
    dataFolder = generalDataFolder.appending(components: subPathComponents)
    #endif
    
    guard let dataFolder else {
        throw ErrorWithDescription("Could not find the data directory with sub path \(subPathComponents.joined(separator: fileSeparator)).")
    }
    
    return dataFolder
}

/// Create and return a data folder using path components as subpath.
/// See the documentation for `getDataFolder(withComponents:)`.
@available(macOS 13.0, *)
public func generateDataFolder(withSubPathComponents subPathComponents: [String]) throws -> URL {
    let dataFolder = try determineDataFolder(withSubPathComponents: subPathComponents)
    try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true)
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

/// Environment with paths added to environment variable PATH.
public func environment(withPriorityPaths paths: [String]) -> [String:String] {
    var environment = ProcessInfo.processInfo.environment
    environment["PATH"] = [paths.joined(separator: pathSeparator), environment["PATH"]].joined(separator: pathSeparator)
    return environment
}
