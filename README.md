# TransactPayiOS
Installation Add the SDK to your project using Swift Package Manager or CocoaPods.

Swift Package Manager .package(url: "https://github.com/TransactionWorldAI/TransactPayiOS.git", from: "1.0.0")

CocoaPods pod 'TransactPay'

Configuration Before using the SDK, configure it with your API keys, most prefarably at the AppDelegate:

TransactPayAPI.configure(apiKey: "YOUR_API_KEY") TransactPayAPI.configure(encryptionKey: "YOUR_ENCRYPTION_KEY")

Usage

Creating an Order To create an order, initialize TransactPayNetworkable and call createOrder().
import TransactPaySDK

let transactPay = TransactPayNetworkable()

let customer = TransactPayCustomerObject( id: "12345", name: "John Doe", email: "johndoe@example.com", country: "NG" )

let order = TransactPayOrderDetails( reference: "order123", amount: 1000, currency: "NGN" )

// Pass the current view controller for presenting the payment flow transactPay.createOrder(self, for: customer, order: order)

2 . Handling Payment Completion You can now receive callbacks when the payment status changes using the TransactPayDelegate.

TransactPayDelegate Define a delegate conforming to TransactPayDelegate to receive updates on the transaction status.

transactPay.delegate = self

extension YourViewController: TransactPayDelegate {

func didCompleteTransaction(success: Bool, message: String) {
    if success {
        print("Payment successful: \(message)")
    } else {
        print("Payment failed: \(message)")
    }
}
}
