//
//  CopyToClipboardConfirmationView.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/15/23.
//

import UIKit

protocol CopyToClipboardViewDelegate {
    func showCopyToClipboardView(message: String?)
}

extension CopyToClipboardViewDelegate {
    func showCopyToClipboardView(view: UIView, message: String?) {
        let copyToClipboardView = CopyToClipboardConfirmationView.loadFromNib()
        copyToClipboardView.setup(message: message)
        copyToClipboardView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
          view.addSubview(copyToClipboardView)
        }, completion: nil)
        NSLayoutConstraint.activate([
            copyToClipboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            copyToClipboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            copyToClipboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            copyToClipboardView.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        // Remove after set time interval
        let timeInterval: TimeInterval = 1.5
        let duration: TimeInterval = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            UIView.animate(withDuration: duration, animations: {
                copyToClipboardView.alpha = 0
            }, completion: { _ in
                copyToClipboardView.removeFromSuperview()
            })
        }
    }
}

class CopyToClipboardConfirmationView: UIView, UIViewLoading {
    @IBOutlet private(set) var messageLabel: UILabel!
        
    func setup(message: String?) {
        self.messageLabel.text = message
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.vaultPassYellow()?.cgColor
    }
}
