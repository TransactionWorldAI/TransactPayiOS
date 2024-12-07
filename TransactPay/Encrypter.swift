//
//  Encrypter.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import Foundation
//import SwiftyRSA

class Encrypter {

    /// Encrypt data using RSA public key.
    /// - Parameters:
    ///   - data: The data to encrypt as a String.
    ///   - rsaPubKey: The RSA public key in base64 XML format.
    /// - Returns: Encrypted data in base64 encoding, or nil if encryption fails
    
    static let shared = Encrypter()
    
    func encrypt(data: String, rsaPubKey: String) -> String? {
        // Decode the base64 encoded public key and remove the prefix
        guard let decodedKeyData = Data(base64Encoded: rsaPubKey),
              let rsaKeyValue = String(data: decodedKeyData, encoding: .utf8) else {
            print("Failed to decode base64 public key")
            return nil
        }

        // Remove the prefix and extract the XML content
        let xmlContent = rsaKeyValue.replacingOccurrences(of: "4096!", with: "")
        guard let modulus = extractXmlComponent(xmlContent: xmlContent, tag: "Modulus"),
              let exponent = extractXmlComponent(xmlContent: xmlContent, tag: "Exponent") else {
            print("Failed to extract Modulus or Exponent")
            return nil
        }

        // Decode the modulus and exponent from base64
        guard let modulusData = Data(base64Encoded: modulus),
              let exponentData = Data(base64Encoded: exponent) else {
            print("Failed to decode modulus or exponent from base64")
            return nil
        }

        // Create the RSA public key
//        guard let publicKey = createRSAPublicKey(modulus: modulusData, exponent: exponentData) else {
//            print("Failed to create RSA public key")
//            return nil
//        }
        guard let publicKey = RSAPublicKey.generateRSAPublicKey(modulus: modulus, exponent: exponent) else {
            print("Failed to create RSA public key")
            return nil
        }

        // Encrypt the data
        guard let encryptedData = rsaEncrypt(data: data, publicKey: publicKey) else {
            print("Encryption failed")
            return nil
        }

        // Encode the encrypted data in base64
        return encryptedData.base64EncodedString()
    }

    /// Extract XML component value by tag name.
    /// - Parameters:
    ///   - xmlContent: The XML content as a string.
    ///   - tag: The tag name to extract.
    /// - Returns: The extracted value, or nil if not found.
    func extractXmlComponent(xmlContent: String, tag: String) -> String? {
        let pattern = "<\(tag)>(.*?)</\(tag)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: xmlContent, options: [], range: NSRange(location: 0, length: xmlContent.utf16.count)),
              let range = Range(match.range(at: 1), in: xmlContent) else {
            return nil
        }
        return String(xmlContent[range])
    }

    func rsaEncrypt(data: String, publicKey: SecKey) -> Data? {
        guard let plainData = data.data(using: .utf8) else { return nil }
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, plainData as CFData, &error) else {
            if let error = error?.takeRetainedValue() {
                print("Encryption error: \(error)")
            }
            return nil
        }
        return encryptedData as Data
    }

    /// Helper function to calculate ASN.1 length.
    /// - Parameter length: The length of the data.
    /// - Returns: The ASN.1 length as Data.
    func asn1Length(_ length: Int) -> Data {
        if length < 128 {
            return Data([UInt8(length)])
        } else {
            let lengthBytes = withUnsafeBytes(of: length.bigEndian) { Data($0) }
            return Data([0x80 | UInt8(lengthBytes.count)]) + lengthBytes
        }
    }
}

class RSAPublicKey {
    
    class func generateRSAPublicKey(modulus: String, exponent: String) -> SecKey? {
        guard let modulusData = Data(base64UrlEncoded: modulus) else {
            return nil
        }
        guard let exponentData = Data(base64UrlEncoded: exponent) else {
            return nil
        }
        
        let publicKeyAttributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ]
        
