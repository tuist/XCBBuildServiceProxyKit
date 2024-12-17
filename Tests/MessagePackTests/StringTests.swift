import Foundation
import XCTest

@testable import MessagePack

class StringTests: XCTestCase {
    func testLiteralConversion() {
        var implicitValue: MessagePackValue

        implicitValue = "Hello, world!"
        XCTAssertEqual(implicitValue, .string("Hello, world!"))

        implicitValue = MessagePackValue(extendedGraphemeClusterLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, .string("Hello, world!"))

        implicitValue = MessagePackValue(unicodeScalarLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, .string("Hello, world!"))
    }

    func testPackFixstr() {
        let packed = Data([0xAD, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21])
        XCTAssertEqual(MessagePackValue.pack(.string("Hello, world!")), packed)
    }

    func testUnpackFixstr() {
        let packed = Data([0xAD, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x21])

        let unpacked = try? MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked?.value, .string("Hello, world!"))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackFixstrEmpty() throws {
        let packed = Data([0xA0])

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .string(""))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackStr8() {
        let string = String(repeating: "*", count: 0x20)
        XCTAssertEqual(MessagePackValue.pack(.string(string)), Data([0xD9, 0x20]) + string.data(using: .utf8)!)
    }

    func testUnpackStr8() throws {
        let string = String(repeating: "*", count: 0x20)
        let packed = Data([0xD9, 0x20]) + string.data(using: .utf8)!

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .string(string))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackStr16() {
        let string = String(repeating: "*", count: 0x1000)
        XCTAssertEqual(MessagePackValue.pack(.string(string)), [0xDA, 0x10, 0x00] + string.data(using: .utf8)!)
    }

    func testUnpackStr16() throws {
        let string = String(repeating: "*", count: 0x1000)
        let packed = Data([0xDA, 0x10, 0x00]) + string.data(using: .utf8)!

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .string(string))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackStr32() {
        let string = String(repeating: "*", count: 0x10000)
        XCTAssertEqual(
            MessagePackValue.pack(.string(string)),
            Data([0xDB, 0x00, 0x01, 0x00, 0x00]) + string.data(using: .utf8)!
        )
    }

    func testUnpackStr32() throws {
        let string = String(repeating: "*", count: 0x10000)
        let packed = Data([0xDB, 0x00, 0x01, 0x00, 0x00]) + string.data(using: .utf8)!

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .string(string))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
