//
//  AdminOwnerCell.swift
//

import UIKit
import SnapKit

final class AdminOwnerCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let approveButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    
    var onApprove: (() -> Void)?
    var onReject: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        
        approveButton.setTitle("승인", for: .normal)
        approveButton.backgroundColor = .systemBlue
        approveButton.tintColor = .white
        approveButton.layer.cornerRadius = 8
        
        rejectButton.setTitle("삭제", for: .normal)
        rejectButton.backgroundColor = .systemRed
        rejectButton.tintColor = .white
        rejectButton.layer.cornerRadius = 8
        
        approveButton.addTarget(self, action: #selector(tapApprove), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(tapReject), for: .touchUpInside)
        
        [nameLabel, emailLabel, approveButton, rejectButton].forEach {
            contentView.addSubview($0)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
        }
        
        approveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
            $0.height.equalTo(34)
        }
        
        rejectButton.snp.makeConstraints {
            $0.trailing.equalTo(approveButton.snp.leading).offset(-8)
            $0.centerY.equalTo(approveButton)
            $0.width.equalTo(60)
            $0.height.equalTo(34)
        }
    }
    
    @objc private func tapApprove() { onApprove?() }
    @objc private func tapReject() { onReject?() }
    
    func configure(with owner: OwnerUser) {
        nameLabel.text = owner.ownerName
        emailLabel.text = owner.email
    }
    
    func setApprovedUI() {
        approveButton.isHidden = true
    }
}
