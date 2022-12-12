/*
 Some definitions useful e.g. to find out about the current platform.
 */

import Foundation

/// An operating system.
public enum OS {
    
    case macOS
    case iOS
    case watchOS
    case tvOS
    case Linux
    case Windows
    
    // The current operating system.
    public static var current: OS {
        #if os(macOS)
            return .macOS
        #endif
        #if os(iOS)
            return .iOS
        #endif
        #if os(watchOS)
            return .watchOS
        #endif
        #if os(tvOS)
            return .tvOS
        #endif
        #if os(Linux)
            return .Linux
        #endif
        #if os(Windows)
            return .Windows
        #endif
    }
}

/// An architecture.
public enum Architecture {
    
    case i386
    case x86_64
    case arm
    case arm64
    
    // The current architecture.
    public static var current: Architecture {
        #if arch(i386)
            return .i386
        #endif
        #if arch(x86_64)
            return .x86_64
        #endif
        #if arch(arm)
            return .arm
        #endif
        #if arch(arm64)
            return .arm64
        #endif
    }
}

/// A platform = OS + architecture.
public struct Platform {
    public let os: OS
    public let architecture: Architecture
}

/// The current platform.
public let platform = Platform(os: OS.current, architecture: Architecture.current)

/// The path separator of the current platform ("/" or "\\").
public let pathSeparator = platform.os == .Windows ? "\\" : "/"

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
    if platform.os == .macOS || platform.os == .Linux {
        generalTemporaryFolder = FileManager.default.homeDirectoryForCurrentUser
        generalTemporaryFolder?.appendPathComponent(".\(applicationName)")
        generalTemporaryFolder?.appendPathComponent("temp")
    }
    else if platform.os == .Windows {
        if let tempEnv = ProcessInfo.processInfo.environment["TEMP"] {
            generalTemporaryFolder = URL(fileURLWithPath: tempEnv)
        }
    }
    
    guard let tempFolder = generalTemporaryFolder else {
        throw ErrorWithDescription("Could not find your temporary directory.")
    }
    
    if !tempFolder.isDirectory {
        try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
    }
    
    return tempFolder
}

/// Return a temporary folder using an application name, using as grandparent directory the according argument
/// or completely continues as in `getGeneralTemporaryFolder(applicationName:)`.
/// The folder will not be created.
public func determineTemporaryFolderForProcess(
    forApplication applicationName: String,
    usingTemporaryFolderForApplication temporaryFolderForApplication: URL? = nil
) throws -> URL {
    let temporaryFolderForProcess = try (temporaryFolderForApplication ?? getTemporaryFolder(forApplication: applicationName))
        .appendingPathComponent("\(applicationName)_\(formattedTime(forFilename: true))_\(UUID())")
    if temporaryFolderForProcess.isFolder || isFile.temporaryFolderForProcess.isFolder {
        throw Exc
    }
}

public func generateTemporaryFolderForProcess(
    forApplication applicationName: String,
    usingTemporaryFolderForApplication temporaryFolderForApplication: URL? = nil
) throws -> URL {
    let temporaryFolderForProcess = try determineTemporaryFolderForProcess(forApplication: applicationName, usingTemporaryFolderForApplication: temporaryFolderForApplication)
    try FileManager.default.createDirectory(at: temporaryFolderForProcess, withIntermediateDirectories: false)
    return temporaryFolderForProcess
}
