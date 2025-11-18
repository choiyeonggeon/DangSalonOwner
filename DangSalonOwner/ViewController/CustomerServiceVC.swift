//
//  CustomerServiceVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/6/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class CustomerServiceVC: UIViewController {
    
    private let tableView = UITableView()
    
    private let noDataLabel: UILabel = {
        let lb = UILabel()
        lb.text = "아직 문의하신 내용이 없습니다.\n오른쪽 상단의 '+' 버튼으로 문의를 작성해보세요!"
        lb.numberOfLines = 0
        lb.textAlignment = .center
        lb.font = .systemFont(ofSize: 15)
        lb.textColor = .systemGray
        lb.isHidden = true
        return lb
    }()
    
    private var inquiries: [OwnerInquiry] = []
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "고객센터"
        setupUI()
        fetchMyInquiries()
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(writeInquiry)
        )
        
        view.addSubview(tableView)
        view.addSubview(noDataLabel)
        
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        noDataLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchMyInquiries() {
        guard let ownerId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("admins")
            .document(ownerId)
            .collection("inquiries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("문의 불러오기 실패:", err.localizedDescription)
                    return
                }
                
                guard let docs = snap?.documents else { return }
                
                self.inquiries = docs.compactMap { OwnerInquiry(document: $0) }
                
                self.noDataLabel.isHidden = !self.inquiries.isEmpty
                self.tableView.reloadData()
            }
    }
    
    @objc private func writeInquiry() {
        let vc = OwnerInquiryWriteVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CustomerServiceVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inquiries.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let inquiry = inquiries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let status = inquiry.answer?.isEmpty ?? true ? "답변대기" : "답변완료"
        
        cell.textLabel?.text = "\(status)  |  \(inquiry.title)"
        cell.textLabel?.numberOfLines = 1
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let inquiry = inquiries[indexPath.row]
        let vc = OwnerInquiryDetailVC(inquiry: inquiry)
        navigationController?.pushViewController(vc, animated: true)
    }
}
