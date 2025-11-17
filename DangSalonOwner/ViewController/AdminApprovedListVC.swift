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
    private let pendingOwners: [OwnerUser] = []
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
    }
    
    private func fetchPendingOwners() {
        
    }
}
