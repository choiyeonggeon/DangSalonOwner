//
//  OwnerInquiryWriteVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class OwnerInquiryWriteVC: UIViewController {
    
    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "제목을 입력하세요."
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.layer.cornerRadius = 10
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle( "문의 제출", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }()
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "문의 작성"
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleField)
        view.addSubview(contentTextView)
        view.addSubview(submitButton)
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        submitButton.addTarget(self, action: #selector(submitInquiry), for: .touchUpInside)
    }
    
    @objc private func submitInquiry() {
        guard let ownerId = Auth.auth().currentUser?.uid else { return }
        guard let title = titleField.text, !title.isEmpty else { return }
        let content = contentTextView.text ?? ""
        
        db.collection("admins")
            .document(ownerId)
            .collection("inquiries")
            .addDocument(data: [
                "title": title,
                "content": content,
                "createdAt": Timestamp(date: Date()),
                "answer": "",
                "answeredAt": NSNull()
            ]) { _ in
                self.navigationController?.popViewController(animated: true)
            }
    }
}
