import Foundation

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

public func makeURL(fromPath path: String?) -> URL? {
    if let path = path {
        return URL(fileURLWithPath: path)
    }
    else {
        return nil
    }
}

public func generateTemporaryFolderForProcess(applicationName: String, temporaryFolder: String? = nil) -> URL {
    return (makeURL(fromPath: temporaryFolder) ?? getGeneralTemporaryFolder(applicationName: applicationName)).appendingPathComponent("\(applicationName)_" + UUID().description)
}

public func pathSeparator() -> String {
    return platform() == Platform.WindowsIntel ? "\\" : "/"
}
