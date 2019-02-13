import XCTest
@testable import GStrobe

final class GStrobeTests: XCTestCase {
    func testGStrobe() {
        let protocolName = "TestProtocol".data(using: .ascii)!
        let a = GStrobe(customization: protocolName)
        let b = GStrobe(customization: protocolName)
        
        func check(line: UInt = #line) {
            for i in 0..<12 {
                XCTAssertEqual(a.gimli.words[i], b.gimli.words[i], line: line)
            }
        }
        
        // Key
        let shared = Data(repeating: 0x1F, count: 32)
        a.key(shared)
        b.key(shared)
        check()
        
        // PRF
        var ra = Data(capacity: 32)
        var rb = Data(capacity: 32)
        a.prf(into: &ra, count: 32)
        b.prf(into: &rb, count: 32)
        XCTAssertEqual(ra, rb)
        check()

        // Send/receive
        let message = "Some Bytes".data(using: .ascii)!
        var ciphertext = Data(capacity: message.count)
        var decrypted = Data(capacity: message.count)
        a.send(message, into: &ciphertext)
        b.receive(ciphertext, into: &decrypted)
        XCTAssertEqual(message, decrypted)
        check()
        
        // AD
        a.additionalData(message)
        b.additionalData(message)
        check()
        
        // metaAD
        a.metaAdditionalData(message)
        b.metaAdditionalData(message)
        check()

        // MAC
        var mac = Data(capacity: 16)
        a.sendMAC(&mac)
        XCTAssert(b.receiveMAC(mac))
        check()
        
        // Ratchet
        a.ratchet()
        b.ratchet()
        check()
        
        // Clone
        let c = GStrobe(cloning: a)
        let d = GStrobe(cloning: b)
        for i in 0..<12 {
            XCTAssertEqual(c.gimli.words[i], d.gimli.words[i])
        }
    }

    static var allTests = [
        ("testGStrobe", testGStrobe),
    ]
}
