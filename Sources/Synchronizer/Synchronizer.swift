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
    /// The counting semaphore doing all the magic.
    private let semaphore = DispatchSemaphore(value: 0)
    /// The internal storage for the value to be transported.
    private var _value: T!

    /// Creates a new non-cancellable Synchronizer object.
    public init() {}

    /// The value to be transported.
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
    /// The counting semaphore doing all the magic.
    private let semaphore = DispatchSemaphore(value: 0)
    /// The internal storage for the value to be transported.
    private var _value: T?
    /// The timeout in seconds, if any.
    private let timeout: TimeInterval?
    
    /// Creates a new CancellableSynchronizer object.
    /// - Parameter timeout: An optional timeout value (in seconds) of how long
    ///   to wait before cancelling the blocking
    public init(timeout: TimeInterval? = nil) {
        self.timeout = timeout
    }
    
    /// The value to be transported.
    /// - Important:
    ///   - Read access to this is blocking (sends the thread to sleep). It
    ///     starts the timeout countdown, if set.
    ///   - Write access triggers continuation of the previously paused
    ///     execution (wakes the thread up).
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
    
    /// Cancels the blocking, i.e. triggers continuation of the previously
    /// paused execution.
    public func cancel() {
        self.semaphore.signal()
    }
}
