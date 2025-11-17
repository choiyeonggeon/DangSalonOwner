//
//  Reservation.swift
//  DangSalon / DangDangSalon (공용)
//
//  Created by 최영건 on 11/12/25.
//

import Foundation
import FirebaseFirestore

struct Reservation {
    let id: String
    let userId: String
    let userName: String
    let shopId: String
    let shopName: String
    let ownerId: String
    let menus: [String]        // ✅ 여러 메뉴 선택 가능
    let totalPrice: Int        // ✅ 총 가격
    let date: Date
    let time: String
    var status: String
    let createdAt: Date        // ✅ 예약 생성일
    let phone: String
    let request: String
    var reviewWritten: Bool    // ✅ 리뷰 작성 여부

    // ✅ 과거 데이터 호환용 (timestamp, price, menuName)
    var timestamp: Date { createdAt }
    var price: Int { totalPrice }
    var menuName: String { menus.joined(separator: ", ") }

    // ✅ UI용 포맷터
    var priceString: String {
        "\(NumberFormatter.localizedString(from: NSNumber(value: totalPrice), number: .decimal))원"
    }
    var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }

    // MARK: - Firestore → 모델 변환
    init?(document: DocumentSnapshot) {
        let d = document.data() ?? [:]
        self.id         = document.documentID
        self.userId     = d["userId"] as? String ?? ""
        self.userName   = d["userName"] as? String ?? d["name"] as? String ?? ""
        self.shopId     = d["shopId"] as? String ?? ""
        self.shopName   = d["shopName"] as? String ?? ""
        self.ownerId    = d["ownerId"] as? String ?? ""
        self.menus      = d["menus"] as? [String] ?? (d["menuName"] != nil ? [d["menuName"] as! String] : [])
        self.totalPrice = d["totalPrice"] as? Int ?? (d["price"] as? Int ?? 0)
        self.date       = (d["date"] as? Timestamp)?.dateValue() ?? Date()
        self.time       = d["time"] as? String ?? "-"
        self.status     = d["status"] as? String ?? "예약 요청"
        self.createdAt  = (d["createdAt"] as? Timestamp)?.dateValue()
                        ?? (d["timestamp"] as? Timestamp)?.dateValue()
                        ?? Date()
        self.phone      = d["phone"] as? String ?? ""
        self.request    = d["request"] as? String ?? ""
        self.reviewWritten = d["reviewWritten"] as? Bool ?? false
    }
}
