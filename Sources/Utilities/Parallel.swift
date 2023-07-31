/*
 Utilities for parallel execution.
*/

import Foundation

/// Process the items in `batch` in parallel by the function `worker` using `threads` number of threads.
public func executeInParallel<Seq: Sequence>(batch: Seq, worker: @escaping (Seq.Element) -> (), threads: Int) {
    let queue = DispatchQueue(label: "AyncLogger", attributes: .concurrent)
    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: threads)
    
    for item in batch {
        
        group.enter()
        queue.async {
            semaphore.wait()
            worker(item)
            semaphore.signal()
            group.leave()
        }
        
    }
    
    group.wait()
}
