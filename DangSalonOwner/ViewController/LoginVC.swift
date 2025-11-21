//
//  LoginVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/5/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class LoginVC: UIViewController {
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인"
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        return label
    }()
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("로그인", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return btn
    }()
    
    // MARK: - 회원가입 / 비밀번호 찾기
    private let signupTextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("회원가입", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        return btn
    }()
    
    private let resetPasswordTextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("비밀번호 찾기", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        return btn
    }()
    
    private let dividerLabel: UILabel = {
        let lb = UILabel()
        lb.text = "|"
        lb.textColor = .systemGray
        lb.font = .systemFont(ofSize: 14, weight: .medium)
        return lb
    }()
    
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signupTextButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        resetPasswordTextButton.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        
        // ⭐ 회원가입 | 비밀번호 찾기 가로 정렬
        let horizontalStack = UIStackView(arrangedSubviews: [
            signupTextButton,
            dividerLabel,
            resetPasswordTextButton
        ])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.distribution = .equalCentering
        
        // 전체 스택
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            emailField,
            passwordField,
            loginButton,
            horizontalStack
        ])
        
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    // MARK: - Actions
    @objc private func loginTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "이메일과 비밀번호를 입력해주세요.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "로그인 실패", message: error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            self?.db.collection("users").document(uid).getDocument { snapshot, _ in
                guard let data = snapshot?.data(),
                      let isApproved = data["isApproved"] as? Bool else {
                    self?.showAlert(title: "승인 대기 중", message: "관리자 승인 후 로그인 가능합니다.")
                    return
                }
                
                if isApproved {
                    let tab = OwnerTabBarController()
                    tab.modalPresentationStyle = .fullScreen
                    self?.present(tab, animated: true)
                } else {
                    self?.showAlert(title: "승인 대기 중", message: "관리자 승인 후 로그인 가능합니다.")
                    try? Auth.auth().signOut()
                }
            }
        }
    }
    
    @objc private func resetPasswordTapped() {
        let vc = PasswordResetVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func signupTapped() {
        navigationController?.pushViewController(SignupVC(), animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }
}
