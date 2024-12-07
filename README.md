# TransactPayiOS

TransactPayiOS is a simple SDK to integrate payment functionality into your iOS app.

## Installation

### Swift Package Manager
Add the SDK to your project using Swift Package Manager:

```swift
.package(url: "https://github.com/TransactionWorldAI/TransactPayiOS.git", from: "1.0.0")
```
## CocoaPods
Alternatively, you can use CocoaPods to integrate the SDK:
```swift
pod 'TransactPay'
```
## Configuration
Before using the SDK, configure it with your API keys, ideally in your AppDelegate:

```swift
TransactPayAPI.configure(apiKey: "YOUR_API_KEY")
TransactPayAPI.configure(encryptionKey: "YOUR_ENCRYPTION_KEY")
```
## Usage
Creating an Order
To create an order, initialize TransactPayNetworkable and call createOrder():

```swift
import TransactPaySDK

let transactPay = TransactPayNetworkable()

let customer = TransactPayCustomerObject(
    id: "12345",
    name: "John Doe",
    mobile: "08123456789",
    country: "NG",
    email: "johndoe@example.com"
)

let order = TransactPayOrderDetails(
    amount: 1000,
    reference: "order123",
    description: "This is a description",
    currency: "NGN"
)

// Pass the current view controller for presenting the payment flow
transactPay.createOrder(self, for: customer, order: order)
```

# Handling Payment Completion
You can receive callbacks when the payment status changes by using the TransactPayDelegate.

```swift
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
```

## Example Integration
ViewController.swift
This is an example of how to integrate the SDK into your view controller.

```swift
import UIKit
import TransactPay

class ViewController: UIViewController {
    let transactPay = TransactPayNetworkable()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let customer = TransactPayCustomerObject(
            firstname: "John",
            lastname: "Doe",
            mobile: "08123456789",
            country: "NGN",
            email: "example@gmail.com"
        )

        let order = TransactPayOrderDetails(
            amount: 1000,
            reference: UUID().uuidString,
            description: "This is a description",
            currency: "NGN"
        )
        
        transactPay.createOrder(self, for: customer, order: order)
    }
}
```
