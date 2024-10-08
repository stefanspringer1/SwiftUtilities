/*
 Definitions useful for running external programs.
 */

import Foundation

public func runProgram(
    executableURL: URL,
    environment: [String:String]? = nil,
    arguments: [String],
    currentDirectoryURL: URL,
    qualityOfService: QualityOfService? = nil,
    standardOutHandler: @escaping (String) -> (),
    errorOutHandler: @escaping (String) -> (),
    commandLineDebugHandler: ((String) -> ())? = nil
) {
    commandLineDebugHandler?("in [\(currentDirectoryURL)]: \"\(executableURL.osPath)\" \(arguments.map{"\"\($0)\""}.joined(separator: " ")) (environment: \(environment?.description ?? "not set"))")
    
    let process = Process()
    
    process.executableURL = executableURL
    
    if let environment = environment {
        process.environment = environment
    }
    
    process.arguments = arguments
    
    process.currentDirectoryURL = currentDirectoryURL
    
    if let qualityOfService = qualityOfService {
        process.qualityOfService = qualityOfService
    }
    
    let group = DispatchGroup()
    
    var tempStdOutStorage = Data()
    let stdOutPipe = Pipe()
    process.standardOutput = stdOutPipe
    group.enter()
    stdOutPipe.fileHandleForReading.readabilityHandler = { stdOutFileHandle in
        let stdOutPartialData = stdOutFileHandle.availableData
        if stdOutPartialData.isEmpty { // EOF on stdin
            stdOutPipe.fileHandleForReading.readabilityHandler = nil
            group.leave()
        } else {
            tempStdOutStorage.append(stdOutPartialData)
        }
    }
    
    var tempStdErrStorage = Data()
    let stdErrPipe = Pipe()
    process.standardError = stdErrPipe
    group.enter()
    stdErrPipe.fileHandleForReading.readabilityHandler = { stdErrFileHandle in
        let stdErrPartialData = stdErrFileHandle.availableData
        if stdErrPartialData.isEmpty { // EOF on stderr
            stdErrPipe.fileHandleForReading.readabilityHandler = nil
            group.leave()
        } else {
            tempStdErrStorage.append(stdErrPartialData)
        }
    }
    
    process.standardOutput = stdOutPipe
    process.standardError = stdErrPipe
    
    process.launch()
    
    #if os(Windows)
    let outputEncoding: String.Encoding = .windowsCP1252
    #else
    let outputEncoding: String.Encoding = .utf8
    #endif
    
    process.terminationHandler = { process in
        group.wait()
        if let stdOutText = String(data: tempStdOutStorage, encoding: outputEncoding) {
            stdOutText.split(separator: "\n").forEach { line in standardOutHandler(String(line)) }
        }
        if let stdErrText = String(data: tempStdErrStorage, encoding: outputEncoding) {
            stdErrText.split(separator: "\n").forEach { line in errorOutHandler(String(line)) }
        }
    }
    process.waitUntilExit()
}
