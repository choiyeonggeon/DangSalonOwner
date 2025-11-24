//
//  OwnerProfileVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/22/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class OwnerProfileVC: UIViewController {
    
    private let db = Firestore.firestore()
    private var userData: [String: Any] = [:]
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let changePasswordButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 정보"
        view.backgroundColor = .systemGroupedBackground
        
        guard Auth.auth().currentUser != nil else {
            showLoginRequiredView()
            return
        }
        
        setupUI()
        fetchUserInfo()
    }
    
    private func setupUI() {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 14
        
        [nameLabel, emailLabel, phoneLabel, changePasswordButton]
            .forEach { container.addSubview($0) }
        
        view.addSubview(container)
        
        container.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(240)
        }
        
        nameLabel.font = .boldSystemFont(ofSize: 18)
        emailLabel.font = .systemFont(ofSize: 16)
        phoneLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .label
        emailLabel.textColor = .darkGray
        phoneLabel.textColor = .darkGray
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        changePasswordButton.setTitle("비밀번호 변경", for: .normal)
        changePasswordButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        changePasswordButton.backgroundColor = .systemBlue
        changePasswordButton.setTitleColor(.white, for: .normal)
        changePasswordButton.layer.cornerRadius = 10
        
        changePasswordButton.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
    }
    
    @objc private func changePasswordTapped() {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let ac = UIAlertController(
            title: "비밀번호 변경",
            message: "비밀번호 재설정 이메일을 전송합니다.",
            preferredStyle: .alert
        )
        
        ac.addAction(UIAlertAction(title: "취소", style: .cancel))
        ac.addAction(UIAlertAction(title: "전송", style: .default, handler: { _ in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(title: "오류", message: error.localizedDescription)
                    return
                }
                self.showAlert(title: "전송 완료", message: "비밀번호 변경 이메일을 확인하세요.")
            }
        }))
        
        present(ac, animated: true)
    }
    
    private func fetchUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error {
                print("유저 정보 불러오기 실패:", error.localizedDescription)
                return
            }
            
            let data = snap?.data() ?? [:]
            self.userData = data
            
            DispatchQueue.main.async {
                self.nameLabel.text = "이름: \(data["name"] as? String ?? "사용자")"
                self.emailLabel.text = "이메일: \(data["email"] as? String ?? "-")"
                self.phoneLabel.text = "전화번호: \(data["phone"] as? String ?? "-")"
            }
        }
    }
    
    private func showLoginRequiredView() {
        let label = UILabel()
        label.text = "로그인이 필요합니다"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 1
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }
}
