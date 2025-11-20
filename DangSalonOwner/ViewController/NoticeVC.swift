//
//  NoticeVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class NoticeVC: UIViewController {
    
    private let tableView = UITableView()
    private var notices: [Notice] = []
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "공지사항"
        
        setupTableView()
        fetchNotices()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.register(NoticeCell.self, forCellReuseIdentifier: "NoticeCell")
    }
    
    // 🔥 “사장님 전용” 공지사항 컬렉션으로 변경
    private func fetchNotices() {
        db.collection("ownerNotices")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("사장 공지사항 불러오기 오류:", error.localizedDescription)
                    return
                }
                guard let docs = snapshot?.documents else { return }
                
                // 🔥 Notice 모델에 맞게 매핑
                self.notices = docs.compactMap { Notice(doc: $0) }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

extension NoticeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NoticeCell",
            for: indexPath
        ) as? NoticeCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: notices[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notice = notices[indexPath.row]
        let vc = NoticeDetailVC(notice: notice)
        navigationController?.pushViewController(vc, animated: true)
    }
}
