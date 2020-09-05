import XCTest
@testable import Synchronizer


func myAsyncFunction(greet: String, whom: String, callback: @escaping (String) -> Void) {
    let message = "\(greet) \(whom)!"
    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
        callback(message)
    }
}


final class SynchronizerTests: XCTestCase {
    func testNotWorking() {
        var output = ""
        myAsyncFunction(greet: "Hello", whom: "World") { message in
            output = message
        }
        XCTAssertNotEqual(output, "Hello World!")
    }

    func testWorking() {
        let sync = Synchronizer<String>()
        myAsyncFunction(greet: "Hello", whom: "World") { message in
            sync.value = message
        }
        XCTAssertEqual(sync.value, "Hello World!")
    }
}
