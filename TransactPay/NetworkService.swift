//
//  NetworkService.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import Foundation
//import SwiftyRSA

class NetworkService {
    
    let baseURL: URL
    private let authorizationToken: String
    
    init(baseURL: URL, authorizationToken: String) {
        self.baseURL = baseURL
        self.authorizationToken = authorizationToken
    }
    
    // Function to check if the API key is set
    func apiKeyCheck() -> Bool {
        if TransactPayAPI.apiKey == nil {
            print("Error: TransactPay API key not provided")
            return false
        }
        return true
    }
    
    /// Encodes a length value according to DER rules.
    private func encodeDERLength(_ length: Int) -> Data {
        if length <= 127 {
            return Data([UInt8(length)])
        } else {
            var lengthBytes = [UInt8]()
            var tempLength = length
            while tempLength > 0 {
                lengthBytes.insert(UInt8(tempLength & 0xFF), at: 0)
                tempLength >>= 8
            }
            return Data([0x80 | UInt8(lengthBytes.count)]) + Data(lengthBytes)
        }
    }

    /// Creates a valid RSA public key in PEM format using the given Base64 modulus and exponent.
    func createPEMPublicKey(modulusBase64: String, exponentBase64: String) -> String? {
        guard let modulusData = Data(base64Encoded: modulusBase64),
              let exponentData = Data(base64Encoded: exponentBase64) else {
            print("Failed to decode Base64 modulus or exponent")
            return nil
        }

        var modulusBytes = [UInt8](modulusData)
        if modulusBytes.first ?? 0 >= 0x80 {
            modulusBytes.insert(0x00, at: 0)
        }
        let modulus = Data(modulusBytes)

        var exponentBytes = [UInt8](exponentData)
        if exponentBytes.first ?? 0 >= 0x80 {
            exponentBytes.insert(0x00, at: 0)
        }
        let exponent = Data(exponentBytes)

        var keySequence = Data()
        keySequence.append(0x02)
        keySequence.append(contentsOf: encodeDERLength(modulus.count))
        keySequence.append(modulus)
        keySequence.append(0x02)
        keySequence.append(contentsOf: encodeDERLength(exponent.count))
        keySequence.append(exponent)

        var derKey = Data()
        derKey.append(0x30) // SEQUENCE
        derKey.append(contentsOf: encodeDERLength(keySequence.count))
        derKey.append(keySequence)

        let algorithmIdentifier: [UInt8] = [
            0x30, 0x0D, // SEQUENCE
            0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, // OBJECT IDENTIFIER (RSA Encryption)
            0x05, 0x00 // NULL
        ]

        var fullKeyData = Data(algorithmIdentifier)
        fullKeyData.append(0x03) // BIT STRING
        fullKeyData.append(contentsOf: encodeDERLength(derKey.count + 1))
        fullKeyData.append(0x00) // Leading zero for BIT STRING
        fullKeyData.append(derKey)

        let base64Key = fullKeyData.base64EncodedString(options: .lineLength64Characters)
        let pemKey = """
        -----BEGIN PUBLIC KEY-----
        \(base64Key)
        -----END PUBLIC KEY-----
        """
        return pemKey
    }


    // Encrypt function using SwiftyRSA
    private func encryptPayload(_ payload: String, encryptionKey: String) throws -> String {
        // Extract modulus and exponent from the provided key
        guard let (modulus, exponent) = extractRSAPublicKeyComponents(from: encryptionKey),
              let pemPublicKey =  createPEMPublicKey(modulusBase64: modulus, exponentBase64: exponent) else {
            throw EncryptionError.encodingFailed
        }
         
        
        if let encryptedPayload = Encrypter.shared.encrypt(data: payload, rsaPubKey: encryptionKey) {
            return encryptedPayload
        }
        return ""
    }
    
    // Extract RSA public key components (modulus and exponent)
    private func extractRSAPublicKeyComponents(from base64Key: String) -> (modulus: String, exponent: String)? {
        guard let keyData = Data(base64Encoded: base64Key),
              let xmlString = String(data: keyData, encoding: .utf8) else {
            print("Failed to decode Base64 key or convert to string.")
            return nil
        }
        
        // Extract <Modulus> and <Exponent> values using regex
        let modulus = extractTagValue(from: xmlString, tagName: "Modulus")
        let exponent = extractTagValue(from: xmlString, tagName: "Exponent")
        
        return (modulus, exponent)
    }
    
    // Helper function to extract value from XML tag
    private func extractTagValue(from xmlString: String, tagName: String) -> String {
        let pattern = "<\(tagName)>(.*?)</\(tagName)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: xmlString, options: [], range: NSRange(location: 0, length: xmlString.utf16.count)),
              let range = Range(match.range(at: 1), in: xmlString) else {
            return ""
        }
        return String(xmlString[range])
    }
    
    func padHex(_ hexStr: String) -> String {
        // Check the first byte
        let firstByte = hexStr.prefix(2).lowercased()
        if firstByte >= "80" {
            return "00" + hexStr
        }
        return hexStr
    }

    // Generic function to send a request
    func sendRequest<T: NetworkRequest, U: Decodable>(request: T, publicKey: String? = nil, completion: @escaping (Result<U, Error>) -> Void) {
        if !apiKeyCheck() {
            return
        }
        
        do {
            var requestData: Data
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(request)
            
            // Encrypt data if publicKey is provided
            if let publicKey = publicKey {
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    throw EncryptionError.encodingFailed
                }

                let encryptedData = try encryptPayload(jsonString, encryptionKey: TransactPayAPI.encryptionKey ?? "")
                let encryptedRequest = EncryptedRequest(data: encryptedData)
                requestData = try encoder.encode(encryptedRequest)
            } else {
                requestData = jsonData
            }
            
            guard let url = URL(string: request.endpoint, relativeTo: baseURL) else {
                throw NetworkError.invalidURL
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.httpMethod
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("Bearer \(self.authorizationToken)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue(TransactPayAPI.apiKey, forHTTPHeaderField: "api-key")
            urlRequest.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = jsonDict?["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    NotificationCenter.default.post(name: .displayToastMessage, object: nil, userInfo: ["message":  message ?? ""])
                }

                print(try? JSONSerialization.jsonObject(with: data), "data")
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(U.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}

enum EncryptionError: Error {
    case encodingFailed
    case encryptionFailed(String)
}

struct EncryptedRequest: Codable {
    let data: String
}
