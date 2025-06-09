//
//  CredentialConfigureMediatingController.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/12/23.
//

import UIKit

protocol CredentialConfigureDelegate: PasswordSettingsDelegate {
    func credentialConfigureViewDidLoad(displayable: CredentialConfigureDisplayable)
    func credentialConfigureViewWillDisappear()
    func saveCredential(_ credential: AccountCredential, vc: CredentialConfigureMediatingController?)
    func generatePassword() -> String
    func deleteButtonPressed(vc: CredentialConfigureMediatingController?)
    func passwordTextFieldDidChange(_ displayable: CredentialConfigureDisplayable, text: String)
    func isFromAutofill() -> Bool
}

protocol CredentialConfigureDisplayable {
    func fillFields(with credential: AccountCredential)
    func createCredential()
    func changePasswordTextFieldBackground(with color: UIColor)
    func showPasswordSettings()
}

protocol CredentialProviderDelegate {
    func updateCredentials()
}

class CredentialConfigureMediatingController: UIViewController {
    
    @IBOutlet private(set) var scrollView: UIScrollView!
    @IBOutlet private(set) var titleField: UITextField!
    @IBOutlet private(set) var usernameField: UITextField!
    @IBOutlet private(set) var passwordField: UITextField!
    @IBOutlet private(set) var errorLabel: UILabel!
    @IBOutlet private(set) var passwordSettingsBtn: UIButton!
    @IBOutlet private(set) var generatePasswordBtn: UIButton!
    @IBOutlet private(set) var saveButton: UIButton!
    @IBOutlet private(set) var deleteBtn: UIButton!
    @IBOutlet private(set) var showPasswordBtn: UIButton!
    @IBOutlet private(set) var copyPasswordBtn: UIButton!
    @IBOutlet private(set) var undoPasswordBtn: UIButton!
    @IBOutlet private(set) var identifierTableView: UITableView!
    @IBOutlet private(set) var addIdentifierButton: UIButton!
    @IBOutlet private(set) var padConstraints: [NSLayoutConstraint]! {
        didSet {
            PadConstraints.setLeadingTrailingConstraints(self.padConstraints)
        }
    }
    
    private let delegate: CredentialConfigureDelegate?
    private let passwordUndoManager = UndoManager()
    var identifiers: [String] = []
    private let cellIdentifier: String = "IdentifierTextFieldCell"
    var passwordSettingsView: PasswordSettingsView?
    var shadowView: UIView?
    
