//
//  SalesBarChartView.swift
//  DangSalonOwner
//

import UIKit

final class SalesBarChartView: UIView {
    
    // 데이터
    private var values: [Int] = []
    
    // 그래프 레이어
    private let graphLayer = SalesGraphLayer()
    
    // 날짜 라벨들
    private let labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fillEqually
        sv.spacing = 0
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .white
        
        // 그래프 레이어 추가
        layer.addSublayer(graphLayer)
        
        // 아래 날짜 라벨 추가
        addSubview(labelsStackView)
        
        labelsStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(18)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let graphHeight: CGFloat = bounds.height - 22
        graphLayer.frame = CGRect(
            x: 0, y: 0,
            width: bounds.width,
            height: graphHeight
        )
        
        graphLayer.setNeedsDisplay()
    }
    
    // 🔥 외부에서 그래프 업데이트
    func configure(with values: [Int]) {
        self.values = values
        graphLayer.values = values
        setupDateLabels()
        setNeedsLayout()
    }
    
    // MARK: - 날짜 라벨
    private func setupDateLabels() {
        labelsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard !values.isEmpty else { return }
        
        let today = Calendar.current.component(.day, from: Date())
        
        for i in 1...values.count {
            let lb = UILabel()
            lb.text = "\(i)"
            lb.font = .systemFont(ofSize: 10)
            lb.textAlignment = .center
            lb.textColor = (i == today ? .systemGreen : .secondaryLabel)
            
            labelsStackView.addArrangedSubview(lb)
        }
    }
}
