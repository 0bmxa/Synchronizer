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
public class Synchronizer<Response> {
    /// The counting semaphore doing all the magic.
    private let semaphore = DispatchSemaphore(value: 0)
    /// The internal storage for the value to be captured.
    private var _value: Response!

    /// Creates a new non-cancellable Synchronizer object.
    public init() {}

    /// The value to be captured.
    /// - Important:
    ///   - Read access to this is blocking (sends the thread to sleep).
    ///   - Write access triggers continuation of the previously paused
    ///     execution (wakes the thread up).
    public var value: Response {
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
public class CancellableSynchronizer<Response> {
    /// The counting semaphore doing all the magic.
    private let semaphore = DispatchSemaphore(value: 0)
    /// The internal storage for the value to be captured.
    private var _value: Response?
    /// The timeout in seconds, if any.
    private let timeout: TimeInterval?
    
    /// Creates a new CancellableSynchronizer object.
    /// - Parameter timeout: An optional timeout value (in seconds) of how long
    ///   to wait before cancelling the blocking.
    public init(timeout: TimeInterval? = nil) {
        self.timeout = timeout
    }
    
    /// The value to be captured.
    /// - Important:
    ///   - Read access to this is blocking (sends the thread to sleep). It
    ///     starts the timeout countdown, if set.
    ///   - Write access triggers continuation of the previously paused
    ///     execution (wakes the thread up).
    public var value: Response? {
        set {
            self._value = newValue
            self.semaphore.signal()
        }
        get {
            let timeout: DispatchTime = self.timeout != nil ? .now() + self.timeout! : .distantFuture
            _ = self.semaphore.wait(timeout: timeout)
            return self._value
        }
    }
    
    /// Cancels the waiting, i.e. triggers continuation of the previously
    /// paused execution.
    public func cancel() {
        self.semaphore.signal()
    }
}
