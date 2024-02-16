//
//  Debouncer.swift
//
//
//  Created by Ana Marquez on 16/02/2024.
//

import Foundation
import Combine

class Debouncer<T> {
    
    private var debounceCancellable: AnyCancellable?
    private var request = PassthroughSubject<T, Never>()
    
    init() {}
    
    deinit {
        self.cancel()
    }
    
    public func send(_ value: T) {
        self.request.send(value)
    }
    
    public func debounce<S>(for dueTime: S.SchedulerTimeType.Stride, scheduler: S, _ completion: @escaping ((T) -> Void)) where S : Scheduler {
        self.debounceCancellable = self.request.debounce(for: dueTime, scheduler: scheduler).sink(receiveValue: completion)
    }
    
    public func cancel() {
        self.debounceCancellable?.cancel()
    }
}
