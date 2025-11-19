//
//  NoticeWriteVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class NoticeWriteVC: UIViewController {
    
    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "제목을 입력하세요."
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.layer.cornerRadius = 10
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("등록하기", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "공지사항 작성"
        
        setupLayout()
        submitButton.addTarget(self, action: #selector(submitNotice), for: .touchUpInside)
    }
    
    private func setupLayout() {
        [titleField, contentTextView, submitButton].forEach { view.addSubview($0) }
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
    
    @objc private func submitNotice() {
        guard let title = titleField.text, !title.isEmpty else {
            showAlert("제목을 입력해주세요.")
            return
        }
        
        let content = contentTextView.text ?? ""
        
        let data: [String: Any] = [
            "title": title,
            "content": content,
            "createdAt": Timestamp()
        ]
        
        db.collection("notices").addDocument(data: data) { error in
            if let error = error {
                self.showAlert("등록 실패: \(error.localizedDescription)")
                return
            }
            
            self.showAlert("공지사항이 등록되었습니다.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showAlert(_ msg: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in completion?() }))
        present(ac, animated: true)
    }
}
