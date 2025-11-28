//
//  OwnerTimeDisableVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/27/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class OwnerTimeDisableVC: UIViewController {
    
    // MARK: - Properties
    private let shopId: String
    private let db = Firestore.firestore()
    
    private var selectedDate = Date()
    private var disabledTimes: [String] = []
    private var availableTimes: [String] = []
    
    // MARK: - UI
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .inline
        dp.locale = Locale(identifier: "ko_KR")
        return dp
    }()
    
    private let tableView = UITableView()
    
    // MARK: - Init
    init(shopId: String) {
        self.shopId = shopId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "스케줄 관리"
        view.backgroundColor = .systemBackground
        
        setupLayout()
        setupTable()
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        loadAvailableTimes()
        loadDisabledTimes(for: selectedDate)
    }
    
    // MARK: - UI Setup
    private func setupLayout() {
        view.addSubview(datePicker)
        view.addSubview(tableView)
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - 날짜 변경
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        loadDisabledTimes(for: selectedDate)
    }
    
    // MARK: - Firestore 불러오기 (수정된 부분)
    private func loadAvailableTimes() {
        db.collection("shops").document(shopId).getDocument { [weak self] snap, error in
            guard let self = self else { return }
            if let error = error {
                print("Firestore error: \(error.localizedDescription)")
                return
            }
            
            guard let data = snap?.data() else {
                print("No shop data")
                return
            }
            
            if let times = data["availableTimes"] as? [String] {
                print("Loaded shop availableTimes:", times)
                self.availableTimes = times.sorted()
            } else {
                print("No availableTimes field, using default")
                
                self.availableTimes = [
                    "09:00","09:30","10:00","10:30","11:00","11:30",
                    "12:00","12:30","13:00","13:30","14:00","14:30",
                    "15:00","15:30","16:00","16:30","17:00","17:30",
                    "18:00","18:30","19:00","19:30","20:00"
                ]
            }
            
            self.tableView.reloadData()
        }
    }
    
    private func loadDisabledTimes(for date: Date) {
        let dateKey = formatDate(date)
        
        db.collection("shops").document(shopId)
            .collection("disabled").document(dateKey)
            .getDocument { [weak self] snap, _ in
                guard let self = self else { return }
                
                let dict = snap?.data() as? [String: Any] ?? [:]
                self.disabledTimes = Array(dict.keys)
                self.tableView.reloadData()
            }
    }
    
    // MARK: - Firestore 저장/삭제
    private func toggleDisabled(time: String) {
        let dateKey = formatDate(selectedDate)
        
        let docRef = db.collection("shops").document(shopId)
            .collection("disabled").document(dateKey)
        
        // 이미 비활성화 → 삭제
        if disabledTimes.contains(time) {
            docRef.updateData([time: FieldValue.delete()]) { _ in
                self.disabledTimes.removeAll { $0 == time }
                self.tableView.reloadData()
            }
        }
        // 비활성화 추가
        else {
            docRef.setData([time: true], merge: true) { _ in
                self.disabledTimes.append(time)
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - TableView
extension OwnerTimeDisableVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let time = availableTimes[indexPath.row]
        
        cell.textLabel?.text = time
        cell.accessoryType = disabledTimes.contains(time) ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let time = availableTimes[indexPath.row]
        toggleDisabled(time: time)
    }
}

// MARK: - DateFormatter
extension OwnerTimeDisableVC {
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
}