    init(delegate: CredentialConfigureDelegate?) {
        self.delegate = delegate
        super.init(nibName: "CredentialConfigureMediatingController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.delegate = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.credentialConfigureViewDidLoad(displayable: self)
        self.setupTextFields()
        self.setupIdentifierTableView()
        self.enableUndoButton(with: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.credentialConfigureViewWillDisappear()
    }
    
    private func setupTextFields() {
        self.titleField.delegate = self
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    private func setupIdentifierTableView() {
        self.identifierTableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
    }
    
    @IBAction func passwordSettingsBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.showPasswordSettings()
    }
    
    @IBAction func generatePasswordBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let newPassword = self.delegate?.generatePassword(), !newPassword.isEmpty else {
            self.showError("Password failed to generate")
            return
        }
        self.registerPasswordUndo()
        self.hideErrorIfNeeded()
        self.setPasswordTextField(with: newPassword)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let title = self.titleField.text, !title.replacingOccurrences(of: " ", with: "").isEmpty else {
            self.showError("Title required")
            return
        }
        guard let username = self.usernameField.text, let password = self.passwordField.text, (!username.isEmpty && !password.isEmpty) else {
            self.showError("Username and password is required")
            return
        }
        
        let credential = AccountCredential(title: title, username: username, password: password, identifiers: self.identifiers)
        self.delegate?.saveCredential(credential, vc: self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        self.delegate?.deleteButtonPressed(vc: self)
    }
    
    @IBAction func showPasswordPressed(_ sender: UIButton) {
        if self.passwordField.isSecureTextEntry {
            self.showPasswordBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            self.passwordField.isSecureTextEntry = false
        } else {
            self.showPasswordBtn.setImage(UIImage(systemName: "eye"), for: .normal)
            self.passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func copyPasswordPressed(_ sender: UIButton) {
        guard let password = self.passwordField.text, !password.isEmpty else {
            return
        }
        UIPasteboard.copyToClipboard(password)
        self.showCopyToClipboardView(message: "Password copied to clipboard")
    }
    
    @IBAction func addIdentifierButtonTapped(_ sender: UIButton) {
        self.identifiers.append("")
        self.identifierTableView.reloadData()
        guard let cell = self.identifierTableView.cellForRow(at: IndexPath(row: self.identifiers.count-1, section: 0)) as? IdentifierTextFieldCell else {
            return
        }
        cell.identifierTextField.becomeFirstResponder()
        #if !targetEnvironment(macCatalyst)
        self.scrollView.contentOffset = CGPoint(x: cell.frame.origin.x, y: cell.frame.origin.y + 100)
        #endif
    }
    
    @IBAction func undoPasswordButtonPressed(_ sender: UIButton) {
        self.navigationUndoButton()
    }
    
    private func showError(_ error: String){
        self.errorLabel.text = error
        if self.errorLabel.isHidden {
            self.errorLabel.isHidden = false
        }
    }
    
    private func hideErrorIfNeeded() {
        if self.errorLabel.isHidden == false {
            self.errorLabel.isHidden = true
        }
    }
    
    func setPasswordTextField(with text: String) {
        self.passwordField.text = text
        self.delegate?.passwordTextFieldDidChange(self, text: text)
    }
    
    @objc func navigationUndoButton() {
        if self.passwordUndoManager.canUndo {
            self.passwordUndoManager.undo()
        }
        self.enableUndoButton(with: self.passwordUndoManager.canUndo)
    }
    
    @objc func undoPassword(password: String) {
        self.setPasswordTextField(with: password)
    }
    
    func enableUndoButton(with value: Bool) {
        self.undoPasswordBtn.isEnabled = value
        self.undoPasswordBtn.isUserInteractionEnabled = value
    }
    
    func registerPasswordUndo() {
        self.passwordUndoManager.registerUndo(withTarget: self, selector: #selector(undoPassword), object: self.passwordField.text)
        self.enableUndoButton(with: self.passwordUndoManager.canUndo)
    }
}

extension CredentialConfigureMediatingController: CredentialConfigureDisplayable {
    func fillFields(with credential: AccountCredential) {
        self.navigationItem.title = "Edit"
        self.titleField.text = credential.title
        self.usernameField.text = credential.decryptedUsername
        self.setPasswordTextField(with: credential.decryptedPassword)
        self.identifiers = credential.identifiers
        self.identifierTableView.reloadData()
    }
    
    func createCredential() {
        self.deleteBtn.isHidden = true
        self.navigationItem.title = "Create"
        if let textField = self.view.viewWithTag(1) {
            textField.becomeFirstResponder()
        }
    }
    
    func changePasswordTextFieldBackground(with color: UIColor) {
        self.passwordField.backgroundColor = color
    }
    
    func showPasswordSettings() {
        let newShadowView: UIView = UIView(frame: self.view.frame)
        newShadowView.backgroundColor = .label
        newShadowView.alpha = 0.4
        let settingsView: PasswordSettingsView = PasswordSettingsView.initFromNib()
        settingsView.setup(delegate: self.delegate, withCloseButton: true)
        settingsView.closeButton.addTarget(self, action: #selector(hidePasswordSettings(_:)), for: .touchUpInside)
        settingsView.layer.cornerRadius = 8
        self.view.addSubview(newShadowView)
        self.view.addSubview(settingsView)
        
        newShadowView.center = self.view.center
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = settingsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16)
        let trailingConstraint = settingsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        
        if self.delegate?.isFromAutofill() == false {
            self.padConstraints = self.padConstraints + [leadingConstraint, trailingConstraint]
        }
        
        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            settingsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            settingsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        self.passwordSettingsView = settingsView
        self.shadowView = newShadowView
    }
    
    @objc func hidePasswordSettings(_ sender: AnyObject) {
        self.passwordSettingsView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
        
        self.passwordSettingsView = nil
        self.shadowView = nil
    }
}

extension CredentialConfigureMediatingController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        #if !targetEnvironment(macCatalyst)
        let textFieldBar = KeyboardToolBar(view: self.view, textFieldTag: textField.tag)
        textField.inputAccessoryView = textFieldBar
        if textField.tag == self.passwordField.tag {
            let origin = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y + 100)
            self.scrollView.contentOffset = origin
        }
        #endif
        self.hideErrorIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        #if !targetEnvironment(macCatalyst)
        self.scrollView.setContentOffset(.zero, animated: true)
        #endif
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.passwordField {
            self.registerPasswordUndo()
            var text = (textField.text ?? "") + string
            if string.isEmpty && (range.length == textField.text?.count) {
                text = ""
            }
            self.delegate?.passwordTextFieldDidChange(self, text: text)
        }
        return true
    }
}

extension CredentialConfigureMediatingController: CopyToClipboardViewDelegate {
    func showCopyToClipboardView(message: String?) {
        self.showCopyToClipboardView(view: self.view, message: message)
    }
}

extension CredentialConfigureMediatingController: UITableViewDelegate, UITableViewDataSource, IdentifierTextFieldCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.identifiers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? IdentifierTextFieldCell else {
            return UITableViewCell()
        }
        cell.configureIdentifier(delegate: self, identifier: self.identifiers[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func deleteIdentifier(_ index: Int) {
        let title = "Do you wish to remove the following identifier?"
        let message = "\(self.identifiers[index])"
        CustomAlert.destructive(self, title: title, message: message, deleteBtn: "Remove", deleteAction: {_ in
            self.identifiers.remove(at: index)
            self.identifierTableView.reloadData()
        })
    }
    
    func textFieldCellDidUpdate(text: String, index: Int) {
        if index < self.identifiers.count {
            self.identifiers[index] = text
        }
    }
    
    func identifierTextFieldDidEndEditing(index: Int?, textFieldIsEmpty: Bool?) {
        self.scrollView.setContentOffset(.zero, animated: true)
        if let index, textFieldIsEmpty == true {
            self.identifiers.remove(at: index)
            self.identifierTableView.reloadData()
        }
    }
    
    func identifierTextFieldDidBeginEditing(origin: CGPoint) {
        #if !targetEnvironment(macCatalyst)
        self.scrollView.contentOffset = CGPoint(x: origin.x, y: origin.y + 100)
        #endif
    }
}

extension CredentialConfigureMediatingController {
    override var keyCommands: [UIKeyCommand]? {
        let undoCommand = UIKeyCommand(title: "Undo password edit", action: #selector(self.navigationUndoButton), input: "z", modifierFlags: .command)
        return (super.keyCommands ?? []) + [undoCommand]
    }
}
