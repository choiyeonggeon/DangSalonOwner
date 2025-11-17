//
//  ReservationDetailVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/4/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class ReservationDetailVC: UIViewController {
    
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let menuLabel = UILabel()
    private let dateLabel = UILabel()
    private let priceLabel = UILabel()
    private let statusLabel = UILabel()
    private let statusSegment = UISegmentedControl(items: ["예약 요청", "확정", "완료", "취소"])
    private let saveButton = UIButton(type: .system)
    
    private let db = Firestore.firestore()
    private var reservation: Reservation
    
    // MARK: - Init
    init(reservation: Reservation) {
        self.reservation = reservation
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "예약 상세"
        setupUI()
        fillData()
    }
    
    // MARK: - UI 구성
    private func setupUI() {
        view.addSubview(cardView)
        [nameLabel, menuLabel, dateLabel, priceLabel, statusLabel, statusSegment, saveButton]
            .forEach { cardView.addSubview($0) }
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 6
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [nameLabel, menuLabel, dateLabel, priceLabel, statusLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .label
        }
        nameLabel.font = .boldSystemFont(ofSize: 18)
        
        statusSegment.backgroundColor = .systemGray6
        statusSegment.selectedSegmentTintColor = .systemBlue
        statusSegment.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .medium)], for: .normal)
        
        saveButton.setTitle("상태 저장", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveButton.addTarget(self, action: #selector(updateStatus), for: .touchUpInside)
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        menuLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(menuLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        statusSegment.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(statusSegment.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - 데이터 채우기
    private func fillData() {
        nameLabel.text = "고객명: \(reservation.userName)"
        menuLabel.text = "메뉴: \(reservation.menus.joined(separator: ", "))"
        
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        dateLabel.text = "예약일: \(f.string(from: reservation.date)) \(reservation.time)"
        
        priceLabel.text = "결제 금액: \(NumberFormatter.localizedString(from: NSNumber(value: reservation.totalPrice), number: .decimal))원"
        statusLabel.text = "현재 상태: \(reservation.status)"
        
        // 현재 상태 UI 반영
        switch reservation.status {
        case "예약 요청": statusSegment.selectedSegmentIndex = 0
        case "확정": statusSegment.selectedSegmentIndex = 1
        case "완료": statusSegment.selectedSegmentIndex = 2
        case "취소": statusSegment.selectedSegmentIndex = 3
        default: statusSegment.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        // 🔥 예약 상태가 "완료" 또는 "취소"라면 이후 변경 불가
        if reservation.status == "완료" || reservation.status == "취소" {
            statusSegment.isEnabled = false
            saveButton.isEnabled = false
            saveButton.backgroundColor = .systemGray4
        }
    }
    
    // MARK: - 상태 업데이트
    @objc private func updateStatus() {
        
        // 🔥 이미 완료/취소 상태면 변경 불가
        if reservation.status == "완료" || reservation.status == "취소" {
            showAlert(title: "변경 불가", message: "완료 또는 취소된 예약은 상태를 변경할 수 없습니다.")
            return
        }
        
        guard let currentUID = Auth.auth().currentUser?.uid else {
            showAlert(title: "로그인 필요", message: "로그인 후 다시 시도해주세요.")
            return
        }
        
        let newStatus = statusSegment.titleForSegment(at: statusSegment.selectedSegmentIndex) ?? reservation.status
        let doc = db.collection("reservations").document(reservation.id)
        
        guard reservation.ownerId == currentUID else {
            showAlert(title: "권한 오류", message: "이 샵의 사장님 계정이 아닙니다.")
            return
        }
        
        doc.updateData(["status": newStatus]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "실패", message: error.localizedDescription)
                return
            }
            
            self.reservation.status = newStatus
            self.statusLabel.text = "현재 상태: \(newStatus)"
            
            // 🔥 완료/취소로 변경된 경우 즉시 UI 잠금
            if newStatus == "완료" || newStatus == "취소" {
                self.statusSegment.isEnabled = false
                self.saveButton.isEnabled = false
                self.saveButton.backgroundColor = .systemGray4
            }
            
            self.showAlert(title: "저장 완료", message: "예약 상태가 변경되었습니다.")
        }
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
