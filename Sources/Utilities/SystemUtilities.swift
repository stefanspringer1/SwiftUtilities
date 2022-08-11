/*
 Some definitions useful e.g. to find out about the current platform.
 */

import Foundation

/// An enumeration of possible platforms.
public enum Platform {
    case macOSIntel
    case macOSARM
    case LinuxIntel
    case WindowsIntel
    case Unknown
    public var description: String? {
        switch self {
        case .macOSARM: return "macOS.ARM"
        case .macOSIntel: return "macOS.Intel"
        case .LinuxIntel: return "RedHat7.Intel" //TODO: Fix mismatch.
        case .WindowsIntel: return "Windows.Intel"
        case .Unknown: return nil
        }
    }
}

/// Get the current platform.
public func platform() -> Platform {
    #if os(macOS)
        #if arch(x86_64)
            return Platform.macOSIntel
        #else
            return Platform.macOSARM
        #endif
    #elseif os(Linux)
        #if arch(x86_64)
            return Platform.LinuxIntel
        #else
            return Platform.Unknown
        #endif
    #else
        #if arch(x86_64)
            return Platform.WindowsIntel
        #else
            return Platform.Unknown
        #endif
    #endif
}

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
public func getGeneralTemporaryFolder(applicationName: String) -> URL {
    var tempFolder: URL? = nil
    if platform() == Platform.WindowsIntel {
        if let tempEnv = ProcessInfo.processInfo.environment["TEMP"] {
            tempFolder = URL(fileURLWithPath: tempEnv)
        }
    } else if ([Platform.LinuxIntel, Platform.macOSARM, Platform.macOSIntel]).contains(platform()) {
        if #available(macOS 10.12, *) {
            tempFolder = FileManager.default.homeDirectoryForCurrentUser
        }
        tempFolder?.appendPathComponent(".\(applicationName)")
        tempFolder?.appendPathComponent("temp")
    }
    
    return tempFolder!
}

/// Generate and return a temporary folder using an application name, using as grandparent directory the according argument
/// or completely continues as in `getGeneralTemporaryFolder(applicationName:)`.
public func generateTemporaryFolderForProcess(applicationName: String, temporaryFolder: String? = nil) -> URL {
    return (makeURL(fromPath: temporaryFolder) ?? getGeneralTemporaryFolder(applicationName: applicationName)).appendingPathComponent("\(applicationName)_" + UUID().description)
}

/// Get the path separator of the current platform ("/" or "\\").
public func pathSeparator() -> String {
    return platform() == Platform.WindowsIntel ? "\\" : "/"
}
