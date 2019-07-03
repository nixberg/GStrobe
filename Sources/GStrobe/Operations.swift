import Foundation

extension GStrobe {
    public func key<D: DataProtocol>(_ key: D) {
        beginOperation(with: [.A, .C])
        
        for byte in key {
            gimli[position] = byte
            advance()
        }
    }
    
    public func prf<MD: MutableDataProtocol>(into data: inout MD, count: Int) {
        beginOperation(with: [.I, .A, .C])
        
        for _ in 0..<count {
            data.append(gimli[position])
            advance()
        }
    }
    
    public func send<D: DataProtocol, MD: MutableDataProtocol>(_ plaintext: D, into ciphertext: inout MD) {
        beginOperation(with: [.A, .C, .T])
        
        for byte in plaintext {
            gimli[position] ^= byte
            ciphertext.append(gimli[position])
            advance()
        }
    }
    
    public func receive<D: DataProtocol, MD: MutableDataProtocol>(_ ciphertext: D, into plaintext: inout MD) {
        beginOperation(with: [.I, .A, .C, .T])
        
        for byte in ciphertext {
            plaintext.append(byte ^ gimli[position])
            gimli[position] = byte
            advance()
        }
    }
    
    public func additionalData<D: DataProtocol>(_ data: D) {
        beginOperation(with: .A)
        
        for byte in data {
            gimli[position] ^= byte
            advance()
        }
    }
    
    public func metaAdditionalData<D: DataProtocol>(_ data: D) {
        beginOperation(with: [.A, .M])
        
        for byte in data {
            gimli[position] ^= byte
            advance()
        }
    }
    
    public func sendMAC<MD: MutableDataProtocol>(_ mac: inout MD, count: Int = 16) {
        beginOperation(with: [.C, .T])
        
        for _ in 0..<count {
            mac.append(gimli[position])
            advance()
        }
    }
    
    public func receiveMAC<D: DataProtocol>(_ mac: D) -> Bool {
        beginOperation(with: [.I, .C, .T])
        
        var check: UInt8 = 0
        for byte in mac {
            check |= byte ^ gimli[position]
            advance()
        }
        return check == 0
    }
    
    public func ratchet(count: Int = 16) {
        beginOperation(with: .C)
        
        for _ in 0..<count {
            gimli[position] = 0
            advance()
        }
        
        assert(GStrobe.R < 16)
        var data = Data(capacity: count)
        prf(into: &data, count: count)
        key(data)
    }
}
