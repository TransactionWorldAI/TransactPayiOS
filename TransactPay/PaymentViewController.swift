//
//  PaymentViewController.swift
//  TransactPay
//
//  Created by James Anyanwu on 10/30/24.
//

import UIKit

class PaymentViewController: BasePaymentController {
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "transactpay_logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let merchantLabel: UILabel = {
        let label = UILabel()
        label.text = "SHOP COCO BEAUTY"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "NGN 101.3"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "nndukwe@gmail.com"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your card details"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "You will be redirected to your card issuer’s verification page to complete this transaction"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue your payment", for: .normal)
        button.backgroundColor = UIColor(white: 0.9, alpha: 1)
        button.tintColor = .darkGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }
    
    // MARK: - Layout Setup
    private func setupLayout() {
        // Add subviews
        view.addSubview(backButton)
        view.addSubview(logoImageView)
        view.addSubview(merchantLabel)
        view.addSubview(amountLabel)
        view.addSubview(emailLabel)
        view.addSubview(instructionLabel)
        view.addSubview(subInstructionLabel)
        view.addSubview(continueButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32),
            
            merchantLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            merchantLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            amountLabel.topAnchor.constraint(equalTo: merchantLabel.bottomAnchor, constant: 4),
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            instructionLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 32),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subInstructionLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 8),
            subInstructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subInstructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            continueButton.topAnchor.constraint(equalTo: subInstructionLabel.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func continueButtonTapped() {
        // Handle continue payment action
    }
}
