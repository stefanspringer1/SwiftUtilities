/*
 Utilities for parallel execution.
*/

import Foundation

/// Process the items in `batch` in parallel by the function `worker` using `threads` number of threads.
public func parallel<T: Sendable>(batch: any Sequence<T>, threads: Int, worker: @escaping @Sendable (T) async -> ()) {
    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: threads)
    
    for item in batch {
        group.enter()
        semaphore.wait()
        Task {
            await worker(item)
            semaphore.signal()
            group.leave()
        }
    }
    
    group.wait()
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
