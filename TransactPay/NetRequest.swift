//
//  NetRequest.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import Foundation

protocol NetworkRequest: Codable {
    var endpoint: String { get }
    var httpMethod: String { get }
}

