//
//  AdminApprovedListVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/6/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class AdminApprovedListVC: UIViewController {
    
    private let tableView = UITableView()
    private var pendingOwners: [OwnerUser] = []
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "입점 승인 관리"
        setupTableView()
        fetchPendingOwners()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.register(AdminOwnerCell.self, forCellReuseIdentifier: "AdminOwnerCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
    }
    
    private func fetchPendingOwners() {
        
        db.collection("owners")
            .whereField("isApproved", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("🚨 승인 대기 사장님 불러오기 실패:", error.localizedDescription)
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                
                self.pendingOwners = docs.compactMap { OwnerUser(document: $0) }
                self.tableView.reloadData()
            }
    }
}

// MARK: - TableView
extension AdminApprovedListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pendingOwners.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let owner = pendingOwners[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AdminOwnerCell",
            for: indexPath
        ) as! AdminOwnerCell
        
        cell.configure(with: owner)
        
        // 승인, 거절 버튼 콜백
        cell.onApprove = { [weak self] in
            self?.approveOwner(owner)
        }
        cell.onReject = { [weak self] in
            self?.rejectOwner(owner)
        }
        
        return cell
    }
}

// MARK: - Firestore Actions
extension AdminApprovedListVC {
    
    private func approveOwner(_ owner: OwnerUser) {
        db.collection("owners").document(owner.id).updateData([
            "isApproved": true
        ]) { error in
            if let error = error {
                print("🚨 승인 실패:", error.localizedDescription)
                return
            }
            print("✅ 승인 완료")
        }
    }
    
    private func rejectOwner(_ owner: OwnerUser) {
        db.collection("owners").document(owner.id).delete { error in
            if let error = error {
                print("🚨 거절 실패:", error.localizedDescription)
                return
            }
            print("❌ 삭제(거절) 완료")
        }
    }
}
