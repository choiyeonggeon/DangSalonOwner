////
////  MyInfoVC.swift
////  DangSalonOwner
////
////  Created by 최영건 on 11/16/25.
////
//
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//import SnapKit
//
//final class MyInfoVC: UIViewController {
//    
//    private let db = Firestore.firestore()
//    private var ownerData: [String: Any] = [:]
//    
//    private let nameLabel = UILabel()
//    private let phoneLabel = UILabel()
//    private let shopLabel = UILabel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "내 정보"
//        view.backgroundColor = .systemBackground
//        
//        setupUI()
//        fetchOwnerInfo()
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "수정",
//            style: .plain,
//            target: self,
//            action: #selector(editInfo)
//        )
//    }
//    
//    private func setupUI() {
//        [nameLabel, phoneLabel, shopLabel].forEach {
//            view.addSubview($0)
//            $0.font = .systemFont(ofSize: 18)
//        }
//        
//        nameLabel.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
//            $0.left.right.equalToSuperview().inset(20)
//        }
//        phoneLabel.snp.makeConstraints {
//            $0.top.equalTo(nameLabel.snp.bottom).offset(12)
//            $0.left.right.equalToSuperview().inset(20)
//        }
//        shopLabel.snp.makeConstraints {
//            $0.top.equalTo(phoneLabel.snp.bottom).offset(12)
//            $0.left.right.equalToSuperview().inset(20)
//        }
//    }
//    
//    private func fetchOwnerInfo() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        db.collection("owners").document(uid).getDocument { snap, error in
//            if let data = snap?.data() {
//                self.ownerData = data
//                self.updateUI()
//            }
//        }
//    }
//    
//    private func updateUI() {
//        nameLabel.text = "이름: \(ownerData["name"] as? String ?? "-")"
//        phoneLabel.text = "전화번호: \(ownerData["phone"] as? String ?? "-")"
//        shopLabel.text = "매장명: \(ownerData["shopName"] as? String ?? "-")"
//    }
//    
//    @objc private func editInfo() {
//        let vc = MyInfoEditVC(ownerData: ownerData)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
