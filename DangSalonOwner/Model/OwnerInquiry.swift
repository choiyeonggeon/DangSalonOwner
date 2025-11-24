//
//  OwnerInquiry.swift
//  DangSalonOwner
//

import Foundation
import FirebaseFirestore

struct OwnerInquiry {
    let id: String
    let title: String
    let content: String
    let createdAt: Timestamp
    let answer: String?
    let answeredAt: Timestamp?  // null 가능
    let senderId: String
    let receiverId: String
    
    init?(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        guard let title = data["title"] as? String,
              let content = data["content"] as? String,
              let createdAt = data["createdAt"] as? Timestamp,
              let answer = data["answer"] as? String,
              let senderId = data["senderId"] as? String,
              let receiverId = data["receiverId"] as? String
        else { return nil }
        
        self.id = document.documentID
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.answer = answer
        self.answeredAt = data["answeredAt"] as? Timestamp
        self.senderId = senderId
        self.receiverId = receiverId
    }
}
