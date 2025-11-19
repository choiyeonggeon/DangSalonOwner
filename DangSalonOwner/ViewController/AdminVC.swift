//
//  AdminVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import UIKit
import SnapKit

final class AdminVC: UIViewController {
    
    private let tableView = UITableView()
    
    private let menuItems = [
        "공지사항 작성",
        "리뷰 신고 관리",
        "예약 신고 관리",
        "입점 승인 대기",
        "승인된 사장님 목록",
        "고객센터(관리자용)"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "관리자 메뉴"
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50
    }
}

extension AdminVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]   // 🔥 글자 나오게 추가
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let item = menuItems[indexPath.row]
        
        switch item {
        case "공지사항 작성":
            navigationController?.pushViewController(NoticeWriteVC(), animated: true)
            
        case "리뷰 신고 관리":
            navigationController?.pushViewController(AdminReviewReportListVC(), animated: true)
            
        case "예약 신고 관리":
            let alert = UIAlertController(
                title: "준비 중",
                message: "예약 신고 관리 기능은 곧 추가됩니다!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            
        case "입점 승인 대기":   // 🔥 오타 수정
            navigationController?.pushViewController(AdminApprovedListVC(), animated: true)
            
        case "승인된 사장님 목록":
            navigationController?.pushViewController(AdminApprovedOwnersVC(), animated: true)
            
        case "고객센터(관리자용)":
            navigationController?.pushViewController(AdminCustomerServiceListVC(), animated: true)
            
        default: break
        }
    }
}
