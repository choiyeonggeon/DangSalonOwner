//
//  OwnerHomeVC.swift
//  DangSalonOwner
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class OwnerHomeVC: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let salesTodayCard = UIView()
    private let salesTodayLabel = UILabel()
    
    private let salesMonthCard = UIView()
    private let salesMonthLabel = UILabel()
    
    private let salesTotalCard = UIView()
    private let salesTotalLabel = UILabel()
    
    private let salesChartCard = UIView()
    private let salesChartLabel = UILabel()
    private let salesChartView = SalesBarChartView()
    
    private let statusCard = UIView()
    private let statusTitleLabel = UILabel()
    private let statusStack = UIStackView()
    
    private let greetingLabel = UILabel()
    private let subLabel = UILabel()
    
    private let todayCard = UIView()
    private let todayCountLabel = UILabel()
    private let todayTitleLabel = UILabel()
    private let todayIcon = UIImageView()
    
    private let recentCard = UIView()
    private let recentTitleLabel = UILabel()
    private let recentStack = UIStackView()
    
    private let goToListButton = UIButton(type: .system)
    
    private let db = Firestore.firestore()
    private var reservations: [Reservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "홈"
        
        setupScroll()
        setupUI()
        fetchAllReservations()
    }
    
    // MARK: - Scroll Setup
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)  // 세로 스크롤
        }
    }
    
    // 🔥 공통 카드 스타일 함수
    private func styleCard(_ v: UIView) {
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        // greeting + subLabel 먼저 추가
        contentView.addSubview(greetingLabel)
        contentView.addSubview(subLabel)
        
        greetingLabel.font = .boldSystemFont(ofSize: 26)
        greetingLabel.text = "👋 사장님, 환영합니다!"
        
        subLabel.font = .systemFont(ofSize: 16)
        subLabel.textColor = .secondaryLabel
        subLabel.text = "오늘 예약 현황을 확인하세요."
        
        // 오늘 예약 카드
        contentView.addSubview(todayCard)
        styleCard(todayCard)
        
        todayIcon.image = UIImage(systemName: "calendar.badge.clock")
        todayIcon.tintColor = .systemBlue
        
        todayCountLabel.font = .boldSystemFont(ofSize: 34)
        todayTitleLabel.font = .systemFont(ofSize: 16)
        todayTitleLabel.text = "오늘 예약"
        
        [todayIcon, todayCountLabel, todayTitleLabel].forEach { todayCard.addSubview($0) }
        
        
        // 매출 카드 3개
        [salesTodayCard, salesMonthCard, salesTotalCard].forEach {
            styleCard($0)
        }
        
        let salesStack = UIStackView(arrangedSubviews: [
            salesTodayCard,
            salesMonthCard,
            salesTotalCard
        ])
        salesStack.axis = .vertical
        salesStack.spacing = 16
        
        contentView.addSubview(salesStack)
        
        setupSalesCard(card: salesTodayCard, title: "오늘 매출", label: salesTodayLabel)
        setupSalesCard(card: salesMonthCard, title: "이번 달 매출", label: salesMonthLabel)
        setupSalesCard(card: salesTotalCard, title: "총 매출", label: salesTotalLabel)
        
        // 🔥 매출 그래프 카드
        styleCard(salesChartCard)
        contentView.addSubview(salesChartCard)
        
        salesChartLabel.text = "이번 달 매출 그래프"
        salesChartLabel.font = .boldSystemFont(ofSize: 18)
        
        salesChartCard.addSubview(salesChartLabel)
        salesChartCard.addSubview(salesChartView)
        
        salesChartView.snp.makeConstraints {
            $0.top.equalTo(salesChartLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(140)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        // 예약 상태 카드
        styleCard(statusCard)
        contentView.addSubview(statusCard)
        
        statusTitleLabel.text = "예약 상태 통계"
        statusTitleLabel.font = .boldSystemFont(ofSize: 18)
        
        statusStack.axis = .vertical
        statusStack.spacing = 6
        
        statusCard.addSubview(statusTitleLabel)
        statusCard.addSubview(statusStack)
        
        
        // 최근 예약 카드
        styleCard(recentCard)
        contentView.addSubview(recentCard)
        
        recentTitleLabel.text = "최근 예약"
        recentTitleLabel.font = .boldSystemFont(ofSize: 18)
        
        recentStack.axis = .vertical
        recentStack.spacing = 6
        
        recentCard.addSubview(recentTitleLabel)
        recentCard.addSubview(recentStack)
        
        
        // 버튼
        contentView.addSubview(goToListButton)
        goToListButton.setTitle("예약 전체 보기", for: .normal)
        goToListButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        goToListButton.backgroundColor = .systemBlue
        goToListButton.tintColor = .white
        goToListButton.layer.cornerRadius = 12
        goToListButton.addTarget(self, action: #selector(openReservationList), for: .touchUpInside)
        
        // MARK: - Constraints
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        subLabel.snp.makeConstraints {
            $0.top.equalTo(greetingLabel.snp.bottom).offset(6)
            $0.leading.equalTo(greetingLabel)
        }
        
        todayCard.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        todayIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        todayCountLabel.snp.makeConstraints {
            $0.leading.equalTo(todayIcon.snp.trailing).offset(20)
            $0.centerY.equalToSuperview().offset(-8)
        }
        
        todayTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(todayCountLabel)
            $0.top.equalTo(todayCountLabel.snp.bottom).offset(4)
        }
        
        salesStack.snp.makeConstraints {
            $0.top.equalTo(todayCard.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 🔥 매출 그래프 카드 — 이게 salesStack 바로 아래!
        salesChartCard.snp.makeConstraints {
            $0.top.equalTo(salesStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 예약 상태 카드
        statusCard.snp.makeConstraints {
            $0.top.equalTo(salesChartCard.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        statusTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }
        
        statusStack.snp.makeConstraints {
            $0.top.equalTo(statusTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        // 최근 예약 카드
        recentCard.snp.makeConstraints {
            $0.top.equalTo(statusCard.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        recentTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }
        
        recentStack.snp.makeConstraints {
            $0.top.equalTo(recentTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        // 전체 보기 버튼
        goToListButton.snp.makeConstraints {
            $0.top.equalTo(recentCard.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(55)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    // MARK: - Navigation
    @objc private func openReservationList() {
        navigationController?.pushViewController(ReservationListVC(), animated: true)
    }
    
    // MARK: - Data Fetch
    private func fetchAllReservations() {
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
                
                DispatchQueue.main.async {
                    self.updateTodayCount()
                    self.updateRecentReservations()
                    self.updateSalesStats()
                    self.updateStatusStats()
                }
            }
    }
    
    // MARK: - UI Components
    private func setupSalesCard(card: UIView, title: String, label: UILabel) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        
        [titleLabel, label].forEach { card.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }
        
        label.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().inset(22)
        }
    }
    
    // MARK: - Stats
    private func updateSalesStats() {
        let completed = reservations.filter { $0.status == "완료" }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        let todaySales = completed
            .filter { $0.date >= today }
            .reduce(0) { $0 + $1.totalPrice }
        
        let startOfMonth = Calendar.current.date(from:
                                                    Calendar.current.dateComponents([.year, .month], from: Date())
        )!
        
        let monthSales = completed
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.totalPrice }
        
        let totalSales = completed.reduce(0) { $0 + $1.totalPrice }
        
        salesTodayLabel.text = "\(formatNumber(todaySales))원"
        salesMonthLabel.text = "\(formatNumber(monthSales))원"
        salesTotalLabel.text = "\(formatNumber(totalSales))원"
    }
    
    private func updateStatusStats() {
        statusStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let completed = reservations.filter { $0.status == "완료" }.count
        let canceled = reservations.filter { $0.status == "취소" }.count
        let pending = reservations.filter { $0.status == "예약 요청" }.count
        
        let list = [
            "예약 완료: \(completed)건",
            "예약 취소: \(canceled)건",
            "예약 요청: \(pending)건"
        ]
        
        list.forEach { text in
            let lb = UILabel()
            lb.font = .systemFont(ofSize: 15)
            lb.text = text
            statusStack.addArrangedSubview(lb)
        }
        
        // 🔥🔥 그래프 데이터 업데이트 (월간 매출 막대 그래프)
        let calendar = Calendar.current
        let days = 31   // 최대 31일
        
        var dailySales = Array(repeating: 0, count: days)
        
        // "완료"된 예약만 매출로 계산
        let completedReservations = reservations.filter { $0.status == "완료" }
        
        for r in completedReservations {
            let day = calendar.component(.day, from: r.date) - 1
            if day >= 0 && day < days {
                dailySales[day] += r.totalPrice
            }
        }
        
        // 🔥 그래프 업데이트
        salesChartView.configure(with: dailySales)
    }
    
    private func updateTodayCount() {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let todayReservations = reservations.filter { $0.date >= startOfDay }
        
        todayCountLabel.text = "\(todayReservations.count)건"
    }
    
    private func updateRecentReservations() {
        recentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let recent = Array(reservations.prefix(3))
        
        if recent.isEmpty {
            let label = UILabel()
            label.text = "최근 예약이 없습니다."
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 15)
            recentStack.addArrangedSubview(label)
            return
        }
        
        recent.forEach { res in
            let lb = UILabel()
            lb.font = .systemFont(ofSize: 15)
            lb.text = "\(res.time) • \(res.userName)"
            recentStack.addArrangedSubview(lb)
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
}
