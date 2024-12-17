import Foundation
import MessagePack
import XCBProtocol

public struct CreateSessionRequest {
    public let name: String
    public let appPath: String
    public let cachePath: String
    public let inferiorProductsPath: String?
}

// MARK: - Decoding

extension CreateSessionRequest: DecodableRPCPayload {
    public init(args: [MessagePackValue], indexPath: IndexPath) throws {
        guard args.count == 4 else { throw RPCPayloadDecodingError.invalidCount(args.count, indexPath: indexPath) }

        name = try args.parseString(indexPath: indexPath + IndexPath(index: 0))
        appPath = try args.parseString(indexPath: indexPath + IndexPath(index: 1))
        cachePath = try args.parseString(indexPath: indexPath + IndexPath(index: 2))
        inferiorProductsPath = try args.parseOptionalString(indexPath: indexPath + IndexPath(index: 3))
    }
}
