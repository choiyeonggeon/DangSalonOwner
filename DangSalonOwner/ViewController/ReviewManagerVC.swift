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
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewCell",
            for: indexPath
        ) as? ReviewCell else {
            return UITableViewCell()
        }
        
        let review = reviews[indexPath.row]
        
        cell.configure(with: review)
        
        // 🔵 답글 저장
        cell.replyHandler = { [weak self] replyText in
            guard let self = self else { return }
            self.saveReply(reviewId: review.id, replyText: replyText)
        }
        
        // 🔴 신고 처리
        cell.reportHandler = { [weak self] in
            guard let self = self else { return }
            self.showReportAlert(review: review)
        }
        
        return cell
    }
    
    // MARK: - 답글 저장
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
    
    // MARK: - 리뷰 신고
    private func showReportAlert(review: Review) {
        let alert = UIAlertController(
            title: "리뷰 신고",
            message: "이 리뷰를 신고하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "신고", style: .destructive) { _ in
            self.sendReviewReport(review)
        })
        
        present(alert, animated: true)
    }
    
    private func sendReviewReport(_ review: Review) {
        db.collection("reviewReports")
            .addDocument(data: [
                "shopId": shopId,
                "reviewId": review.id,
                "userId": review.authorId ?? "",
                "nickname": review.nickname,
                "content": review.content,
                "timestamp": Timestamp()
            ]) { err in
                if let err = err {
                    print("신고 저장 실패:", err.localizedDescription)
                } else {
                    print("리뷰 신고 저장 완료")
                }
            }
    }
}
