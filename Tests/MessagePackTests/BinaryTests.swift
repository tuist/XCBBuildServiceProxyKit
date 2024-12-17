import Foundation
import XCTest

@testable import MessagePack

class BinaryTests: XCTestCase {
    let payload = Data([0x00, 0x01, 0x02, 0x03, 0x04])
    let packed = Data([0xC4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04])

    func testPack() {
        XCTAssertEqual(MessagePackValue.pack(.binary(payload)), packed)
    }

    func testUnpack() throws {
        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .binary(payload))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackBinEmpty() {
        let value = Data()
        let expectedPacked = Data([0xC4, 0x00]) + value
        XCTAssertEqual(MessagePackValue.pack(.binary(value)), expectedPacked)
    }

    func testUnpackBinEmpty() throws {
        let data = Data()
        let packed = Data([0xC4, 0x00]) + data

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, MessagePackValue.binary(data))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackBin16() {
        let value = Data(count: 0xFF)
        let expectedPacked = Data([0xC4, 0xFF]) + value
        XCTAssertEqual(MessagePackValue.pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin16() throws {
        let data = Data([0xC4, 0xFF]) + Data(count: 0xFF)
        let value = Data(count: 0xFF)

        let unpacked = try MessagePackValue.unpack(data)
        XCTAssertEqual(unpacked.value, .binary(value))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackBin32() {
        let value = Data(count: 0x100)
        let expectedPacked = Data([0xC5, 0x01, 0x00]) + value
        XCTAssertEqual(MessagePackValue.pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin32() throws {
        let data = Data([0xC5, 0x01, 0x00]) + Data(count: 0x100)
        let value = Data(count: 0x100)

        let unpacked = try MessagePackValue.unpack(data)
        XCTAssertEqual(unpacked.value, .binary(value))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackBin64() {
        let value = Data(count: 0x10000)
        let expectedPacked = Data([0xC6, 0x00, 0x01, 0x00, 0x00]) + value
        XCTAssertEqual(MessagePackValue.pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin64() throws {
        let data = Data([0xC6, 0x00, 0x01, 0x00, 0x00]) + Data(count: 0x10000)
        let value = Data(count: 0x10000)

        let unpacked = try MessagePackValue.unpack(data)
        XCTAssertEqual(unpacked.value, .binary(value))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [
            // only type byte
            Data([0xC4]), Data([0xC5]), Data([0xC6]),

            // type byte with no data
            Data([0xC4, 0x01]),
            Data([0xC5, 0x00, 0x01]),
            Data([0xC6, 0x00, 0x00, 0x00, 0x01]),
        ]

        for data in dataArray {
            do {
                _ = try MessagePackValue.unpack(data)
                XCTFail("Expected unpack to throw")
            } catch {
                XCTAssertEqual(error as? MessagePackUnpackError, .insufficientData)
            }
        }
    }
}
