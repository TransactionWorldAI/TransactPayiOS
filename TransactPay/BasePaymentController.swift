//
//  BasePaymentController.swift
//  TransactPay
//
//  Created by James Anyanwu on 11/10/24.
//

import UIKit


class BasePaymentController: UIViewController {

    private let loadingView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let toastLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        setupToastView()
        observeStateChanges()
        hideLoading()
        navigationItem.titleView?.tintColor = .systemRed
        navigationController?.navigationBar.tintColor = .systemRed
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideLoading()
        observeStateChanges()
    }
    
    private func setupLoadingView() {

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 130/255, green: 36/255, blue: 63/255, alpha: 0.4).cgColor,
            UIColor.systemRed.withAlphaComponent(0.4).cgColor,
        ]
        gradientLayer.frame = UIScreen.main.bounds
        loadingView.layer.insertSublayer(gradientLayer, at: 0)
        loadingView.layer.cornerRadius = 10
        loadingView.layer.zPosition = .greatestFiniteMagnitude
        loadingView.isHidden = true

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        loadingLabel.textColor = .white
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textAlignment = .center

        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)

        view.addSubview(loadingView)

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -10),

            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        ])
    }

    private let toastContainerView = UIView()

    private func setupToastView() {
        // Setup for the toast container view
        toastContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastContainerView.layer.cornerRadius = 10
        toastContainerView.clipsToBounds = true
        toastContainerView.alpha = 0

        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0

        toastContainerView.addSubview(toastLabel)
        
        view.addSubview(toastContainerView)
        
        toastContainerView.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubviewToFront(toastContainerView)
        toastContainerView.layer.zPosition = .greatestFiniteMagnitude
        NSLayoutConstraint.activate([
            toastContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toastContainerView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            toastContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),

            toastLabel.leadingAnchor.constraint(equalTo: toastContainerView.leadingAnchor, constant: 10),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainerView.trailingAnchor, constant: -10),
            toastLabel.topAnchor.constraint(equalTo: toastContainerView.topAnchor, constant: 5),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainerView.bottomAnchor, constant: -5)
        ])
    }

    func showToast(message: String, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            self.toastLabel.text = message
            UIView.animate(withDuration: 0.3, animations: {
                self.toastContainerView.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                    self.toastContainerView.alpha = 0
                }, completion: nil)
            }
        }
    }

    func showLoading(with message: String = "Please wait...") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadingLabel.text = message
            self.activityIndicator.startAnimating()
            self.loadingView.isHidden = false
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.loadingView.isHidden = true
        }
    }

    func showToast(message: String, duration: TimeInterval = 2.0, isError: Bool = false) {
        DispatchQueue.main.async {
            self.toastLabel.text = message
            self.toastLabel.backgroundColor = isError ? UIColor.red.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.8)
            UIView.animate(withDuration: 0.3, animations: {
                self.toastLabel.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                    self.toastLabel.alpha = 0
                }, completion: nil)
            }
        }
    }

    private func observeStateChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoadingState(_:)), name: .loadingStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleToastMessage(_:)), name: .displayToastMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleErrorToastMessage(_:)), name: .displayErrorToastMessage, object: nil)
    }

    @objc private func handleLoadingState(_ notification: Notification) {
        guard let isLoading = notification.userInfo?["isLoading"] as? Bool,
              let message = notification.userInfo?["message"] as? String else { return }

        if isLoading {
            showLoading(with: message)
        } else {
            hideLoading()
        }
    }

    @objc private func handleToastMessage(_ notification: Notification) {
        guard let message = notification.userInfo?["message"] as? String else { return }
        showToast(message: message)
    }

    @objc private func handleErrorToastMessage(_ notification: Notification) {
        guard let message = notification.userInfo?["message"] as? String else { return }
        showToast(message: message, isError: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension Notification.Name {
    static let loadingStateChanged = Notification.Name("loadingStateChanged")
    static let displayToastMessage = Notification.Name("displayToastMessage")
    static let displayErrorToastMessage = Notification.Name("displayErrorToastMessage")
}
