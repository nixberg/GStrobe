import Foundation
import Gimli

enum Role : UInt8 {
    case initiator = 0
    case responder = 1
}

struct Flags : OptionSet {
    let rawValue: UInt8
    static let I = Flags(rawValue: 1 << 0) // Inbound       Transport -> cipher -> application.
    static let A = Flags(rawValue: 1 << 1) // Application   Data flows from or to application.
    static let C = Flags(rawValue: 1 << 2) // Cipher        Output depends on cipher state.
    static let T = Flags(rawValue: 1 << 3) // Transport     Sends or receives data.
    static let M = Flags(rawValue: 1 << 4) // Meta
}

public final class GStrobe {
    public static let R = 15

    static let version = 0
    static let protocolName = "GStrobe-v\(version)"

    let gimli: Gimli
    var position = 0
    var role: Role?

    public init(customization: Data) {
        gimli = Gimli()
        gimli.bytes.copyBytes(from: GStrobe.protocolName.utf8)
        gimli.permute()
        metaAdditionalData(customization)
    }
    
    public init(cloning other: GStrobe) {
        gimli = Gimli()
        let _ = gimli.words.initialize(from: other.gimli.words)
        position = other.position
        role = other.role
    }
    
    func beginOperation(with flags: Flags) {
        var opByte = flags.rawValue
        if flags.contains(.T) {
            role = role ?? (flags.contains(.I) ? .responder : .initiator)
            opByte ^= role!.rawValue
        }
        gimli.bytes[position] ^= opByte
        gimli.bytes[position + 1] ^= 0x03
        gimli.permute()
        position = 0
    }
    
    func advance() {
        position += 1
        if position >= GStrobe.R {
            gimli.bytes[position] ^= 0x02
            gimli.permute()
            position = 0
        }
    }
}
