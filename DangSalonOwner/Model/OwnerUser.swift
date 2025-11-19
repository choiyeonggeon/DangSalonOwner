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
    let email: String
    let isApproved: Bool
    let createdAt: Date?
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        id = document.documentID
        ownerName = data["ownerName"] as? String ?? ""
        email = data["email"] as? String ?? ""
        isApproved = data["isApproved"] as? Bool ?? false
        if let ts = data["createdAt"] as? Timestamp {
            createdAt = ts.dateValue()
        } else {
            createdAt = nil
        }
    }
}
