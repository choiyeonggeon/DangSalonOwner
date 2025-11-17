//
//  AdminOwnerCell.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/6/25.
//

import UIKit
import SnapKit

final class AdminOwnerCell: UITableViewCell {
    
    private let emailLabel = UILabel()
    private let dateLabel = UILabel()
    private let approveButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    
    var onApprove: (() -> Void)?
    var onReject: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        emailLabel.font = .systemFont(ofSize: 15, weight: .medium)
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        
        approveButton.setTitle("승인", for: .normal)
        approveButton.tintColor = .white
        approveButton.backgroundColor = .systemBlue
        approveButton.layer.cornerRadius = 8
        approveButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        approveButton.addTarget(self, action: #selector(didTapApprove), for: .touchUpInside)
        
        rejectButton.setTitle("거절", for: .normal)
        rejectButton.tintColor = .white
        rejectButton.backgroundColor = .systemRed
        rejectButton.layer.cornerRadius = 8
        rejectButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        rejectButton.addTarget(self, action: #selector(didTapReject), for: .touchUpInside)
        
        let hStack = UIStackView(arrangedSubviews: [approveButton, rejectButton])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.distribution = .fillEqually
        
        [emailLabel, dateLabel, hStack].forEach { contentView.addSubview($0) }
        
        emailLabel.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(12) }
        dateLabel.snp.makeConstraints { $0.top.equalTo(emailLabel.snp.bottom).offset(4); $0.leading.equalTo(emailLabel) }
        hStack.snp.makeConstraints { $0.trailing.equalToSuperview().inset(12); $0.centerY.equalToSuperview(); $0.width.equalTo(120) }
    }
    
    func configure(with owner: OwnerUser) {
        emailLabel.text = owner.email
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateLabel.text = formmater.string(from: owner.createdAt)
    }
    @objc private func didTapApprove() { onApprove?() }
    @objc private func didTapReject() { onReject?() }
}
