//
//  OwnerInquiryDetailVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import UIKit
import SnapKit

final class OwnerInquiryDetailVC: UIViewController {
    
    private let inquiry: OwnerInquiry
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let answerTitleLabel = UILabel()
    private let answerLabel = UILabel()
    
    init(inquiry: OwnerInquiry) {
        self.inquiry = inquiry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "문의 상세"
        
        setupUI()
        fillData()
    }
    
    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 20)
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        
        answerTitleLabel.text = "관리자 답변"
        answerLabel.numberOfLines = 0
        answerLabel.textColor = .systemGray
        
        [titleLabel, contentLabel, answerTitleLabel, answerLabel]
            .forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        answerTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(20)
        }
        
        answerLabel.snp.makeConstraints {
            $0.top.equalTo(answerTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func fillData() {
        titleLabel.text = inquiry.title
        contentLabel.text = inquiry.content
        
        if let answer = inquiry.answer, !answer.isEmpty {
            answerLabel.text = answer
            answerLabel.textColor = .label
        } else {
            answerLabel.text = "아직 답변이 등록되지 않았습니다."
        }
    }
}
