/*
 Utilities for parallel execution.
*/

import Foundation

/// Process the items in `batch` in parallel by the function `worker`.
@available(macOS 10.15, *)
public func parallel<T: Sendable>(batch: Array<T>, worker: @escaping @Sendable (T) async -> ()) {
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
            for (index,work) in batch.enumerated() {
                if index >= maxWorkers {
                    _ = await taskGroup.next()
                }
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
