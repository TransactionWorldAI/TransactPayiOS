//
//  CardDetailsViewController.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//
import UIKit

typealias CardCallback = ((CardDetailsViewController.CardDetailsCallbackData) -> Void)

class CardDetailsViewController: BasePaymentController, UITextFieldDelegate {

    struct CardDetailsCallbackData {
        var cardNumber: String
        var expiry: String
        var cvv: String
    }
    private let headerView = TransactPayHeaderView()
    private let cardNumberTextField = UITextField()
    private let expiryTextField = UITextField()
    private let cvvTextField = UITextField()
    private let saveInfoCheckbox = UIButton(type: .custom)
    private let saveInfoLabel = UILabel()
    private let payButton = UIButton(type: .system)
    private let savedCardLabel = UILabel()
    var tapCallback: CardCallback?
   
    var orderData: OrderData? {
        didSet {
            configureHeader()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupLayout()
    }

    private func setupUI() {
        cardNumberTextField.placeholder = "Card Number"
        cardNumberTextField.borderStyle = .roundedRect
        cardNumberTextField.keyboardType = .numberPad
        cardNumberTextField.delegate = self
        cardNumberTextField.layer.cornerRadius = 8

        expiryTextField.placeholder = "MM/YY"
        expiryTextField.borderStyle = .roundedRect
        expiryTextField.keyboardType = .numberPad
        expiryTextField.delegate = self
        expiryTextField.layer.cornerRadius = 8

        cvvTextField.placeholder = "CVV"
        cvvTextField.borderStyle = .roundedRect
        cvvTextField.keyboardType = .numberPad
        cvvTextField.delegate = self
        cvvTextField.layer.cornerRadius = 8

        saveInfoCheckbox.tintColor = .systemRed
        saveInfoCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        saveInfoCheckbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        saveInfoCheckbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)

        saveInfoLabel.text = "Save my information for a faster checkout"
        saveInfoLabel.font = UIFont.systemFont(ofSize: 14)

        payButton.setTitle("Pay", for: .normal)
        payButton.backgroundColor = .systemPink
        payButton.tintColor = .white
        payButton.layer.cornerRadius = 8
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        payButton.isEnabled = false

        savedCardLabel.text = "Click here to pay with a saved card"
        savedCardLabel.textColor = .systemRed
        savedCardLabel.font = UIFont.systemFont(ofSize: 14)
        savedCardLabel.textAlignment = .center
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(cardNumberTextField)
        view.addSubview(expiryTextField)
        view.addSubview(cvvTextField)
        view.addSubview(saveInfoCheckbox)
        view.addSubview(saveInfoLabel)
        view.addSubview(payButton)
        view.addSubview(savedCardLabel)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        cardNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }

        expiryTextField.snp.makeConstraints { make in
            make.top.equalTo(cardNumberTextField.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(32)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(44)
        }

        cvvTextField.snp.makeConstraints { make in
            make.top.equalTo(cardNumberTextField.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(32)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(44)
        }

        saveInfoCheckbox.snp.makeConstraints { make in
            make.top.equalTo(expiryTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(32)
        }

        saveInfoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(saveInfoCheckbox)
            make.leading.equalTo(saveInfoCheckbox.snp.trailing).offset(8)
        }

        payButton.snp.makeConstraints { make in
            make.top.equalTo(saveInfoCheckbox.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }

        savedCardLabel.snp.makeConstraints { make in
            make.top.equalTo(payButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - Text Field Validation
    private func validateField(_ textField: UITextField) {
        switch textField {
        case cardNumberTextField:
            let isValid = cardNumberTextField.text?.count == 16
            updateTextFieldAppearance(textField: cardNumberTextField, isValid: isValid)
        case expiryTextField:
            let isValid = expiryTextField.text?.count == 5
            updateTextFieldAppearance(textField: expiryTextField, isValid: isValid)
        case cvvTextField:
            let isValid = cvvTextField.text?.count == 3
            updateTextFieldAppearance(textField: cvvTextField, isValid: isValid)
        default:
            break
        }
        updatePayButtonState()
    }

    private func updatePayButtonState() {
        let isCardNumberValid = cardNumberTextField.text?.count == 16
        let isExpiryValid = expiryTextField.text?.count == 5
        let isCVVValid = cvvTextField.text?.count == 3
        payButton.isEnabled = isCardNumberValid && isExpiryValid && isCVVValid
    }

    private func updateTextFieldAppearance(textField: UITextField, isValid: Bool) {
        textField.layer.borderWidth = isValid ? 0 : 1
        textField.layer.borderColor = isValid ? UIColor.clear.cgColor : UIColor.red.cgColor
        textField.layer.cornerRadius = 8
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == expiryTextField {
            if range.location == 2 && string != "" {
                textField.text?.append("/")
            }
            return textField.text?.count ?? 0 < 5 || string == ""
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validateField(textField)
    }

    // MARK: - Actions
    @objc private func toggleCheckbox() {
        saveInfoCheckbox.isSelected.toggle()
    }

    @objc private func payButtonTapped() {
        validateField(cardNumberTextField)
        validateField(expiryTextField)
        validateField(cvvTextField)
        
        tapCallback?(CardDetailsCallbackData(cardNumber: cardNumberTextField.text ?? "",
                                             expiry: expiryTextField.text ?? "",
                                             cvv: cvvTextField.text ?? ""))
    }

    // MARK: - Configure Header
    private func configureHeader() {
        guard let order = orderData else { return }
        let merchantName = orderData?.subsidiary.name ?? ""
        let amount = "\(orderData?.order.currency ?? "")\(orderData?.order.amount ?? 0)"
        let email = orderData?.customer.email ?? ""
        headerView.configure(title: merchantName, amount: amount, email: email)
    }
}

import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadUrl()
    }
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Layout using SnapKit
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadUrl() {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        navigationController?.dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load web page: \(error.localizedDescription)")
    }
}
