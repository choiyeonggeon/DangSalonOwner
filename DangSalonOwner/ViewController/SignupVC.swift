//
//  SignupVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/5/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class SignupVC: UIViewController {
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "회원가입"
        lb.font = .boldSystemFont(ofSize: 24)
        lb.textAlignment = .center
        return lb
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호 (특수문자 포함, 최소 8자)"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호 확인"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("회원가입", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return btn
    }()
    
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "회원가입"
        setupLayout()
        
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            emailTextField,
            passwordField,
            confirmPasswordField,
            signupButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    // MARK: - Actions
    
    @objc private func signupTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(title: "입력 오류", message: "모든 필드를 입력해주세요.")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "비밀번호 불일치", message: "비밀번호가 일치하지 않습니다.")
            return
        }
        
        guard isValidPassword(password) else {
            showAlert(title: "비밀번호 오류", message: "비밀번호는 최소 8자 이상이며 특수문자를 포함해야 합니다.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "회원가입 실패", message: error.localizedDescription)
                return
            }
            guard let uid = result?.user.uid else { return }
            
            self?.db.collection("users").document(uid).setData([
                "email": email,
                "role": "owner",
                "isApproved": false,
                "createdAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    self?.showAlert(title: "저장 실패", message: error.localizedDescription)
                } else {
                    self?.showAlert(title: "가입 완료", message: "회원가입이 완료되었습니다.\n관리자 승인 후 로그인 가능합니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func isValidPassword(_ password: String) -> Bool {
        let regex = "(?=.*[!@#$^&*(),.?\":{}|<>]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    
    private func showAlert(title: String, message: String, okHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in okHandler?() })
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
