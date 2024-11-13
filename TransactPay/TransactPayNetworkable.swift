//
//  TransactPayNetworkable.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/28/24.
//
import Foundation
import UIKit

public protocol TransactPayProtocol {
    
    func createOrder(_ controller: UIViewController, for customer: TransactPayCustomerObject, order: TransactPayOrderDetails)
    func payOrder()
    
}

public class TransactPayNetworkable: TransactPayProtocol {
    
    private var navigatationController = UINavigationController()
    private var presentingController: UIViewController?
    var orderData: OrderData?
    
    private var customer: TransactPayCustomerObject?
    private var orderDetails: TransactPayOrderDetails?
    private var selectedPaymentOption: PaymentOption?
    private var timer: Timer?
    
    public init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigatationController.navigationBar.standardAppearance = appearance
        navigatationController.navigationBar.scrollEdgeAppearance = appearance
    }
    let service = NetworkService(baseURL: URL(string: "https://payment-api-service.transactpay.ai")!, authorizationToken: TransactPayAPI.encryptionKey ?? "")
    
    public func createOrder(_ controller: UIViewController, for customer: TransactPayCustomerObject, order: TransactPayOrderDetails) {
        presentingController = controller
        
        let createOrderRequest = CreateTransactPayOrderRequest(customer: customer, order: order, payment: Payment(redirectUrl: ""))
        
        service.sendRequest(request: createOrderRequest, publicKey: TransactPayAPI.apiKey ?? "") { [weak self] (result: Result<CreateOrderResponse, Error>) in
            switch result {
            case .success(let success):
                print(success)
                self?.orderData = success.data
                DispatchQueue.main.async {
                    self?.startPayment()
                }
            case .failure(let failure):
                print("failure", failure)
            }
        }
    }
    
    public func payOrder() {
        
    }
    
    func startPayment() {
        guard let orderData else {
            print("Cant find order data")
            return
        }
        let paymentController = PaymentOptionsViewController()
        paymentController.setup(with: orderData)
        paymentController.selectedPaymentCallback = { [weak self] payment in
            self?.selectedPaymentOption = payment
            let type = PaymentOptionType(code: payment.code)
            switch type {
            case .cardPayment:
                DispatchQueue.main.async {
                    self?.navigateToCardPayment()
                }
            case .payWithBankTransfer:
                self?.navigateToBankPayment()
            default: break
                
            }
        }
        presentingController?.present(navigatationController, animated: true)
        navigatationController.pushViewController(paymentController, animated: true)
    }
    
    func navigateToCardPayment() {
//        service.sendRequest(request: PayOrderCardRequest(reference: orderData?.order.reference ?? "",
//                                                         paymentOption: selectedPaymentOption?.code ?? "",
//                                                         country: orderData?.customer.country ?? "", card: CardDetails(cardNumber: <#T##String#>, expiryMonth: <#T##String#>, expiryYear: <#T##String#>, cvv: <#T##String#>)), completion: <#T##(Result<Decodable, any Error>) -> Void#>)
        
        let controller = CardDetailsViewController()
        controller.orderData = orderData
        controller.tapCallback = { [weak self] data in
            self?.sendCardRequest(data)
        }
        navigatationController.pushViewController(controller, animated: true)
    }
    
    func sendCardRequest(_ data: CardDetailsViewController.CardDetailsCallbackData) {
        service.sendRequest(request: PayOrderCardRequest(reference: orderData?.order.reference ?? "",
                                                                    paymentOption: selectedPaymentOption?.code ?? "",
                                                         country: orderData?.customer.country ?? "",
                                                         card: CardDetails(cardNumber: data.cardNumber, expiryMonth: String(data.expiry.dropLast(3)), expiryYear:  String(data.expiry.dropFirst(3)), cvv: data.cvv)), publicKey: TransactPayAPI.encryptionKey){ [weak self] (result: Result<PayOrderResponse, Error>) in
            
            switch result {
            case .success(let success):
                let redirectURL = success.data.paymentDetail.redirectUrl
                DispatchQueue.main.async {
                    self?.handlePaymentResponse(redirectUrl: redirectURL)
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func handlePaymentResponse(redirectUrl: String) {
        
        let webVC = WebViewController(urlString: redirectUrl)
        navigatationController.setViewControllers([webVC], animated: true)
    }
    
    func navigateToBankPayment() {
        Foundation.NotificationCenter.default.post(name: .loadingStateChanged, object: nil, userInfo: ["isLoading": true, "message": "Fetching Transfer Details..."])
        service.sendRequest(request: PayOrderBankTransferRequest(reference: orderData?.order.reference ?? "",
                                                                 paymentOption: selectedPaymentOption?.code ?? "",
                                                                 country: orderData?.customer.country ?? "",
                                                                 bankTransfer: BankTransferDetails(bankCode: "000017")), publicKey: TransactPayAPI.encryptionKey) { [weak self] (result: Result<PayOrderResponse, Error>) in
            Foundation.NotificationCenter.default.post(name: .loadingStateChanged, object: nil, userInfo: ["isLoading": false])
            switch result {
            case .success(let success):

                DispatchQueue.main.async {
                    if let order = self?.orderData {
                        let payOrder = success.data
                        let controller = BankTransferViewController(orderData: order, payOrderData: payOrder)
                        controller.orderData = self?.orderData
                        controller.paymentSentCallback = { [weak self] _ in
                            self?.pollTransaction()
                            DispatchQueue.main.async {
                                let vc = PaymentWaitingViewController()
                                self?.navigatationController.setViewControllers([vc], animated: true)
                            }
                        }
                        self?.navigatationController.pushViewController(controller, animated: true)
                    }

                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func pollTransaction() {
        timer?.invalidate()

        timer = Timer(timeInterval: 20, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        timer?.fire()
    }
    @objc private func timerAction() {
        print("Polling transaction...")
        if let reference = self.orderData?.order.reference  {
            self.transactionStatus(reference: reference)
        }
    }
    func transactionStatus(reference: String) {
        service.sendRequest(request: OrderStatusRequest(reference: reference), publicKey: TransactPayAPI.apiKey ?? "") { [weak self] (result: Result<PaymentResponse, Error>)  in
            switch result {
            case .success(let success):
                if success.data.orderSummary.statusId == 5  {
                    self?.timer?.invalidate()
                    self?.showSuccessController()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func showSuccessController() {
        DispatchQueue.main.async {
            let vc = PaymentCompletionViewController()
            self.navigatationController.setViewControllers([vc], animated: true)
        }
    }
}
