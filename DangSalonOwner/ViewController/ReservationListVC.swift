//
//  ReservationListVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/3/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class ReservationListVC: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let db = Firestore.firestore()
    private var reservations: [Reservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "예약 목록"
        setupTableView()
        fetchReservations()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.register(ReservationCell.self, forCellReuseIdentifier: "ReservationCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func fetchReservations() {
        guard let ownerId = Auth.auth().currentUser?.uid else { return }

        db.collection("reservations")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("예약 불러오기 실패:", err.localizedDescription)
                    return
                }

                self.reservations = snap?.documents.compactMap { Reservation(document: $0) } ?? []
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
    }
}

// MARK: - TableView
extension ReservationListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let res = reservations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath) as! ReservationCell
        cell.configure(with: res)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let res = reservations[indexPath.row]
        let vc = ReservationDetailVC(reservation: res)
        navigationController?.pushViewController(vc, animated: true)
    }
}
