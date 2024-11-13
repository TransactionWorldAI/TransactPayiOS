//
//  Models.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import Foundation

public struct TransactPayCustomerObject: Codable {
    let firstname: String
    let lastname: String
    let mobile: String
    let country: String
    let email: String
    
    public init(firstname: String, lastname: String, mobile: String, country: String, email: String) {
        self.firstname = firstname
        self.lastname = lastname
        self.mobile = mobile
        self.country = country
        self.email = email
    }
}

public struct TransactPayOrderDetails: Codable {
    let amount: Int
    let reference: String
    let description: String
    let currency: String
    
    public init(amount: Int, reference: String, description: String, currency: String) {
        self.amount = amount
        self.reference = reference
        self.description = description
        self.currency = currency
    }
}

struct Payment: Codable {
    let redirectUrl: String
    
    enum CodingKeys: String, CodingKey {
        case redirectUrl = "RedirectUrl"
    }
}

struct CreateTransactPayOrderRequest: Encodable {
    let customer: TransactPayCustomerObject
    let order: TransactPayOrderDetails
    let payment: Payment
}

extension CreateTransactPayOrderRequest: NetworkRequest {
    var endpoint: String {
        return "payment/order/create"
    }
    
    var httpMethod: String {
        return "POST"
    }
    
    
}

struct EncryptedOrderRequest: Encodable {
    let data: String
}


enum PaymentOptionType: String {
    case bankTransfer = "BT"
    case cardPayment = "C"
    case bankAccount = "BA"
    case ussd = "USSD"
    case payWithBankTransfer = "BANK-TRANSFER"
    case qrCodePayment = "NQR"

    var title: String {
        switch self {
        case .bankTransfer:
            return "Bank Transfer"
        case .cardPayment:
            return "Card Payment"
        case .bankAccount:
            return "Bank Account"
        case .ussd:
            return "USSD"
        case .payWithBankTransfer:
            return "Pay With Bank Transfer"
        case .qrCodePayment:
            return "QR Code Payment"
        }
    }

    var imagePath: String {
        switch self {
        case .bankTransfer:
            return "paperplane"
        case .cardPayment:
            return "creditcard"
        case .bankAccount:
            return "nairasign.bank.building.fill"
        case .ussd:
            return "ussd_icon"
        case .payWithBankTransfer:
            return "paperplane"
        case .qrCodePayment:
            return "qr_code_payment_icon"
        }
    }

    init?(code: String) {
        self.init(rawValue: code)
    }
}
