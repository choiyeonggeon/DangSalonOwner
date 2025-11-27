//
//  InquiryCell.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/25/25.
//

import UIKit

final class InquiryCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .gray
        contentLabel.numberOfLines = 2
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with inquiry: CustomerInquiry) {
        titleLabel.text = inquiry.title
        contentLabel.text = inquiry.content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = formatter.string(from: inquiry.createdAt)
    }
}
