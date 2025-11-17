//
//  SalesBarChartView.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import UIKit

final class SalesBarChartView: UIView {
    
    private var values: [Int] = []
    private let barColor: UIColor = .systemBlue
    private let barSpacing: CGFloat = 6
    
    func configure(with values: [Int]) {
        self.values = values
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard !values.isEmpty else { return }
        
        let maxVal = values.max() ?? 1
        let context = UIGraphicsGetCurrentContext()
        
        let barWidth: CGFloat = (rect.width - CGFloat(values.count - 1) * barSpacing) / CGFloat(values.count)
        
        for (index, val) in values.enumerated() {
            
            let normalized = CGFloat(val) / CGFloat(maxVal)
            let barHeight = rect.height * normalized
            
            let x = CGFloat(index) * (barWidth + barSpacing)
            let y = rect.height - barHeight
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            
            context?.setFillColor(barColor.cgColor)
            context?.fill(barRect)
        }
    }
}
