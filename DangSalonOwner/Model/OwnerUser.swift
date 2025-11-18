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
    let ownerName: String
    let shopName: String
    let businessNumber: String
    let isApproved: Bool
    
    init?(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        self.id = document.documentID
        self.ownerName = data["ownerName"] as? String ?? "이름 없음"
        self.shopName = data["shopName"] as? String ?? "가게명 없음"
        self.businessNumber = data["businessNumber"] as? String ?? ""
        self.isApproved = data["isApproved"] as? Bool ?? false
    }
}
