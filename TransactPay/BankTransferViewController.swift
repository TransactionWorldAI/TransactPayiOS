//
//  BankTransferViewController.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import UIKit
import SnapKit

class BankTransferViewController: BasePaymentController {
    
    var orderData: OrderData? {
        didSet {
            headerView.configure(title: orderData?.subsidiary.name ?? "",
                                        amount: "\(orderData?.order.currency ?? "")\(orderData?.order.amount ?? 0)",
                                        email: orderData?.subsidiary.supportEmail ?? "")
            
        }
    }
    var payOrderData: PayOrderData? {
        didSet {
            if let data = payOrderData {
                setAccountDetails(accountNumber: data.paymentDetail.recipientAccount ?? "", amount:"\(data.orderPayment.currency)\(data.orderPayment.totalAmount)",
                                  bankName: data.bankTransferDetails?.bankCode ?? "Null",
                                  beneficiary: data.bankTransferDetails?.bankCode ?? "Null")

            }
        }
    }
    
    init(orderData: OrderData, payOrderData: PayOrderData) {
        self.payOrderData = payOrderData
        self.orderData = orderData
        self.accountNumber = payOrderData.paymentDetail.recipientAccount ?? "Null"
        self.bankName = "WEMA BANK"
        self.beneficiary = "TPAY/\(orderData.subsidiary.name)"
        self.amount = "\(payOrderData.orderPayment.currency)\(payOrderData.orderPayment.totalAmount)".toMoneyFormat() ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI Elements
    private let headerView = TransactPayHeaderView()
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Proceed to your bank app to complete this transaction"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var accountNumberView = UIStackView()
    private var amountView = UIStackView()
    private var bankNameView = UIStackView()
    private var beneficiaryView = UIStackView()
    
    private var remainingSeconds: Int = 600
    private var countdownTimer: Timer?

    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.text = "Account details are valid for this transaction only and will expire in 10:00 minutes"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I’ve sent the money", for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var accountNumber: String = ""
    private var amount: String = ""
    private var bankName: String = ""
    private var beneficiary: String = ""
    
    var paymentSentCallback: ((String) -> Void)?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        startCountdown()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.addSubview(headerView)
        view.addSubview(instructionLabel)
        setupDetailViews()
        view.addSubview(expirationLabel)
        view.addSubview(confirmButton)
        
        navigationItem.title = "Bank Transfer"
    }
    
    private func setupDetailViews() {
        accountNumberView = createDetailLabel(title: "Account Number", value: accountNumber)
        amountView = createDetailLabel(title: "Amount", value: amount)
        bankNameView = createDetailLabel(title: "Bank Name", value: bankName)
        beneficiaryView = createDetailLabel(title: "Beneficiary", value: beneficiary)
        
        view.addSubview(accountNumberView)
        view.addSubview(amountView)
        view.addSubview(bankNameView)
        view.addSubview(beneficiaryView)
    }

    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        accountNumberView.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        amountView.snp.makeConstraints { make in
            make.top.equalTo(accountNumberView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        bankNameView.snp.makeConstraints { make in
            make.top.equalTo(amountView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        beneficiaryView.snp.makeConstraints { make in
            make.top.equalTo(bankNameView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        expirationLabel.snp.makeConstraints { make in
            make.top.equalTo(beneficiaryView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(expirationLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
    }
    
    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                updateCountdownLabel()
            } else {
                timer.invalidate()
            }
        }
    }

    private func updateCountdownLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        expirationLabel.text = "Account details are valid for this transaction only and will expire in \(String(format: "%d:%02d", minutes, seconds)) minutes"
    }

    func setAccountDetails(accountNumber: String, amount: String, bankName: String, beneficiary: String) {
        self.accountNumber = accountNumber
        self.amount = amount
        self.bankName = bankName
        self.beneficiary = beneficiary
        setupDetailViews()
    }
    
    private var tag = 0
    // MARK: - Helper Method
    private func createDetailLabel(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .gray
        
        let attributes = NSMutableAttributedString()
        attributes.append(NSAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributes.append(NSAttributedString(string: "\n\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.darkGray]))
        titleLabel.attributedText = attributes
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let copyButton = UIButton(type: .system)
        copyButton.setTitle("copy", for: .normal)
        copyButton.setTitleColor(.systemRed, for: .normal)
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        tag += 1
        copyButton.tag = tag
        copyButton.addTarget(self, action: #selector(copyButtonTapped(sender:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, copyButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }

    @objc private func copyButtonTapped(sender: UIButton) {
        switch sender.tag {
        case 1:
            UIPasteboard.general.string = accountNumber
        case 2:
            UIPasteboard.general.string = amount
        case 3:
            UIPasteboard.general.string = bankName
        case 4:
            UIPasteboard.general.string = beneficiary
        default:
            break
        }
    }
    // MARK: - Actions
    @objc private func confirmButtonTapped() {
        paymentSentCallback?(orderData?.order.reference ?? "")
    }
}

class TransactPayHeaderView: UIView {
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let emailLabel = UILabel()
    
    private var separatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemRed
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(amountLabel)
        addSubview(emailLabel)
        addSubview(separatorView)

        // Configure views
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "transactpay_logo")
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .black

        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        amountLabel.textColor = .red

        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor = .gray

        // Layout using SnapKit
        logoImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }

        emailLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(amountLabel.snp.bottom).offset(4)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(title: String, amount: String, email: String) {
        titleLabel.text = title
        amountLabel.text = amount.toMoneyFormat()
        emailLabel.text = email
    }
}
