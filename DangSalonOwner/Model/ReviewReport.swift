//
//  ReviewReport.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import Foundation
import FirebaseFirestore

struct ReviewReport {
    let id: String
    let reviewId: String
    let shopId: String
    let reason: String
    let createdAt: Date
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let reviewId = data["reviewId"] as? String,
              let shopId = data["shopId"] as? String,
              let reason = data["reason"] as? String,
              let ts = data["createdAt"] as? Timestamp else { return nil }
        
        self.id = document.documentID
        self.reviewId = reviewId
        self.shopId = shopId
        self.reason = reason
        self.createdAt = ts.dateValue()
    }
}
