//
//  CustomerInquiry.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

// CustomerInquiry.swift (새 파일)
import Foundation
import FirebaseFirestore

// 답변 정보 구조체
struct InquiryAnswer: Codable {
    let content: String
    let answeredAt: Timestamp
    let answeredBy: String // 사장님 UID
}

// 고객 문의 정보 구조체
struct CustomerInquiry: Codable {
    // Firestore 문서 ID는 보통 Codable에 포함하지 않지만, 구분용으로 추가
    let id: String
    
    // 고객 정보
    let userId: String
    let userEmail: String // 테이블 뷰 셀 표시용
    let shopName: String
    
    // 문의 내용
    let title: String
    let content: String
    let createdAt: Date
    let isAnswered: Bool
    
    // 답변 정보 (옵셔널)
    let answer: InquiryAnswer?
    
    // MARK: - Initializer for Firestore Document
    init?(document: DocumentSnapshot) {
        // Document ID 설정
        guard let data = document.data() else { return nil }
        self.id = document.documentID
        
        // 필수 필드 디코딩
        self.userId = data["userId"] as? String ?? "N/A"
        self.userEmail = data["email"] as? String ?? "N/A" // 가정: 문의 시 이메일 저장
        self.shopName = data["shopName"] as? String ?? "샵 이름 없음"
        self.title = data["title"] as? String ?? "제목 없음"
        self.content = data["content"] as? String ?? "내용 없음"
        self.isAnswered = data["isAnswered"] as? Bool ?? false
        
        // MARK: ⭐ Timestamp → Date 변환
        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        // 답변 필드 디코딩 (JSON/Dictionary 형태)
        if let answerData = data["answer"] as? [String: Any],
           let content = answerData["content"] as? String,
           let answeredAt = answerData["answeredAt"] as? Timestamp,
           let answeredBy = answerData["answeredBy"] as? String {
            
            self.answer = InquiryAnswer(
                content: content,
                answeredAt: answeredAt,
                answeredBy: answeredBy
            )
        } else {
            self.answer = nil
        }
    }
}
