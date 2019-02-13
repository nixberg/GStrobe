import Foundation

extension GStrobe {
    public func key(_ key: Data) {
        beginOperation(with: [.A, .C])
        
        for byte in key {
            gimli.bytes[position] = byte
            advance()
        }
    }
    
    public func prf(into data: inout Data, count: Int) {
        beginOperation(with: [.I, .A, .C])
        
        for _ in 0..<count {
            data.append(gimli.bytes[position])
            advance()
        }
    }
    
    public func send(_ plaintext: Data, into ciphertext: inout Data) {
        beginOperation(with: [.A, .C, .T])
        
        for byte in plaintext {
            gimli.bytes[position] ^= byte
            ciphertext.append(gimli.bytes[position])
            advance()
        }
    }
    
    public func receive(_ ciphertext: Data, into plaintext: inout Data) {
        beginOperation(with: [.I, .A, .C, .T])
        
        for byte in ciphertext {
            plaintext.append(byte ^ gimli.bytes[position])
            gimli.bytes[position] = byte
            advance()
        }
    }
    
    public func additionalData(_ data: Data) {
        beginOperation(with: .A)
        
        for byte in data {
            gimli.bytes[position] ^= byte
            advance()
        }
    }
    
    public func metaAdditionalData(_ data: Data) {
        beginOperation(with: [.A, .M])
        
        for byte in data {
            gimli.bytes[position] ^= byte
            advance()
        }
    }
    
    public func sendMAC(_ mac: inout Data, count: Int = 16) {
        beginOperation(with: [.C, .T])
        
        for _ in 0..<count {
            mac.append(gimli.bytes[position])
            advance()
        }
    }
    
    public func receiveMAC(_ mac: Data) -> Bool {
        beginOperation(with: [.I, .C, .T])
        
        var check: UInt8 = 0
        for byte in mac {
            check |= byte ^ gimli.bytes[position]
            advance()
        }
        return check == 0
    }
    
    public func ratchet(count: Int = 16) {
        beginOperation(with: .C)

        for _ in 0..<count {
            gimli.bytes[position] = 0
            advance()
        }
        
        assert(GStrobe.R < 16)
        var data = Data(capacity: count)
        prf(into: &data, count: count)
        key(data)
    }
}
