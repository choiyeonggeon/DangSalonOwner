//
//  Notice.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import Foundation
import FirebaseFirestore

struct Notice {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    
    init?(doc: DocumentSnapshot) {
        guard let data = doc.data(),
              let title = data["title"] as? String,
              let content = data["content"] as? String,
              let ts = data["createdAt"] as? Timestamp else { return nil }
        
        self.id = doc.documentID
        self.title = title
        self.content = content
        self.createdAt = ts.dateValue()
    }
}
