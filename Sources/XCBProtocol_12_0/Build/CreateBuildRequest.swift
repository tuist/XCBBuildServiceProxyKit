import Foundation
import MessagePack
import XCBProtocol

public struct CreateBuildRequest {
    public let sessionHandle: String
    public let responseChannel: UInt64
    public let buildRequest: BuildRequest // Called `request` by Xcode
    public let unknown: Bool
}

// MARK: - Decoding

extension CreateBuildRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 4 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }

        sessionHandle = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        responseChannel = try args.parseUInt64(indexPath: indexPath + IndexPath(index: 1))
        buildRequest = try args.parseObject(indexPath: indexPath + IndexPath(index: 2))
        unknown = try args.parseBool(indexPath: indexPath + IndexPath(index: 3))
    }
}
