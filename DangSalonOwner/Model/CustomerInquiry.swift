//
//  CustomerInquiry.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import Foundation
import FirebaseFirestore

struct CustomerInquiry {
    let id: String
    let userId: String
    let title: String
    let content: String
    let userEmail: String
    let createdAt: Date
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let title = data["title"] as? String,
              let content = data["content"] as? String,
              let userId = data["userId"] as? String,
              let userEmail = data["email"] as? String,
              let ts = data["createdAt"] as? Timestamp else { return nil }
        
        self.id = document.documentID
        self.userId = userId
        self.title = title
        self.content = content
        self.userEmail = userEmail
        self.createdAt = ts.dateValue()
    }
}
