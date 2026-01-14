/*
 Definitions useful for running external programs.
 */

import Foundation
import Subprocess

#if canImport(System)
import System
#else
import SystemPackage
#endif

/// Run an external program by using an asynchronous call.
/// Environment might be .inherit.updating(["NewKey": "NewValue"]).
/// Returns the return code of the program or (if the program could not be started or could not be ended in a regular fashion) `nil`.
@Sendable public func runProgram(
    executableURL: URL,
    environment: Environment = .inherit,
    arguments: [String],
    currentDirectoryURL: URL,
    outputHandler: @Sendable (String) -> ()
) async -> Int? {
    do {
        let platformOptions = {
            var _platformOptions = PlatformOptions()
            #if os(Windows)
            _platformOptions.windowStyle = .hidden
            #endif
            return _platformOptions
        }()
        async let monitorResult = run(
            .path(FilePath(stringLiteral: executableURL.path)),
            arguments: Arguments(arguments),
            environment: environment,
            workingDirectory: FilePath(stringLiteral: currentDirectoryURL.path),
            platformOptions: platformOptions,
            error: .combineWithOutput
        ) { execution, standardOutput in
            for try await line in standardOutput.lines() {
                outputHandler(line.trimmingCharacters(in: .newlines))
            }
        }
        
        let terminationStatus = try await monitorResult.terminationStatus
        switch terminationStatus {
        case .exited(let code):
            return Int(code)
        case .unhandledException(let code):
            outputHandler("fatal error calling \(executableURL.path): unhandled exception \(code))")
            return nil
        }
    } catch {
        outputHandler("fatal error calling \(executableURL.path): \(String(describing: error))")
        return nil
    }
}

// Run an external program.
@available(*, deprecated, message: "use function 'runProgramAsync' or 'runProgramSync' instead (and only in async contexts)")
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
