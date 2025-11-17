//
//  OwnerUser.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/6/25.
//

import Foundation
import FirebaseFirestore

struct OwnerUser {
    let id: String
    let email: String
    let createdAt: Date
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let email = data["email"] as? String,
              let timestamp = data["createdAt"] as? Timestamp else { return nil }
        self.id = document.documentID
        self.email = email
        self.createdAt = timestamp.dateValue()
    }
}
