//
//  MapSelectVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/16/25.
//

import UIKit
import MapKit
import SnapKit

protocol MapSelectDelegate: AnyObject {
    func didSelectLocation(latitude: Double, longitude: Double)
}

final class MapSelectVC: UIViewController {
    
    weak var delegate: MapSelectDelegate?
    
    private let mapView = MKMapView()
    private let centerPin: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let selectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("이 위치로 선택", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "지도에서 위치 선택"
        view.backgroundColor = .systemBackground
        
        setupMap()
        setupPin()
        setupButton()
    }
    
    private func setupMap() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setupPin() {
        view.addSubview(centerPin)
        centerPin.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(40)
        }
    }
    
    private func setupButton() {
        view.addSubview(selectButton)
        selectButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(55)
        }
        selectButton.addTarget(self, action: #selector(selectLocation), for: .touchUpInside)
    }
    
    @objc private func selectLocation() {
        let center = mapView.centerCoordinate
        delegate?.didSelectLocation(latitude: center.latitude,
                                    longitude: center.longitude)
        navigationController?.popViewController(animated: true)
    }
}
