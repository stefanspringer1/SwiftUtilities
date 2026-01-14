/*
 Utilities for parallel execution.
*/

import Foundation

/// Process the items in `batch` in parallel by the function `worker`
/// (only a subset of the items might actually be processed simultaneously).
public func parallel<T: Sendable>(batch: Array<T>, worker: @escaping @Sendable (T) async -> ()) async {
    await withTaskGroup(of: Void.self) { taskGroup in
        for work in batch {
            taskGroup.addTask {
                await worker(work)
            }
        }
    }
}

/// Process the items in `batch` in parallel by the function `worker`,
/// but no more than`maximalSimultaneousOperations` at the same time
/// (the number of items actually being processed simultaneously could be lower).
public func parallel<T: Sendable>(batch: Array<T>, maximalSimultaneousOperations: Int, worker: @escaping @Sendable (T) async -> ()) async {
    await withTaskGroup(of: Void.self) { taskGroup in
        for (index,work) in batch.enumerated() {
            if index >= maximalSimultaneousOperations {
                _ = await taskGroup.next()
            }
            taskGroup.addTask {
                await worker(work)
            }
        }
    }
}
