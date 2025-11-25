//
//  CustomerInquiryWriteVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/25/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class CustomerInquiryWriteVC: UIViewController {
    
    private let titleField = UITextField()
    private let contentTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "문의 작성"
        setupUI()
    }
    
    private func setupUI() {
        titleField.placeholder = "제목"
        titleField.borderStyle = .roundedRect
        
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.systemGray5.cgColor
        contentTextView.layer.cornerRadius = 8
        
        submitButton.setTitle("등록", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        [titleField, contentTextView, submitButton].forEach { view.addSubview($0) }
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
    
    //
    //  CustomerInquiryWriteVC.swift (수정)
    //
    
    // ... (생략) ...
    
    // MARK: - Shop Name 비동기 가져오기 함수 (추가)
    private func fetchShopName(for userId: String) async throws -> String {
        // ⭐️ Firestore의 'shops' 컬렉션에서 사장님 UID가 일치하는 문서를 찾습니다.
        let snapshot = try await db.collection("shops")
            .whereField("user", isEqualTo: userId) // ⭐️ 'shops' 문서의 'user' 필드가 사장님 UID와 일치하는지 확인
            .getDocuments()
        
        // 첫 번째 샵 문서를 가져옵니다. (사장님 한 명당 샵이 하나라고 가정)
        guard let shopDocument = snapshot.documents.first,
              let shopName = shopDocument.data()["name"] as? String // ⭐️ 샵 문서의 'name' 필드 가져오기
        else {
            // 샵 정보를 찾지 못하면 기본값 반환
            return "알 수 없는 샵"
        }
        
        return shopName
    }
    
    @objc private func submit() {
        guard let user = Auth.auth().currentUser,
              let title = titleField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else { return }
        
        // MARK: - 비동기 처리 시작
        Task {
            do {
                // 1. 샵 이름 비동기로 가져오기
                let shopName = try await fetchShopName(for: user.uid)
                
                // 2. 문의 등록 데이터 준비
                let data: [String: Any] = [
                    "title": title,
                    "content": content,
                    "userId": user.uid,
                    "email": user.email ?? "",
                    "shopName": shopName, // ⭐️ 가져온 샵 이름 추가
                    "createdAt": Timestamp(date: Date()),
                    "isAnswered": false // (추가: 문의 모델에 맞춰 필드 기본값 설정)
                ]
                
                // 3. Firestore에 문서 추가
                try await db.collection("admins")
                    .document(user.uid)
                    .collection("inquiries")
                    .addDocument(data: data)
                
                // 4. 성공 시 화면 닫기
                self.navigationController?.popViewController(animated: true)
                
            } catch {
                // 실패 시 오류 처리
                print("문의 등록/샵 이름 가져오기 실패:", error.localizedDescription)
                // TODO: 사용자에게 오류 알림 (Alert)
            }
        }
    }
}
