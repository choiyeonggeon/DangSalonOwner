//  ReviewCell.swift
//  DangSalonOwner
//

import UIKit
import SnapKit

final class ReviewCell: UITableViewCell {
    
    private let container = UIView()
    
    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let reviewText = UILabel()
    
    // ⭐ 리뷰 이미지 표시용 ScrollView
    private let imageScrollView = UIScrollView()
    private var imageViews: [UIImageView] = []
    
    private let replyTitleLabel = UILabel()
    private let replyBackground = UIView()
    private let replyTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    
    var replyHandler: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - UI 구성
    private func setupUI() {
        contentView.backgroundColor = .systemGroupedBackground
        
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        
        // 닉네임
        nameLabel.font = .boldSystemFont(ofSize: 16)
        
        // 별점
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textColor = .systemYellow
        
        // 리뷰 내용
        reviewText.font = .systemFont(ofSize: 15)
        reviewText.numberOfLines = 0
        
        // ⭐ 이미지 ScrollView 설정
        imageScrollView.showsHorizontalScrollIndicator = false
        
        // 사장님 답글
        replyTitleLabel.text = "사장님 답글"
        replyTitleLabel.font = .boldSystemFont(ofSize: 15)
        replyTitleLabel.textColor = .label
        
        replyBackground.backgroundColor = UIColor.systemGray6
        replyBackground.layer.cornerRadius = 10
        
        replyTextView.font = .systemFont(ofSize: 15)
        replyTextView.backgroundColor = .clear
        replyTextView.isScrollEnabled = false
        replyTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        
        replyTextView.text = "답글을 입력해주세요."
        replyTextView.textColor = .systemGray3
        replyTextView.delegate = self
        
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        saveButton.addTarget(self, action: #selector(saveReply), for: .touchUpInside)
        
        contentView.addSubview(container)
        [
            nameLabel, ratingLabel, reviewText,
            imageScrollView, replyTitleLabel,
            replyBackground, saveButton
        ].forEach { container.addSubview($0) }
        
        replyBackground.addSubview(replyTextView)
        
        // MARK: - Layout
        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(6)
            $0.centerY.equalTo(nameLabel)
        }
        
        reviewText.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        imageScrollView.snp.makeConstraints {
            $0.top.equalTo(reviewText.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(80)   // 썸네일 높이
        }
        
        replyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(imageScrollView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)
        }
        
        replyBackground.snp.makeConstraints {
            $0.top.equalTo(replyTitleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        replyTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(60)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(replyBackground.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Configure
    func configure(with review: Review) {
        nameLabel.text = review.nickname
        ratingLabel.text = "⭐️ \(review.rating)"
        reviewText.text = review.content
        
        // ⭐ 리뷰 이미지 표시
        loadImages(urls: review.imageURLs)
        
        // 답글 표시
        if let reply = review.reply, !reply.isEmpty {
            replyTextView.text = reply
            replyTextView.textColor = .label
            replyBackground.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        } else {
            replyTextView.text = "답글을 입력해주세요."
            replyTextView.textColor = .systemGray3
            replyBackground.backgroundColor = UIColor.systemGray6
        }
    }
    
    // MARK: - 이미지 UI 생성
    private func loadImages(urls: [String]) {
        imageScrollView.subviews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        var x: CGFloat = 0
        
        for urlString in urls {
            let iv = UIImageView()
            iv.frame = CGRect(x: x, y: 0, width: 80, height: 80)
            iv.backgroundColor = .systemGray5
            iv.layer.cornerRadius = 8
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFill
            
            // 이미지 로드
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            iv.image = img
                        }
                    }
                }.resume()
            }
            
            imageScrollView.addSubview(iv)
            imageViews.append(iv)
            
            x += 90
        }
        
        imageScrollView.contentSize = CGSize(width: x, height: 80)
    }
    
    @objc private func saveReply() {
        let text = replyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text != "답글을 입력해주세요." else { return }
        replyHandler?(text)
    }
}

// MARK: - Placeholder 처리
extension ReviewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray3 {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            textView.text = "답글을 입력해주세요."
            textView.textColor = .systemGray3
        }
    }
}
