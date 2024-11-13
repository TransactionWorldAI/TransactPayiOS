//
//  WaitingForPaymentViewController.swift
//  TransactPay
//
//  Created by James Anyanwu on 11/10/24.
//

import UIKit

class PaymentWaitingViewController: BasePaymentController {

    private let messageLabel = UILabel()
    private let countdownLabel = UILabel()
    private let progressCircle = CAShapeLayer()
    private var countdownTimer: Timer?
    private var remainingSeconds = 300

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupMessageLabel()
        setupCountdownLabel()
        setupProgressCircle()
        startCountdown()
        
        navigationController?.navigationBar.isHidden = true
    }

    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 130/255, green: 36/255, blue: 63/255, alpha: 1).cgColor,
            UIColor.systemRed.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.addSublayer(gradientLayer)
    }

    private func setupMessageLabel() {
        messageLabel.text = "Waiting to receive your payment"
        messageLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        view.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80)
        ])

        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.5
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        messageLabel.layer.add(pulseAnimation, forKey: "pulsing")
    }

    private func setupCountdownLabel() {
        countdownLabel.text = "5:00"
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 37, weight: .heavy)
        countdownLabel.textColor = .white
        countdownLabel.textAlignment = .center
        view.addSubview(countdownLabel)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 35)
        ])
        
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.7
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        countdownLabel.layer.add(pulseAnimation, forKey: "pulsing")
    }

    private func setupProgressCircle() {
        let circlePath = UIBezierPath(arcCenter: view.center, radius: 60, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)

        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = UIColor.white.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = 6
        progressCircle.strokeEnd = 1.0
        view.layer.addSublayer(progressCircle)
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.updateCountdownLabel()
                self.updateProgressCircle()
            } else {
                timer.invalidate()
                self.showCompletionScreen()
            }
        }
    }

    private func updateCountdownLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        countdownLabel.text = String(format: "%d:%02d", minutes, seconds)
    }

    private func updateProgressCircle() {
        let progress = CGFloat(remainingSeconds) / 300.0
        progressCircle.strokeEnd = progress
    }

    private func showCompletionScreen() {
        let completionVC = PaymentCompletionViewController()
        navigationController?.pushViewController(completionVC, animated: true)
    }
}

class PaymentCompletionViewController: UIViewController {

    private let tickImageView = UIImageView()
    private let successLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTickImageView()
        setupSuccessLabel()
    }

    private func setupTickImageView() {
        tickImageView.image = UIImage(systemName: "checkmark.circle.fill")
        tickImageView.tintColor = .systemGreen
        tickImageView.contentMode = .scaleAspectFit
        view.addSubview(tickImageView)
        tickImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tickImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tickImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            tickImageView.widthAnchor.constraint(equalToConstant: 150),
            tickImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func setupSuccessLabel() {
        successLabel.text = "Payment Successful"
        successLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        successLabel.textColor = .systemGreen
        successLabel.textAlignment = .center
        view.addSubview(successLabel)
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.topAnchor.constraint(equalTo: tickImageView.bottomAnchor, constant: 20)
        ])
    }
}
