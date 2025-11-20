//
//  NoticeCell.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/21/25.
//

import UIKit
import SnapKit

final class NoticeCell: UITableViewCell {
    
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // 카드 UI
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        // 제목
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 2
        
        // 날짜
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        
        [titleLabel, dateLabel].forEach { cardView.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(with notice: Notice) {
        titleLabel.text = notice.title
        
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        dateLabel.text = fmt.string(from: notice.createdAt)
    }
}
