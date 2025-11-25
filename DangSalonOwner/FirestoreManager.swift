//
//  FirestoreManager.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/25/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AdminInquiryService {
    private let db = Firestore.firestore()
    
    var adminId: String {
        return Auth.auth().currentUser?.uid ?? "unknownAdmin"
    }
    
    /// 고객 문의 목록 실시간 불러오기
    func listenInquiries(completion: @escaping ([CustomerInquiry]) -> Void) {
        db.collection("admins")
            .document(adminId)
            .collection("inquiries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ 문의 목록 불러오기 실패:", error.localizedDescription)
                    completion([])
                    return
                }
                
                let inquiries = snapshot?.documents.compactMap { CustomerInquiry(document: $0) } ?? []
                completion(inquiries)
            }
    }
    
    
    /// 단일 문의 불러오기
    func fetchInquiry(id: String, completion: @escaping (CustomerInquiry?) -> Void) {
        db.collection("admins")
            .document(adminId)
            .collection("inquiries")
            .document(id)
            .getDocument { doc, error in
                if let error = error {
                    print("❌ 문의 상세 불러오기 실패:", error.localizedDescription)
                    completion(nil)
                    return
                }
                completion(doc.flatMap { CustomerInquiry(document: $0) })
            }
    }
    
    
    /// 답변 저장
    func submitAnswer(inquiryId: String, text: String, completion: @escaping (Bool) -> Void) {
        let update: [String: Any] = [
            "answer": text,
            "answeredAt": Timestamp(date: Date())
        ]
        
        db.collection("admins")
            .document(adminId)
            .collection("inquiries")
            .document(inquiryId)
            .updateData(update) { error in
                if let error = error {
                    print("❌ 답변 저장 실패:", error.localizedDescription)
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
}
