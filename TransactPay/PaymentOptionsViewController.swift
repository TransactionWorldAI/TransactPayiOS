//
//  PaymentOptionsViewController.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import UIKit
import SnapKit

class PaymentOptionsViewController: BasePaymentController {

    private let headerView = TransactPayHeaderView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let paymentOptionsTitle = UILabel()

    fileprivate var paymentOptionViews: [PaymentOptionView] = []
    var selectedPaymentCallback: ((PaymentOption) -> Void)?
    var orderData: OrderData?

    var selectedPayment: PaymentOption? {
        didSet {
            if let selectedPayment {
                paymentOptionViews.forEach { $0.setSelected($0.option == selectedPayment) }
                selectedPaymentCallback?(selectedPayment)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setup(with orderData: OrderData) {
        self.orderData = orderData
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }

        // Configure header view
        headerView.configure(
            title: orderData.subsidiary.name,
            amount: "\(orderData.order.currency)\(orderData.order.amount)",
            email: orderData.subsidiary.supportEmail
        )

        // Populate payment options
        for option in orderData.otherPaymentOptions {
            let paymentOptionView = PaymentOptionView()
            paymentOptionView.setup(option)
            paymentOptionView.setSelected(option.code == orderData.payment.code)
            paymentOptionViews.append(paymentOptionView)
            paymentOptionView.tapCallback = { [weak self] option in
                self?.selectedPayment = option
            }
            stackView.addArrangedSubview(paymentOptionView)
        }
        paymentOptionViews.first?.setSelected(true)
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Payment options title
        paymentOptionsTitle.text = "Choose A Payment Option"
        paymentOptionsTitle.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        navigationItem.title = "Payment Option"

        // Add components to the main view
        view.addSubview(headerView)
        view.addSubview(paymentOptionsTitle)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 4

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        paymentOptionsTitle.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(paymentOptionsTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = stackView.frame.size
    }
}


fileprivate class PaymentOptionView: UIView {

    let iconView = UIImageView(image: UIImage(systemName: "creditcard"))
    let labelView = UILabel()
    let secondaryImagesStackView = UIStackView()
    var isSelected: Bool = false
    var tapCallback: ((PaymentOption) -> Void)?
    var option: PaymentOption!
    init() {
        super.init(frame: .zero)
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemRed.cgColor
        layer.cornerRadius = 8
        
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        addSubview(labelView)

        secondaryImagesStackView.axis = .horizontal
        secondaryImagesStackView.spacing = 8
        addSubview(secondaryImagesStackView)

        // Layout using SnapKit
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalTo(labelView)
            make.width.height.equalTo(24)
        }

        labelView.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        secondaryImagesStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(labelView)
            make.width.equalTo(80)
            make.height.equalTo(24)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapView() {
        setSelected(true)
        tapCallback?(option)
    }
    func setup(_ paymentOption: PaymentOption) {
        labelView.text = paymentOption.name
        let type = PaymentOptionType(code: paymentOption.code)
        
        iconView.image = UIImage(systemName: type?.imagePath ?? "")?.withRenderingMode(.alwaysOriginal).withTintColor(.systemRed)
        self.option = paymentOption
    }
    
    func setSelected(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 1 : 0
        backgroundColor = isSelected ? .systemRed.withAlphaComponent(0.4) : .clear
    }
}
