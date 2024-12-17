import Foundation
import MessagePack
import XCBProtocol

public struct BuildOperationPreparationCompleted {
    public init() {}
}

// MARK: - ResponsePayloadConvertible

extension BuildOperationPreparationCompleted: ResponsePayloadConvertible {
    public func toResponsePayload() -> ResponsePayload { .buildOperationPreparationCompleted(self) }
}

// MARK: - Decoding

extension BuildOperationPreparationCompleted: CustomDecodableRPCPayload {
    public init(values _: [MessagePackValue], indexPath _: IndexPath) {}
}

extension BuildOperationPreparationCompleted: CustomEncodableRPCPayload {
    public func encode() -> MessagePackValue {
        .nil
    }
}
