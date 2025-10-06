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

/// Run an external program by using an asynchonous call.
/// Environment might be .inherit.updating(["NewKey": "NewValue"]).
@Sendable public func runProgramAsync(
    executableURL: URL,
    environment: Environment = .inherit,
    arguments: [String],
    currentDirectoryURL: URL,
    outputHandler: @Sendable (String) -> ()
) async -> Bool {
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
        return terminationStatus == .exited(0)
    } catch {
        outputHandler("error calling \(executableURL.path): \(String(describing: error))")
        return false
    }
}

/// Run an external program by using a synchonous call.
/// Environment might be .inherit.updating(["NewKey": "NewValue"]).
@Sendable public func runProgramSync(
    executableURL: URL,
    environment: Environment = .inherit,
    arguments: [String],
    currentDirectoryURL: URL,
    outputHandler: @Sendable @escaping (String) -> ()
) -> Bool {
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let asyncResult = AsyncValue<Bool>(initialValue: false)
    Task {
        let result = await runProgramAsync(
            executableURL: executableURL,
            environment: environment,
            arguments: arguments,
            currentDirectoryURL: currentDirectoryURL,
            outputHandler: outputHandler
        )
        asyncResult.set(result)
        semaphore.signal()
    }
    
    semaphore.wait()
    return asyncResult.value
}

// Run an external program.
@available(*, deprecated, message: "use function 'runProgramAsync' or 'runProgramSync' instead")
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
