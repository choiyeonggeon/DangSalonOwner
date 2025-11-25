//
//  CustomerServiceVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/25/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class CustomerServiceVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private var inquiries: [CustomerInquiry] = []
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupTable()
        observeData()
    }
    
    // MARK: - Navigation Bar (댕살롱 스타일)
    private func setupNavigationBar() {
        title = "고객센터"
        
        let addButton = UIBarButtonItem(title: "문의하기", style: .plain, target: self, action: #selector(didTapAdd))
        addButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func didTapAdd() {
        let vc = CustomerInquiryWriteVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table UI (댕살롱 스타일)
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = 90
        tableView.backgroundColor = .white
        tableView.register(InquiryCell.self, forCellReuseIdentifier: "InquiryCell")
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    // MARK: - Firestore Listener
    private func observeData() {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("admins")
            .document(user.uid)
            .collection("inquiries")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                
                if let error = error {
                    print("불러오기 오류:", error.localizedDescription)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.inquiries = documents.compactMap { CustomerInquiry(document: $0) }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inquiries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inquiry = inquiries[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InquiryCell", for: indexPath) as! InquiryCell
        cell.configure(with: inquiry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let inquiry = inquiries[indexPath.row]
        let vc = CustomerInquiryDetailVC(inquiryId: inquiry.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
