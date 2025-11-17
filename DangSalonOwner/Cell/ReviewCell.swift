//
//  ReviewCell.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import UIKit
import SnapKit

final class ReviewCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let textLabelView = UILabel()
    private let replyField = UITextField()
    private let replyButton = UIButton(type: .system)
    
    var replyHandler: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - UI 구성
    private func setupUI() {
        nameLabel.font = .boldSystemFont(ofSize: 16)
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textColor = .systemYellow
        
        textLabelView.numberOfLines = 0
        textLabelView.font = .systemFont(ofSize: 15)
        
        replyField.placeholder = "사장님 답글 작성"
        replyField.borderStyle = .roundedRect
        
        replyButton.setTitle("저장", for: .normal)
        replyButton.addTarget(self, action: #selector(saveReply), for: .touchUpInside)
        
        [nameLabel, ratingLabel, textLabelView, replyField, replyButton].forEach {
            contentView.addSubview($0)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(12)
        }
        ratingLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nameLabel)
        }
        textLabelView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        replyField.snp.makeConstraints {
            $0.top.equalTo(textLabelView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(38)
        }
        replyButton.snp.makeConstraints {
            $0.top.equalTo(replyField.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - 리뷰 표시
    func configure(with review: Review) {
        nameLabel.text = review.nickname
        ratingLabel.text = "⭐️ \(review.rating)"
        textLabelView.text = review.content
        replyField.text = review.reply
    }
    
    // MARK: - 답글 저장
    @objc private func saveReply() {
        guard let text = replyField.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        replyHandler?(text)
    }
}
