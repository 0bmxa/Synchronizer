import XCTest
@testable import Synchronizer


func myAsyncFunction(greet: String, whom: String, callback: @escaping (String) -> Void) {
    let message = "\(greet) \(whom)!"
    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
        callback(message)
    }
}


final class SynchronizerTests: XCTestCase {
    /// Tests that `myAsyncFunction` actually behaves async.
    func testAsyncFailure() {
        var output = ""
        myAsyncFunction(greet: "Hello", whom: "World") { message in
            output = message
        }
        XCTAssertNotEqual(output, "Hello World!")
    }
    
    /// Tests Synchronizer.
    func testSynchronizer() {
        let sync = Synchronizer<String>()
        myAsyncFunction(greet: "Hello", whom: "World") { message in
            sync.value = message
        }
        XCTAssertEqual(sync.value, "Hello World!")
    }

    /// Tests CancellableSynchronizer.
    func testCancellableSynchronizer() {
        let sync = CancellableSynchronizer<String>()
        myAsyncFunction(greet: "Hello", whom: "World") { message in
            sync.value = message
        }
        let response = sync.value
        XCTAssertNotNil(response)
        XCTAssertEqual(response!, "Hello World!")
    }

    /// Tests CancellableSynchronizer can be cancelled.
    func testCancellableSynchronizerCanBeCancelled() {
        let sync = CancellableSynchronizer<String>()
        myAsyncFunction(greet: "Hello", whom: "World") { message in
            sync.value = message
        }
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            sync.cancel()
        }

        let response = sync.value
        XCTAssertNil(response)
    }
}
