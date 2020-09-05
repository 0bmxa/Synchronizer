# Synchronizer

A simple type wrapping object that makes an otherwise asynchronous execution path (e.g. function call) synchronous (blocking).

It's essentially a Swift-y wrapper around a counting semaphore.

## Usage

Assuming you have an async function call like so:
```Swift
// Call your async function
someAsyncFunction(foo: "Foo", bar: "Bar", callback: { response in
    // Use `response` in the async context (the callback)
    if response { ... }
})

// No access to `response` here
if response { ... } // ✘ ERROR
```

With `Synchronizer` you can block execution and make a value inside the asynchronous function accessible to the outside like so:

```Swift
// Create a Synchronizer object with the expected return type
let sync = Synchronizer<SomeResponseType>()

// Call your async function
someAsyncFunction(foo: "Foo", bar: "Bar", callback: { response in
    // Assign the `response` to Synchronizer's `value` property
    // NOTE: This will allow continuation of the outer execution below
    sync.value = response
})

// Access Synchronizer's `value` property
// NOTE: This will block any further execution until `value` has been set
let response = sync.value

// Use `response` outside the async context ✔
if response { ... }
```

#### Compact notation
The above example, but with Swift's compact trailing closure usage:
```Swift
// Create and use a Synchronizer object inside an async function
let sync = Synchronizer<SomeResponseType>()
someAsyncFunction(foo: "Foo", bar: "Bar") { sync.value = $0 }
let response = sync.value

// Use `response` outside the async context \o/
if response { ... }
```