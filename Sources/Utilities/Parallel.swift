/*
 Utilities for parallel execution.
*/

import Foundation

/// Process the items in `batch` in parallel by the function `worker`.
@available(macOS 10.15, *)
public func parallel<T: Sendable>(batch: any Sequence<T>, worker: @escaping @Sendable (T) async -> ()) {
    let semaphore = DispatchSemaphore(value: 0)

    Task {
        await withTaskGroup(of: Void.self) { taskGroup in
            for work in batch {
                taskGroup.addTask {
                    await worker(work)
                }
            }
        }
        semaphore.signal()
    }
    
    semaphore.wait()
}

/// Process the items in `batch` in parallel by the function `worker` using `threads` number of threads.
@available(macOS 10.15, *)
public func parallel<T: Sendable>(batch: Array<T>, threads: Int, worker: @escaping @Sendable (T) async -> ()) {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await withTaskGroup(of: Void.self) { taskGroup in
            let maxWorkers = min(threads, batch.count)
            for i in 0..<maxWorkers {
                taskGroup.addTask {
                    let work = batch[i]
                    await worker(work)
                }
            }
            var nextIndex = maxWorkers
            for await _ in taskGroup {
                if nextIndex < batch.count {
                    let index = nextIndex
                    taskGroup.addTask {
                        let work = batch[index]
                        await worker(work)
                    }
                }
                nextIndex += 1
                
            }
        }
        semaphore.signal()
    }
    semaphore.wait()
}

/// Process the items in `batch` in parallel by the function `worker` using `threads` number of threads.
@available(*, deprecated, message: "use function 'parallel' instead")
public func executeInParallel<Seq: Sequence>(batch: Seq, threads: Int, worker: @escaping (Seq.Element) -> ()) {
    let queue = DispatchQueue(label: "AyncLogger", attributes: .concurrent)
    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: threads)
    
    for item in batch {
        group.enter()
        semaphore.wait()
        queue.async {
            worker(item)
            semaphore.signal()
            group.leave()
        }
    }
    
    group.wait()
}
