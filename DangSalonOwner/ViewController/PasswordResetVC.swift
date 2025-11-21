//
//  PasswordResetVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/22/25.
//

import UIKit
import SnapKit
import FirebaseAuth

final class PasswordResetVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "비밀번호 재설정"
        lb.font = .boldSystemFont(ofSize: 24)
        lb.textAlignment = .center
        return lb
    }()
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "가입한 이메일 입력"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }()
    
    private let resetButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("재설정 메일 보내기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "비밀번호 찾기"
        
        setupLayout()
        resetButton.addTarget(self, action: #selector(sendResetEmail), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            emailField,
            resetButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc private func sendResetEmail() {
        guard let email = emailField.text, !email.isEmpty else {
            showAlert(title: "입력 오류", message: "이메일을 입력해주세요.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "전송 실패", message: error.localizedDescription)
                return
            }
            self?.showAlert(title: "전송 완료", message: "비밀번호 재설정 메일이 발송되었습니다.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }
}
