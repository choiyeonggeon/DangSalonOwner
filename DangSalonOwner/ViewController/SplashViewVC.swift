//
//  SplashViewVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/22/25.
//

import UIKit
import SnapKit

class SplashViewVC: UIViewController {
    
    private let logoImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "dangsalonOwnerLogo")
        img.contentMode = .scaleAspectFill   // 🔥 핵심
        return img
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
}

extension SplashViewVC {
    private func setupUI() {
        view.addSubview(logoImage)
    }
    
    private func setupLayout() {
        logoImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

