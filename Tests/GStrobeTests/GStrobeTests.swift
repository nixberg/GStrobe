import XCTest
@testable import GStrobe

final class GStrobeTests: XCTestCase {
    func testGStrobe() {
        let protocolName = "TestProtocol".data(using: .ascii)!
        let a = GStrobe(customization: protocolName)
        let b = GStrobe(customization: protocolName)
        
        // Key
        let shared = Data(repeating: 0x1F, count: 32)
        a.key(shared)
        b.key(shared)
        XCTAssertEqual(a.gimli, b.gimli)

        // PRF
        var ra = Data()
        var rb = Data()
        a.prf(into: &ra, count: 32)
        b.prf(into: &rb, count: 32)
        XCTAssertEqual(ra, rb)
        XCTAssertEqual(a.gimli, b.gimli)

        // Send/receive
        let message = "Some Bytes".data(using: .ascii)!
        var ciphertext = Data(capacity: message.count)
        var decrypted = Data(capacity: message.count)
        a.send(message, into: &ciphertext)
        b.receive(ciphertext, into: &decrypted)
        XCTAssertEqual(message, decrypted)
        XCTAssertEqual(a.gimli, b.gimli)

        // AD
        a.additionalData(message)
        b.additionalData(message)
        XCTAssertEqual(a.gimli, b.gimli)

        // metaAD
        a.metaAdditionalData(message)
        b.metaAdditionalData(message)
        XCTAssertEqual(a.gimli, b.gimli)

        // MAC
        var mac = Data()
        a.sendMAC(&mac)
        XCTAssert(b.receiveMAC(mac))
        XCTAssertEqual(a.gimli, b.gimli)

        // Ratchet
        a.ratchet()
        b.ratchet()
        XCTAssertEqual(a.gimli, b.gimli)

        // Clone
        let c = GStrobe(from: a)
        let d = GStrobe(from: b)
        XCTAssertEqual(c.gimli, d.gimli)
    }

    static var allTests = [
        ("testGStrobe", testGStrobe),
    ]
}
