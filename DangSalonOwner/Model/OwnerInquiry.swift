//
//  OwnerInquiry.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import Foundation
import FirebaseFirestore

struct OwnerInquiry {
    let id: String
    let title: String
    let content: String
    let createdAt: Timestamp
    let answer: String?
    let answeredAt: Timestamp?
    
    init?(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        guard let title = data["title"] as? String,
              let content = data["content"] as? String,
              let createdAt = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        self.id = document.documentID
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.answer = data["answer"] as? String
        self.answeredAt = data["answeredAt"] as? Timestamp
    }
}
