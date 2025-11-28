//
//  OwnerClosedDayVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/27/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class OwnerClosedDayVC: UIViewController {
    
    // MARK: - Properties
    private let shopId: String
    private let db = Firestore.firestore()
    
    private var closedWeekdays: [String] = []
    private var closedDates: [String] = []
    
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    private let weekdayKeys = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    // MARK: - UI Components
    
    private let weekdayTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "정기 휴무 요일"
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        return lbl
    }()
    
    private lazy var weekdayStack: UIStackView = {
        var buttons: [UIButton] = []
        for index in 0..<weekdays.count {
            let btn = UIButton(type: .system)
            btn.setTitle(weekdays[index], for: .normal)
            btn.tag = index
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.systemGray4.cgColor
            btn.backgroundColor = .systemGray6
            btn.addTarget(self, action: #selector(toggleWeekday(_:)), for: .touchUpInside)
            buttons.append(btn)
        }
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let dateTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "특정일 휴무 추가"
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        return lbl
    }()
    
    private let datePickerCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 12
        return v
    }()
    
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.locale = Locale(identifier: "ko_KR")
        dp.preferredDatePickerStyle = .compact
        return dp
    }()
    
    private let addDateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("추가", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.systemBlue
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return btn
    }()
    
    private let closedDateTable: UITableView = {
        let tv = UITableView()
        tv.layer.cornerRadius = 12
        tv.backgroundColor = .clear
        return tv
    }()
    
    // MARK: - Init
    init(shopId: String) {
        self.shopId = shopId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "휴무 관리"
        
        setupLayout()
        setupTable()
        loadClosedDays()
        
        addDateButton.addTarget(self, action: #selector(addClosedDate), for: .touchUpInside)
    }
    
    // MARK: - UI Layout
    private func setupLayout() {
        
        view.addSubview(weekdayTitleLabel)
        view.addSubview(weekdayStack)
        view.addSubview(dateTitleLabel)
        view.addSubview(datePickerCard)
        datePickerCard.addSubview(datePicker)
        datePickerCard.addSubview(addDateButton)
        view.addSubview(closedDateTable)
        
        weekdayTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        weekdayStack.snp.makeConstraints {
            $0.top.equalTo(weekdayTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        dateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(weekdayStack.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(20)
        }
        
        datePickerCard.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        
        datePicker.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        }
        
        addDateButton.snp.makeConstraints {
            $0.centerY.equalTo(datePicker)
            $0.trailing.equalToSuperview().inset(15)
        }
        
        closedDateTable.snp.makeConstraints {
            $0.top.equalTo(datePickerCard.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupTable() {
        closedDateTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        closedDateTable.dataSource = self
        closedDateTable.delegate = self
    }
    
    // MARK: - Load Firestore
    private func loadClosedDays() {
        db.collection("shops").document(shopId).getDocument { [weak self] snap, _ in
            guard let self = self else { return }
            let data = snap?.data() ?? [:]
            
            self.closedWeekdays = data["closedWeekdays"] as? [String] ?? []
            self.closedDates = data["closedDates"] as? [String] ?? []
            
            for (index, key) in self.weekdayKeys.enumerated() {
                if let btn = self.weekdayStack.arrangedSubviews[index] as? UIButton {
                    if self.closedWeekdays.contains(key) {
                        btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
                        btn.layer.borderColor = UIColor.systemBlue.cgColor
                        btn.setTitleColor(.systemBlue, for: .normal)
                    }
                }
            }
            self.closedDateTable.reloadData()
        }
    }
    
    @objc private func toggleWeekday(_ sender: UIButton) {
        let key = weekdayKeys[sender.tag]
        
        if closedWeekdays.contains(key) {
            closedWeekdays.removeAll { $0 == key }
            sender.backgroundColor = .systemGray6
            sender.layer.borderColor = UIColor.systemGray4.cgColor
            sender.setTitleColor(.label, for: .normal)
        } else {
            closedWeekdays.append(key)
            sender.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            sender.layer.borderColor = UIColor.systemBlue.cgColor
            sender.setTitleColor(.systemBlue, for: .normal)
        }
        saveClosedDays()
    }
    
    // MARK: - Add Date
    @objc private func addClosedDate() {
        let key = formatDate(datePicker.date)
        
        guard !closedDates.contains(key) else { return }
        closedDates.append(key)
        closedDates.sort()
        
        closedDateTable.reloadData()
        saveClosedDays()
    }
    
    // MARK: - Save Firestore
    private func saveClosedDays() {
        db.collection("shops").document(shopId).setData([
            "closedWeekdays": closedWeekdays,
            "closedDates": closedDates
        ], merge: true)
    }
    
    // MARK: - Date Formatting
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f.string(from: date)
    }
}

// MARK: - TableView
extension OwnerClosedDayVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return closedDates.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let date = closedDates[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.text = "\(date)  ·  휴무"
        
        return cell
    }
    
    // 삭제 기능
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let date = closedDates[indexPath.row]
        
        let alert = UIAlertController(
            title: "삭제",
            message: "\(date)을(를) 휴무 목록에서 제거하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.closedDates.remove(at: indexPath.row)
            self.saveClosedDays()
            self.closedDateTable.reloadData()
        }))
        
        present(alert, animated: true)
    }
}
