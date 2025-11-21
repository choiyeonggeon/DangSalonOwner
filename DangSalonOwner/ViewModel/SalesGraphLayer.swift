//
//  SalesGraphLayer.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/21/25.
//

import UIKit

final class SalesGraphLayer: CALayer {
    
    var values: [Int] = []
    
    private let gradientColors: [CGColor] = [
        UIColor.systemBlue.withAlphaComponent(0.9).cgColor,
        UIColor.systemBlue.withAlphaComponent(0.4).cgColor
    ]
    private let todayBarColor = UIColor.systemGreen.cgColor
    private let barSpacing: CGFloat = 6
    
    override func draw(in ctx: CGContext) {
        guard !values.isEmpty else { return }
        
        let rect = bounds
        
        let maxVal = values.max() ?? 1
        
        let barWidth: CGFloat = (rect.width - CGFloat(values.count - 1) * barSpacing) / CGFloat(values.count)
        
        let todayIndex = Calendar.current.component(.day, from: Date()) - 1
        
        for (i, val) in values.enumerated() {
            let normalized = CGFloat(val) / CGFloat(maxVal)
            let barHeight = rect.height * normalized
            
            let x = CGFloat(i) * (barWidth + barSpacing)
            let y = rect.height - barHeight
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 6).cgPath
            ctx.addPath(path)
            ctx.clip()
            
            if i == todayIndex {
                // 🔥 오늘
                ctx.setFillColor(todayBarColor)
                ctx.fill(barRect)
            } else {
                // 🔥 그라데이션
                let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: gradientColors as CFArray,
                    locations: [0, 1]
                )!
                
                ctx.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: barRect.midX, y: barRect.minY),
                    end: CGPoint(x: barRect.midX, y: barRect.maxY),
                    options: []
                )
            }
            
            ctx.resetClip()
        }
    }
}
