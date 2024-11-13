//
//  Helper.swift
//  TransactPay
//
//  Created by James Anyanwu on 11/8/24.
//

import Foundation
import CryptoKit
import CryptoSwift

class Helper {
    
    static let shared = Helper()

    /// Encrypt data using RSA public key.
    /// - Parameters:
    ///   - data: The data to encrypt as a String.
    ///   - rsaPubKey: The RSA public key in base64 XML format.
    /// - Returns: Encrypted data in base64 encoding, or nil if encryption fails.
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
        guard let publicKey = createRSAPublicKey(modulus: modulusData, exponent: exponentData) else {
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

    /// Create an RSA public key from modulus and exponent data.
    /// - Parameters:
    ///   - modulus: The modulus data.
    ///   - exponent: The exponent data.
    /// - Returns: The SecKey representing the RSA public key, or nil if creation fails.
    func createRSAPublicKey(modulus: Data, exponent: Data) -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 4096
        ]

        // Create the key data in ASN.1 DER format
        let keyData = Data([0x30]) + asn1Length(modulus.count + exponent.count + 6) +
                      Data([0x02, UInt8(modulus.count)]) + modulus +
                      Data([0x02, UInt8(exponent.count)]) + exponent

        return SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, nil)
    }

    /// Encrypt data using RSA public key.
    /// - Parameters:
    ///   - data: The data to encrypt.
    ///   - publicKey: The RSA public key.
    /// - Returns: The encrypted data, or nil if encryption fails.
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

enum Currency: String {
    case naira = "NGN"
}
