//
//  NoticeDetailVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import UIKit
import SnapKit

final class NoticeDetailVC: UIViewController {
    
    private let notice: Notice
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    
    init(notice: Notice) {
        self.notice = notice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "공지사항"
        setupUI()
    }
    
    private func setupUI() {
        [titleLabel, dateLabel, contentLabel].forEach { view.addSubview($0) }
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0
        titleLabel.text = notice.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = formatter.string(from: notice.createdAt)
        dateLabel.textColor = .secondaryLabel
        
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        contentLabel.text = notice.content
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(18)
            $0.left.right.equalToSuperview().inset(20)
        }
    }
}
