//
//  ReservationReportWriteVC.swift
//  DangSalonOwner
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

final class ReservationReportWriteVC: UIViewController {
    
    private let reservation: Reservation
    private let db = Firestore.firestore()
    
    private let reasonTextView: UITextView = {
        let tv = UITextView()
        tv.text = "신고 사유를 입력하세요."
        tv.textColor = .lightGray
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 10
        tv.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("신고 제출", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 10
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }()
    
    init(reservation: Reservation) {
        self.reservation = reservation
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "예약 신고하기"
        view.backgroundColor = .systemBackground
        setupLayout()
        
        reasonTextView.delegate = self
        submitButton.addTarget(self, action: #selector(submitReport), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupLayout() {
        [reasonTextView, submitButton].forEach { view.addSubview($0) }
        
        reasonTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(reasonTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc private func submitReport() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let reason = reasonTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reason.isEmpty, reason != "신고 사유를 입력하세요." else {
            showAlert("신고 사유를 입력해주세요.")
            return
        }
        
        let reportId = UUID().uuidString
        
        let data: [String: Any] = [
            "reportId": reportId,
            "reservationId": reservation.id,
            "reporterId": uid,
            "targetOwnerId": reservation.ownerId,
            "reason": reason,
            "status": "pending",
            "createdAt": Timestamp()
        ]
        
        db.collection("reservationReports")
            .document(reportId)
            .setData(data) { error in
                if let error = error {
                    self.showAlert("등록 실패: \(error.localizedDescription)")
                    return
                }
                self.showAlert("신고가 제출되었습니다.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    private func showAlert(_ msg: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(ac, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ReservationReportWriteVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
}
