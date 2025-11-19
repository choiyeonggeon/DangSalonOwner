//
//  AdminCustomerServiceListVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/18/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class AdminCustomerServiceListVC: UIViewController {
    
    private let tableView = UITableView()
    private var inquiries: [CustomerInquiry] = []
    private let db = Firestore.firestore()
    
    private let emptyLabel: UILabel = {
        let lb = UILabel()
        lb.text = "아직 접수된 고객 문의가 없습니다."
        lb.textColor = .systemGray
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.isHidden = true
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "고객센터(관리자)"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        fetchInquiries()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.rowHeight = 70
    }
    
    private func fetchInquiries() {
        db.collectionGroup("customerInquiries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err = err {
                    print("고객 문의 불러오기 실패:", err.localizedDescription)
                    return
                }
                
                guard let docs = snap?.documents else { return }
                self.inquiries = docs.compactMap { CustomerInquiry(document: $0) }
                
                self.tableView.reloadData()
                self.emptyLabel.isHidden = !self.inquiries.isEmpty
            }
    }
}

extension AdminCustomerServiceListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        inquiries.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let inquiry = inquiries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text =
        """
        \(inquiry.title)
        \(inquiry.userEmail)
        """
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
