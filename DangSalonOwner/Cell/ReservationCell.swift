//
//  ReservationCell.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/7/25.
//

import UIKit
import SnapKit

final class ReservationCell: UITableViewCell {
    
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let statusBadge = UILabel()
    private let dateIcon = UIImageView(image: UIImage(systemName: "calendar"))
    private let dateLabel = UILabel()
    private let menuLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // MARK: - Card Style
        contentView.addSubview(cardView)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        // MARK: - Texts
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        menuLabel.font = UIFont.systemFont(ofSize: 15)
        menuLabel.textColor = .secondaryLabel
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        
        priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        priceLabel.textColor = .systemGray
        
        // MARK: - Status Badge
        statusBadge.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        statusBadge.textColor = .white
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 8
        statusBadge.layer.masksToBounds = true
        statusBadge.setContentHuggingPriority(.required, for: .horizontal)
        statusBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dateIcon.tintColor = .systemGray2
        dateIcon.contentMode = .scaleAspectFit
        dateIcon.snp.makeConstraints { $0.size.equalTo(16) }
        
        // MARK: - Layout Stack
        cardView.addSubview(nameLabel)
        cardView.addSubview(statusBadge)
        cardView.addSubview(dateIcon)
        cardView.addSubview(dateLabel)
        cardView.addSubview(menuLabel)
        cardView.addSubview(priceLabel)
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(18)
        }
        
        statusBadge.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(18)
            $0.height.equalTo(24)
            $0.width.greaterThanOrEqualTo(60)
        }
        
        dateIcon.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(18)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateIcon)
            $0.leading.equalTo(dateIcon.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview().inset(18)
        }
        
        menuLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.lessThanOrEqualTo(priceLabel.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        priceLabel.snp.makeConstraints {
            $0.centerY.equalTo(menuLabel)
            $0.trailing.equalToSuperview().inset(18)
        }
    }
    
    // MARK: - Data Binding
    func configure(with res: Reservation) {
        nameLabel.text = res.userName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateLabel.text = formatter.string(from: res.timestamp)
        
        menuLabel.text = res.menuName
        priceLabel.text = res.priceString
        
        // 상태에 따라 뱃지 색상 및 텍스트 설정
        switch res.status {
        case "예약 요청", "pending":
            statusBadge.text = "예약 요청"
            statusBadge.backgroundColor = UIColor.systemBlue
        case "확정", "confirmed":
            statusBadge.text = "예약 확정"
            statusBadge.backgroundColor = UIColor.systemIndigo
        case "완료", "completed":
            statusBadge.text = "이용 완료"
            statusBadge.backgroundColor = UIColor.systemGreen
        case "취소", "cancelled":
            statusBadge.text = "취소됨"
            statusBadge.backgroundColor = UIColor.systemRed
        default:
            statusBadge.text = res.status
            statusBadge.backgroundColor = UIColor.systemGray
        }
    }
}
