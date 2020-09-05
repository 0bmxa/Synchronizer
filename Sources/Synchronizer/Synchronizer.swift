//
//  Synchronizer.swift
//  Synchronizer
//
//  Created by 0bmxa on 2019-06-12.
//  Copyright © 2019-2020 0bmxa. All rights reserved.
//

import Dispatch
import Foundation.NSDate

/// An type wrapping object that makes an otherwise asynchronous execution path
/// (e.g. function call) synchronous (blocking).
///
/// - Note: Cannot be cancelled. For a cancellable version see
/// `CancellableSynchronizer`.
public class Synchronizer<T> {
    private let semaphore = DispatchSemaphore(value: 0)
    
    private var _value: T!
    public var value: T {
        set {
            self._value = newValue
            self.semaphore.signal()
        }
        get {
            self.semaphore.wait()
            return self._value
        }
    }
}

/// An type wrapping object that makes an otherwise asynchronous execution path
/// (e.g. function call) synchronous (blocking).
///
/// - Note: For a simpler, non-cancellable version see `Synchronizer`.
public class CancellableSynchronizer<T> {
    private let semaphore = DispatchSemaphore(value: 0)
    private let timeout: TimeInterval?
    
    init(timeout: TimeInterval? = nil) {
        self.timeout = timeout
    }
    
    private var _value: T?
    public var value: T? {
        set {
            self._value = newValue
            self.semaphore.signal()
        }
        get {
            if let timeout = self.timeout {
                _ = self.semaphore.wait(timeout: DispatchTime.now() + timeout)
                return self._value
            }
            
            self.semaphore.wait()
            return self._value
        }
    }
    
    public func cancel() {
        self.semaphore.signal()
    }
}
