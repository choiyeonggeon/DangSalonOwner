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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchNotices() {
        db.collection("notices")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("공지사항 불러오기 오류:", error.localizedDescription)
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self.tableView.reloadData()
            }
    }
}

extension NoticeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let notice = notices[indexPath.row]
        cell.textLabel?.text = notice.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notice = notices[indexPath.row]
        let vc = NoticeDetailVC(notice: notice)
        navigationController?.pushViewController(vc, animated: true)
    }
}
