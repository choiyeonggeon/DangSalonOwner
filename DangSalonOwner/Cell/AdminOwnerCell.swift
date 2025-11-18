//
//  AdminOwnerCell.swift
//

import UIKit
import SnapKit

final class AdminOwnerCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let shopLabel = UILabel()
    private let approveButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    
    // 콜백
    var onApprove: (() -> Void)?
    var onReject: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        nameLabel.font = .boldSystemFont(ofSize: 16)
        shopLabel.font = .systemFont(ofSize: 14)
        shopLabel.textColor = .gray
        
        approveButton.setTitle("승인", for: .normal)
        approveButton.backgroundColor = .systemGreen
        approveButton.tintColor = .white
        approveButton.layer.cornerRadius = 8
        
        rejectButton.setTitle("거절", for: .normal)
        rejectButton.backgroundColor = .systemRed
        rejectButton.tintColor = .white
        rejectButton.layer.cornerRadius = 8
        
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(shopLabel)
        contentView.addSubview(approveButton)
        contentView.addSubview(rejectButton)
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(12)
        }
        
        shopLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        approveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(32)
        }
        
        rejectButton.snp.makeConstraints {
            $0.trailing.equalTo(approveButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(32)
        }
    }
    
    func configure(with owner: OwnerUser) {
        nameLabel.text = owner.ownerName
        shopLabel.text = owner.shopName
    }
    
    @objc private func approveTapped() {
        onApprove?()
    }
    
    @objc private func rejectTapped() {
        onReject?()
    }
}
