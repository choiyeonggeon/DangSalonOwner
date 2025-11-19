//
//  AdminApprovedOwnersVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/19/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class AdminApprovedOwnersVC: UIViewController {
    
    private let tableView = UITableView()
    private var owners: [OwnerUser] = []
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "승인된 사장님 목록"
        
        setupTableView()
        fetchApprovedOwners()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tableView.register(AdminOwnerCell.self, forCellReuseIdentifier: "AdminOwnerCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
    }
    
    private func fetchApprovedOwners() {
        db.collection("owners")
            .whereField("isApproved", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                
                if let err = err {
                    print("🚨 승인된 사장님 불러오기 실패:", err.localizedDescription)
                    return
                }
                self.owners = snap?.documents.compactMap { OwnerUser(document: $0) } ?? []
                self.tableView.reloadData()
            }
    }
}

extension AdminApprovedOwnersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return owners.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let owner = owners[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AdminOwnerCell",
            for: indexPath) as! AdminOwnerCell
        
        cell.configure(with: owner)
        
        cell.onReject = { [weak self] in
            self?.removeOwner(owner)
        }
        
        cell.onApprove = nil
        cell.setApprovedUI()
        
        return cell
    }
}

extension AdminApprovedOwnersVC {
    
    private func removeOwner(_ owner: OwnerUser) {
        db.collection("owners").document(owner.id).delete { err in
            if let err = err {
                print("🚨 삭제 실패:", err.localizedDescription)
                return
            }
            print("❌ 승인된 사장님 삭제 완료")
        }
    }
}

