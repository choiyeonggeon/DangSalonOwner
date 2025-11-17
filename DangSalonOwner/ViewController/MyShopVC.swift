//
//  MyShopVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/7/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class MyShopVC: UIViewController {
    
    private let shopId: String
    private let db = Firestore.firestore()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08 // ✅ 자연스러운 그림자
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 6
        return v
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray6
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        return iv
    }()
    
    private let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("매장 정보 수정", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private let reviewButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("리뷰 관리", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private let nameLabel = UILabel()
    private let descLabel = UILabel()
    private let addressLabel = UILabel()
    private let phoneLabel = UILabel()
    private let divider1 = UIView()
    private let divider2 = UIView()
    
    // MARK: - Init
    init(shopId: String) {
        self.shopId = shopId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "내 매장 정보"
        setupUI()
        fetchShop()
    }
    
    // MARK: - UI 구성
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        [imageView, nameLabel, descLabel,
         divider1, addressLabel,
         divider2, phoneLabel, editButton, reviewButton].forEach { cardView.addSubview($0) }
        
        // cardView 제약
        cardView.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(140)
        }
        
        nameLabel.font = .boldSystemFont(ofSize: 22)
        nameLabel.textAlignment = .center
        
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [divider1, divider2].forEach {
            $0.backgroundColor = UIColor.systemGray5
            $0.snp.makeConstraints { $0.height.equalTo(1 / UIScreen.main.scale) }
        }
        
        addressLabel.font = .systemFont(ofSize: 16)
        phoneLabel.font = .systemFont(ofSize: 16)
        addressLabel.numberOfLines = 0
        phoneLabel.numberOfLines = 0
        addressLabel.textColor = .label
        phoneLabel.textColor = .label
        
        divider1.snp.makeConstraints {
            $0.top.equalTo(descLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(divider1.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        divider2.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(divider2.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        editButton.snp.makeConstraints {
            $0.top.equalTo(phoneLabel.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
        
        reviewButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(20)  // 마지막을 reviewButton이 잡도록 변경
        }
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        reviewButton.addTarget(self, action: #selector(openReviewManager), for: .touchUpInside)
    }
    
    // MARK: - Firestore에서 데이터 불러오기
    private func fetchShop() {
        db.collection("shops").document(shopId).getDocument { snapshot, error in
            if let error = error {
                print("샵 불러오기 실패:", error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("데이터 없음")
                return
            }
            
            DispatchQueue.main.async {
                self.nameLabel.text = data["name"] as? String ?? "이름 없음"
                self.descLabel.text = data["description"] as? String ?? "설명 없음"
                self.addressLabel.text = data["address"] as? String ?? "주소 없음"
                self.phoneLabel.text = data["phone"] as? String ?? "전화번호 없음"
                
                if let urlString = (data["imageURLs"] as? [String])?.first,
                   let url = URL(string: urlString) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.imageView.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
    }
    
    // MARK: - 버튼 액션
    @objc private func editTapped() {
        let vc = MyShopEditVC(shopId: shopId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openReviewManager() {
        let vc = ReviewManagerVC(shopId: shopId)
        navigationController?.pushViewController(vc, animated: true)
    }
}
