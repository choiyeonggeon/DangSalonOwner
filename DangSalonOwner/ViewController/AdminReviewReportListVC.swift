//
//  AdminReviewReportListVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/18/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class AdminReviewReportListVC: UIViewController {
    
    private let tableView = UITableView()
    private var reports: [ReviewReport] = []
    private let db = Firestore.firestore()
    
    private let emptyLabel: UILabel = {
        let lb = UILabel()
        lb.text = "아직 신고된 리뷰가 없습니다."
        lb.textColor = .systemGray
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.isHidden = true
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "리뷰 신고 목록"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        fetchReports()
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
    
    private func fetchReports() {
        db.collection("reviewReports")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, err in
                if let err = err {
                    print("리뷰 신고 불러오기 실패:", err.localizedDescription)
                    return
                }
                guard let docs = snap?.documents else { return }
                
                self.reports = docs.compactMap { ReviewReport(document: $0) }
                self.tableView.reloadData()
                self.emptyLabel.isHidden = !self.reports.isEmpty
            }
    }
}

extension AdminReviewReportListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        reports.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let report = reports[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text =
        """
        리뷰 ID: \(report.reviewId)
        사유: \(report.reason)
        """
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
