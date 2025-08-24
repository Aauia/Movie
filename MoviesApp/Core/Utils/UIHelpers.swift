import UIKit
import ObjectiveC

// Associated object key for retry button
private var retryButtonKey: UInt8 = 0

// MARK: - ViewState
enum ViewState<T> {
    case idle
    case loading
    case content(T)
    case empty
    case error(String)
}

// MARK: - UIView Extensions
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func pinToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
    
    func pinToSuperviewSafeArea(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

// MARK: - UIViewController Extensions
extension UIViewController {
    func showError(_ message: String, retry: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Remove existing error view
            self.view.subviews.first { $0.tag == 999 }?.removeFromSuperview()
            
            let errorView = UIView()
            errorView.tag = 999
            errorView.backgroundColor = .systemBackground
            errorView.translatesAutoresizingMaskIntoConstraints = false
            
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let errorLabel = UILabel()
            errorLabel.text = message
            errorLabel.textColor = .secondaryLabel
            errorLabel.textAlignment = .center
            errorLabel.numberOfLines = 0
            errorLabel.font = .systemFont(ofSize: 16)
            
            stackView.addArrangedSubview(errorLabel)
            
            if let retry = retry {
                let retryButton = UIButton(type: .system)
                retryButton.setTitle(NSLocalizedString("Повторить", comment: ""), for: .normal)
                retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
                retryButton.backgroundColor = .systemBlue
                retryButton.setTitleColor(.white, for: .normal)
                retryButton.layer.cornerRadius = 8
                retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
                retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
                
                // Store retry closure for later use
                objc_setAssociatedObject(retryButton, &retryButtonKey, retry, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                
                stackView.addArrangedSubview(retryButton)
            }
            
            errorView.addSubview(stackView)
            self.view.addSubview(errorView)
            
            NSLayoutConstraint.activate([
                errorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                errorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                errorView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 32),
                errorView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -32),
                
                stackView.topAnchor.constraint(equalTo: errorView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: errorView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
            ])
        }
    }
    
    func showEmpty(_ message: String = "Нет данных для отображения") {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Remove existing empty view
            self.view.subviews.first { $0.tag == 998 }?.removeFromSuperview()
            
            let emptyView = UIView()
            emptyView.tag = 998
            emptyView.backgroundColor = .systemBackground
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            
            let emptyLabel = UILabel()
            emptyLabel.text = message
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.font = .systemFont(ofSize: 16)
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            emptyView.addSubview(emptyLabel)
            self.view.addSubview(emptyView)
            
            NSLayoutConstraint.activate([
                emptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                emptyView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                emptyView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 32),
                emptyView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -32),
                
                emptyLabel.topAnchor.constraint(equalTo: emptyView.topAnchor),
                emptyLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
                emptyLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
                emptyLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
            ])
        }
    }
    
    func hideErrorAndEmpty() {
        DispatchQueue.main.async { [weak self] in
            self?.view.subviews.first { $0.tag == 999 }?.removeFromSuperview()
            self?.view.subviews.first { $0.tag == 998 }?.removeFromSuperview()
        }
    }
    
    @objc private func retryButtonTapped(_ sender: UIButton) {
        if let retry = objc_getAssociatedObject(sender, &retryButtonKey) as? (() -> Void) {
            retry()
        }
    }
}
