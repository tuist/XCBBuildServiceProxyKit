import Foundation
import MessagePack
import NIO
import os

/// An RPC response sent to Xcode.
public struct RPCResponse<Payload: ResponsePayload>: CustomStringConvertible {
    public var description: String { "Channel: \(channel) - Payload: \(payload) " }

    public let channel: UInt64
    public let payload: Payload

    public init(channel: UInt64, payload: Payload) {
        self.channel = channel
        self.payload = payload
    }
}

// MARK: - Encoder/Decoder

/// Encodes `RPCResponse`s into `RPCPacket`s.
public final class RPCResponseEncoder<Payload: ResponsePayload>: ChannelOutboundHandler {
    public typealias OutboundIn = RPCResponse<Payload>
    public typealias OutboundOut = RPCPacket

    public init() {}

    public func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let packet = RPCPacket(unwrapOutboundIn(data))
        context.write(wrapOutboundOut(packet), promise: promise)
    }
}

/// Decodes `RPCResponse`s from `RPCPacket`s.
public final class RPCResponseDecoder<Payload: ResponsePayload>: ChannelInboundHandler {
    public typealias InboundIn = RPCPacket
    public typealias InboundOut = RPCResponse<Payload>

    public init() {}

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let packet = unwrapInboundIn(data)
        let response = RPCResponse<Payload>(packet)

        os_log(.debug, "RPCResponse decoded: \(response)")

        context.fireChannelRead(wrapInboundOut(response))
    }
}

extension RPCResponse {
    init(_ packet: RPCPacket) {
        let payload: Payload
        do {
            payload = try packet.body.parseObject(indexPath: IndexPath())
        } catch {
            let errorStr = "\(error)"
            os_log(.error, "Failed parsing ResponsePayload received from XCBBuildService: \(errorStr)\nValues: \(packet.body)")

            payload = .unknownResponse(values: packet.body)
        }

        self.init(
            channel: packet.channel,
            payload: payload
        )
    }
}

extension RPCPacket {
    init(_ response: RPCResponse<some ResponsePayload>) {
        self.init(
            channel: response.channel,
            body: response.payload.encode()
        )
    }
}

enum ResponseParsingError: Error {
    case nameNotFound
    case indexOutOfBounds(indexPath: IndexPath)
    case incorrectValueType(indexPath: IndexPath, expectedType: Any.Type)
}
