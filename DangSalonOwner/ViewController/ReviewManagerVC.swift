//
//  ReviewManagerVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import UIKit
import FirebaseFirestore
import SnapKit

final class ReviewManagerVC: UIViewController {
    
    private let shopId: String
    private let db = Firestore.firestore()
    private var reviews: [Review] = []
    
    private let tableView = UITableView()
    
    init(shopId: String) {
        self.shopId = shopId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "리뷰 관리"
        view.backgroundColor = .systemBackground
        setupTable()
        fetchReviews()
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func fetchReviews() {
        db.collection("shops")
            .document(shopId)
            .collection("reviews")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snap, err in
                
                guard let self = self else { return }
                
                if let err = err {
                    print("리뷰 불러오기 실패:", err.localizedDescription)
                    return
                }
                
                self.reviews = snap?.documents.compactMap { Review(document: $0) } ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

extension ReviewManagerVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell",
                                                       for: indexPath) as? ReviewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: reviews[indexPath.row])
        cell.replyHandler = { [weak self] replyText in
            self?.saveReply(reviewId: self?.reviews[indexPath.row].id ?? "",
                            replyText: replyText)
        }
        
        return cell
    }
    
    private func saveReply(reviewId: String, replyText: String) {
        db.collection("shops")
            .document(shopId)
            .collection("reviews")
            .document(reviewId)
            .setData(["reply": replyText], merge: true) { error in
                if let error = error {
                    print("답글 저장 실패:", error.localizedDescription)
                } else {
                    print("답글 저장 완료")
                    self.fetchReviews()
                }
            }
    }
}
