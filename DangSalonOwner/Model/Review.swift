//
//  Review.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import Foundation
import FirebaseFirestore

struct Review {
    let id: String
    let authorId: String?
    let nickname: String
    let content: String
    let rating: Int
    let timestamp: Timestamp
    let reply: String?
    let imageURLs: [String]

    init?(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        guard let nickname = data["nickname"] as? String,
              let content = data["content"] as? String,
              let rating = data["rating"] as? Int,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        
        self.id = document.documentID
        self.authorId = data["authorId"] as? String
        self.nickname = nickname
        self.content = content
        self.rating = rating
        self.timestamp = timestamp
        self.reply = data["reply"] as? String
        self.imageURLs = data["imageURLs"] as? [String] ?? []
    }
}
