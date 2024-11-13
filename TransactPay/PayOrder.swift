//
//  PayOrder.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import Foundation

struct PayOrderCardRequest: Codable {
    let reference: String
    let paymentOption: String
    let country: String
    let card: CardDetails
}

struct CardDetails: Codable {
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvv: String
}

struct PayOrderBankTransferRequest: Codable {
    let reference: String
    let paymentOption: String
    let country: String
    let bankTransfer: BankTransferDetails
}

struct BankTransferDetails: Codable {
    let bankCode: String
}

struct EncryptedPayOrderRequest: Codable {
    let data: String
}


struct PayOrderResponse: Codable {
    let data: PayOrderData
    let status: String
    let statusCode: String
    let message: String
}

struct PayOrderData: Codable {
    let paymentDetail: PaymentDetail
    let bankTransferDetails: BankTransferDetails?
    let orderPayment: PayOrderPayment
}

struct PaymentDetail: Codable {
    let redirectUrl: String
    let recipientAccount: String?
    let paymentReference: String
}


extension PayOrderBankTransferRequest: NetworkRequest {
    var endpoint: String {
        return "payment/order/pay"
    }
    
    var httpMethod: String {
        return "POST"
    }
      
}
extension PayOrderCardRequest: NetworkRequest {
    var endpoint: String {
        return "payment/order/pay"
    }
    
    var httpMethod: String {
        return "POST"
    }
      
}
struct PayOrderPayment: Codable {
    let orderId: Int
    let orderPaymentReference: String
    let currency: String
    let statusId: Int
    let orderPaymentResponseCode: String
    let orderPaymentResponseMessage: String
    let orderPaymentInstrument: String?
    let remarks: String
    let totalAmount: Int
    let fee: Int
}

struct OrderStatusRequest: Encodable {
    let reference: String
}

extension OrderStatusRequest: NetworkRequest {
    var endpoint: String {
        return "payment/order/status"
    }
    
    var httpMethod: String {
        return "POST"
    }
}

// Root Response Model
struct PaymentResponse: Codable {
    let status: String
    let statusCode: String
    let message: String
    let data: PaymentData
}

struct PaymentData: Codable {
    let isFinalStatus: Bool
    let requeryNeeded: Bool
    let requeryType: String?
    let orderSummary: OrderSummary
    let orderPayments: [OrderPayment]
}

 
struct OrderSummary: Codable {
    let id: Int
    let paymentReference: String
    let orderReference: String
    let totalChargedAmount: Double
    let fee: Double
    let statusId: Int
    let status: String
    let paymentType: String
    let currencyId: Int
    let paymentResponseCode: String
    let paymentResponseMessage: String
    let providerResponseDate: String?
    let datePaymentConfirmed: String?
    let dateCreated: String
    let narration: String
    let remarks: String
}

// Order Payment Model
struct OrderPayment: Codable {
    let orderId: Int
    let orderPaymentReference: String
    let paymentOptionId: Int
    let statusId: Int
    let orderPaymentResponseCode: String
    let orderPaymentResponseMessage: String
    let orderPaymentInstrument: String?
    let remarks: String
    let providerReference: String
    let providerResponseCode: String
    let paymentUrl: String
    let externalReference: String
    let authOption: String?
    let order: String?
    let id: Int?
    let dateCreated: String?
    let dateUpdated: String?
    let dateDeleted: String?
    let createdBy: Int?
    let updatedBy: Int?
    let deletedBy: Int?
}
