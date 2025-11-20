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
    
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름"
        tf.borderStyle = .roundedRect
        return tf
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
    
    private let phoneField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "휴대폰 번호 (숫자만)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private let requestCodeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("인증번호 요청", for: .normal)
        btn.backgroundColor = .systemGray4
        btn.layer.cornerRadius = 8
        btn.setTitleColor(.black, for: .normal)
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return btn
    }()
    
    private let codeField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "인증번호 입력"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
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
    private var verificationID: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "회원가입"
        setupLayout()
        
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        requestCodeButton.addTarget(self, action: #selector(requestCode), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            nameField,
            emailTextField,
            phoneField,
            requestCodeButton,
            codeField,
            passwordField,
            confirmPasswordField,
            signupButton
        ])
        stack.axis = .vertical
        stack.spacing = 14
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    @objc private func requestCode() {
        guard let phone = phoneField.text, !phone.isEmpty else {
            showAlert(title: "입력 오류", message: "휴대폰 번호를 입력해주세요.")
            return
        }
        
        let fullPhone = "+82" + phone.dropFirst(1)
        
        PhoneAuthProvider.provider().verifyPhoneNumber(fullPhone, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.showAlert(title: "오류", message: error.localizedDescription)
                return
            }
            
            self.verificationID = verificationID
            self.showAlert(title: "인증번호 발송", message: "휴대폰으로 인증번호가 전송되었습니다.")
        }
    }
    
    // MARK: - Actions
    // MARK: - 회원가입 처리
    @objc private func signupTapped() {
        
        guard let name = nameField.text, !name.isEmpty else {
            return showAlert(title: "입력 오류", message: "이름을 입력해주세요.")
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            return showAlert(title: "입력 오류", message: "이메일을 입력해주세요.")
        }
        
        guard let phone = phoneField.text, !phone.isEmpty else {
            return showAlert(title: "입력 오류", message: "휴대폰 번호를 입력해주세요.")
        }
        
        guard let code = codeField.text, !code.isEmpty else {
            return showAlert(title: "인증 필요", message: "인증번호를 입력해주세요.")
        }
        
        guard let password = passwordField.text,
              let confirm = confirmPasswordField.text,
              !password.isEmpty, !confirm.isEmpty else {
            return showAlert(title: "입력 오류", message: "비밀번호를 모두 입력해주세요.")
        }
        
        guard password == confirm else {
            return showAlert(title: "불일치", message: "비밀번호가 일치하지 않습니다.")
        }
        
        guard isValidPassword(password) else {
            return showAlert(title: "비밀번호 오류", message: "비밀번호는 8자 이상, 특수문자를 포함해야 합니다.")
        }
        
        guard let verificationID = verificationID else {
            return showAlert(title: "인증 필요", message: "휴대폰 인증을 먼저 진행해주세요.")
        }
        
        // 🔥 휴대폰 인증 검증
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        
        Auth.auth().signIn(with: credential) { _, error in
            if let error = error {
                return self.showAlert(title: "인증 실패", message: error.localizedDescription)
            }
            
            // 🔥 email + password 계정 생성
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    return self.showAlert(title: "회원가입 실패", message: error.localizedDescription)
                }
                
                guard let uid = result?.user.uid else { return }
                
                // 🔥 Firestore 저장
                self.db.collection("users").document(uid).setData([
                    "name": name,
                    "email": email,
                    "phone": phone,
                    "role": "owner",
                    "isApproved": false,
                    "createdAt": Timestamp()
                ]) { error in
                    if let error = error {
                        self.showAlert(title: "저장 오류", message: error.localizedDescription)
                    } else {
                        self.showAlert(title: "가입 완료", message: "회원가입이 완료되었습니다.") {
                            self.navigationController?.popViewController(animated: true)
                        }
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