        var error: Unmanaged<CFError>?
        
        let dataa = Data(modulus: modulusData, exponent: exponentData)
        
        guard let publicKey = SecKeyCreateWithData(dataa as CFData, publicKeyAttributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                print("Failed to create RSA public key: \(error)")
            }
            return nil
        }
        var error1:Unmanaged<CFError>?
        if let cfdata = SecKeyCopyExternalRepresentation(publicKey, &error1) {
            let data:Data = cfdata as Data
            let b64Key = data.base64EncodedString()
            print("Key =>", b64Key)
        }
        return publicKey
    }
    
    class func secKeyToData(_ publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            if let error = error?.takeRetainedValue() {
                print("Failed to convert SecKey to data: \(error)")
            }
            return nil
        }
        return publicKeyData
    }
}


/// Encoding/Decoding lengths as octets
///
private extension NSInteger {
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)];
        }
        
        // Long form
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
        
        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
    
    init?(octetBytes: [CUnsignedChar], startIdx: inout NSInteger) {
        if octetBytes[startIdx] < 128 {
            // Short form
            self.init(octetBytes[startIdx])
            startIdx += 1
        } else {
            // Long form
            let octets = NSInteger(octetBytes[startIdx] as UInt8 - 128)
            
            if octets > octetBytes.count - startIdx {
                self.init(0)
                return nil
            }
            
            var result = UInt64(0)
            
            for j in 1...octets {
                result = (result << 8)
                result = result + UInt64(octetBytes[startIdx + j])
            }
            
            startIdx += 1 + octets
            self.init(result)
        }
    }
}

private extension Data {
    init(modulus: Data, exponent: Data) {
        // Make sure neither the modulus nor the exponent start with a null byte
        var modulusBytes = [CUnsignedChar](UnsafeBufferPointer<CUnsignedChar>(start: (modulus as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: modulus.count), count: modulus.count / MemoryLayout<CUnsignedChar>.size))
        let exponentBytes = [CUnsignedChar](UnsafeBufferPointer<CUnsignedChar>(start: (exponent as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: exponent.count), count: exponent.count / MemoryLayout<CUnsignedChar>.size))
        
        // Make sure modulus starts with a 0x00
        if let prefix = modulusBytes.first , prefix != 0x00 {
            modulusBytes.insert(0x00, at: 0)
        }
        
        // Lengths
        let modulusLengthOctets = modulusBytes.count.encodedOctets()
        let exponentLengthOctets = exponentBytes.count.encodedOctets()
        
        // Total length is the sum of components + types
        let totalLengthOctets = (modulusLengthOctets.count + modulusBytes.count + exponentLengthOctets.count + exponentBytes.count + 2).encodedOctets()
        
        // Combine the two sets of data into a single container
        var builder: [CUnsignedChar] = []
        let data = NSMutableData()
        
        // Container type and size
        builder.append(0x30)
        builder.append(contentsOf: totalLengthOctets)
        data.append(builder, length: builder.count)
        builder.removeAll(keepingCapacity: false)
        
        // Modulus
        builder.append(0x02)
        builder.append(contentsOf: modulusLengthOctets)
        data.append(builder, length: builder.count)
        builder.removeAll(keepingCapacity: false)
        data.append(modulusBytes, length: modulusBytes.count)
        
        // Exponent
        builder.append(0x02)
        builder.append(contentsOf: exponentLengthOctets)
        data.append(builder, length: builder.count)
        data.append(exponentBytes, length: exponentBytes.count)
        
        self.init(bytes: data.bytes, count: data.length)
    }
}

extension Data {
    init?(base64UrlEncoded: String) {
        var base64Encoded = base64UrlEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = 4 - base64Encoded.count % 4
        if paddingLength < 4 {
            base64Encoded += String(repeating: "=", count: paddingLength)
        }

        self.init(base64Encoded: base64Encoded)
    }
}
