////
////  MyInfoEditVC.swift
////  DangSalonOwner
////
////  Created by 최영건 on 11/16/25.
////
//
//import UIKit
//import SnapKit
//import FirebaseAuth
//import FirebaseFirestore
//
//final class MyInfoEditVC: UIViewController {
//    
//    private let db = Firestore.firestore()
//    private var ownerData: [String: Any]
//    
//    private let nameField = UITextField()
//    private let phoneField = UITextField()
//    private let shopField = UITextField()
//    
//    init(ownerData: [String: Any]) {
//        self.ownerData = ownerData
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) { fatalError() }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "정보 수정"
//        view.backgroundColor = .systemBackground
//        
//        setupUI()
//        fillData()
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "저장",
//            style: .done,
//            target: self,
//            action: #selector(saveInfo)
//        )
//    }
//    
//    private func setupUI() {
//        let stack = UIStackView(arrangedSubviews: [nameField, phoneField, shopField])
//        stack.axis = .vertical
//        stack.spacing = 16
//        
//        view.addSubview(stack)
//        stack.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
//            $0.left.right.equalToSuperview().inset(20)
//        }
//        
//        [nameField, phoneField, shopField].forEach {
//            $0.borderStyle = .roundedRect
//            $0.heightAnchor.constraint(equalToConstant: 45).isActive = true
//        }
//        
//        nameField.placeholder = "이름"
//        phoneField.placeholder = "전화번호"
//        shopField.placeholder = "매장명"
//    }
//    
//    private func fillData() {
//        nameField.text = ownerData["name"] as? String
//        phoneField.text = ownerData["phone"] as? String
//        shopField.text = ownerData["shopName"] as? String
//    }
//    
//    @objc private func saveInfo() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        let updated: [String: Any] = [
//            "name": nameField.text ?? "",
//            "phone": phoneField.text ?? "",
//            "shopName": shopField.text ?? ""
//        ]
//        
//        db.collection("owners").document(uid).updateData(updated) { error in
//            if let error = error {
//                print("정보 수정 실패:", error.localizedDescription)
//                return
//            }
//            
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//}
