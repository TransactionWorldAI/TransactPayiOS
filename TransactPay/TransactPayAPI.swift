//
//  TransactPayAPI.swift
//  TransactPay
//
//  Created by James Anyanwu on 11/2/24.
//

import Foundation

public class TransactPayAPI {
    
    public private (set) static var apiKey: String?
    public private (set) static var encryptionKey: String?
}

public extension TransactPayAPI {
    
    static func configure(apiKey: String) {
       Self.apiKey = apiKey
    }
    
    static func configure(encryptionKey: String) {
        Self.encryptionKey = encryptionKey
    }
}
