//
//  CreateOrder.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import Foundation

struct CreateOrderResponse: Codable {
    let data: OrderData
    let status: String
    let statusCode: String
    let message: String
}

struct OrderData: Codable {
    let order: OrderInfo
    let subsidiary: SubsidiaryInfo
    let customer: CustomerInfo
    let payment: PaymentInfo
    let otherPaymentOptions: [PaymentOption]
    let savedCards: [SavedCard]
    let subsidiaryOrderSummary: CreateOrderSummary
}

struct OrderInfo: Codable {
    let reference: String
    let processorReference: String
    let orderPaymentReference: String?
    let amount: Int
    let fee: Int
    let feeRate: Int
    let statusId: Int
    let status: String
    let currency: String
    let narration: String
}

struct SubsidiaryInfo: Codable {
    let id: Int
    let name: String
    let country: String
    let supportEmail: String
    let customization: [String]
}

struct CustomerInfo: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let mobile: String
    let country: String
}

struct PaymentInfo: Codable {
    let code: String?
    let source: String
    let selectedOption: String?
    let accountNumber: String?
    let bankProviderName: String?
}

struct PaymentOption: Codable {
    let code: String
    let name: String
    let currency: String
}

extension PaymentOption: Equatable {
    
}
struct SavedCard: Codable {
    
}

struct CreateOrderSummary: Codable {
    let orderName: String
    let totalAmount: Int
    let reference: String
    let currency: String
    let orderItems: [OrderItem]
}

struct OrderItem: Codable {
    let name: String
    let amount: Int
}
