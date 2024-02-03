//
//  _KeyValueCodingAndObserving+observeValues.swift
//  
//
//  Created by Jinwoo Kim on 2/4/24.
//

import ObjectiveC

extension _KeyValueCodingAndObserving {
    @_spi(SwainCoreTests)
    public func observeValues<Value>(
        _ keyPath: KeyPath<Self, Value>,
        options: NSKeyValueObservingOptions = []
    ) -> AsyncStream<(observer: Self, changes: NSKeyValueObservedChange<Value>)> {
        let (stream, continuation) = AsyncStream<(observer: Self, changes: NSKeyValueObservedChange<Value>)>.makeStream()
        
        let deallocNotifier = DeallocNotifier {
            continuation.finish()
        }
        
        objc_setAssociatedObject(self, Unmanaged.passUnretained(deallocNotifier).toOpaque(), deallocNotifier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let observation = observe(keyPath, options: options) { observer, changes in
            continuation.yield((observer, changes))
        }
        
        continuation.onTermination = { _ in
            observation.invalidate()
        }
        
        return stream
    }
}

fileprivate final class DeallocNotifier {
    let handler: () -> Void
    
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    deinit {
        handler()
    }
}
