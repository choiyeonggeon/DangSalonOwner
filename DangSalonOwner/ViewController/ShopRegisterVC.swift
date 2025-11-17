//
//  ShopRegisterVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/4/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

final class ShopRegisterVC: UIViewController {
    
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameField = UITextField()
    private let introField = UITextField()
    private let addressField = UITextField()
    private let openTimeField = UITextField()
    private let closeTimeField = UITextField()
    private let phoneField = UITextField()
    
    private let imagePickerButton = UIButton(type: .system)
    private let imagePreview = UIScrollView()
    private let registerButton = UIButton(type: .system)
    
    private var selectedImages: [UIImage] = []
    private var existingShopId: String? = nil
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private let locationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("📍 지도에서 위치 선택 (선택 안 하면 주소만 사용)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "샵 등록"
        setupUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        checkExistingShop()
    }
    
    // MARK: - 기존 매장 여부 확인
    private func checkExistingShop() {
        guard let ownerId = Auth.auth().currentUser?.uid else { return }
        db.collection("shops")
            .whereField("ownerId", isEqualTo: ownerId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("매장 확인 오류:", error.localizedDescription)
                    return
                }
                if let doc = snapshot?.documents.first {
                    self.existingShopId = doc.documentID
                    self.updateUIForExistingShop()
                }
            }
    }
    
    private func updateUIForExistingShop() {
        registerButton.setTitle("내 매장 보기", for: .normal)
        registerButton.backgroundColor = .systemGray
        registerButton.removeTarget(nil, action: nil, for: .allEvents)
        registerButton.addTarget(self, action: #selector(showMyShop), for: .touchUpInside)
        
        [nameField, introField, addressField, openTimeField, closeTimeField, phoneField].forEach {
            $0.isEnabled = false
            $0.backgroundColor = UIColor.systemGray6
        }
        imagePickerButton.isEnabled = false
        imagePickerButton.alpha = 0.6
    }
    
    // MARK: - 내 매장 보기
    @objc private func showMyShop() {
        guard let shopId = existingShopId else { return }
        let vc = MyShopVC(shopId: shopId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UI 구성
    private func setupUI() {
        [scrollView, registerButton].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(registerButton.snp.top).offset(-8)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        registerButton.setTitle("등록하기", for: .normal)
        registerButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        registerButton.backgroundColor = .systemBlue
        registerButton.tintColor = .white
        registerButton.layer.cornerRadius = 12
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(56)
        }
        
        imagePreview.snp.makeConstraints { $0.height.equalTo(100) }
        
        [nameField, addressField, openTimeField, closeTimeField, phoneField].forEach {
            $0.borderStyle = .roundedRect
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
        nameField.placeholder = "샵 이름"
        addressField.placeholder = "주소"
        openTimeField.placeholder = "오픈 시간 (예: 10:00)"
        closeTimeField.placeholder = "마감 시간 (예: 21:00)"
        phoneField.placeholder = "전화번호 (예: 010-1234-5678)"
        phoneField.keyboardType = .phonePad
        
        introField.font = .systemFont(ofSize: 15)
        introField.layer.borderWidth = 1
        introField.layer.cornerRadius = 8
        introField.layer.borderColor = UIColor.systemGray4.cgColor
        introField.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        imagePickerButton.setTitle("📷 사진 선택 (최대 5장)", for: .normal)
        imagePickerButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        imagePickerButton.addTarget(self, action: #selector(selectImages), for: .touchUpInside)
        imagePreview.showsHorizontalScrollIndicator = false
        
        let stack = UIStackView(arrangedSubviews: [
            nameField, introField, addressField,
            openTimeField, closeTimeField, phoneField,
            locationButton,
            imagePickerButton, imagePreview
        ])
        stack.axis = .vertical
        stack.spacing = 16
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-40)
        }
        locationButton.addTarget(self, action: #selector(openMapPicker), for: .touchUpInside)
    }
    
    @objc private func openMapPicker() {
        let vc = MapSelectVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 등록 로직
    @objc private func didTapRegister() {
        
        // 1. 로그인 체크
        guard let ownerId = Auth.auth().currentUser?.uid else {
            showAlert(title: "로그인 필요", message: "로그인 후 이용해주세요.")
            return
        }
        
        // 2. 기존 매장 체크
        if let _ = existingShopId {
            showAlert(title: "이미 등록됨", message: "이미 매장을 등록하셨습니다.")
            return
        }
        
        // 3. 입력값 체크
        guard let name = nameField.text, !name.isEmpty,
              let intro = introField.text, !intro.isEmpty,
              let address = addressField.text, !address.isEmpty,
              let open = openTimeField.text, !open.isEmpty,
              let close = closeTimeField.text, !close.isEmpty,
              let phone = phoneField.text, !phone.isEmpty else {
            showAlert(title: "입력 오류", message: "모든 필드를 입력해주세요.")
            return
        }
        
        let shopRef = db.collection("shops").document()
        let shopId = shopRef.documentID
        
        uploadImages(shopId: shopId) { urls in
            let data: [String: Any] = [
                "name": name,
                "intro": intro,
                "address": address,
                "openTime": open,
                "closeTime": close,
                "phone": phone,
                "ownerId": ownerId,
                "imageURLs": urls,
                "rating": 0.0,
                "isRecommended": false,
                "createdAt": Timestamp(date: Date()),
                "latitude": self.selectedLatitude as Any,
                "longitude": self.selectedLongitude as Any
            ]
            
            shopRef.setData(data) { error in
                if let error = error {
                    self.showAlert(title: "등록 실패", message: error.localizedDescription)
                } else {
                    
                    // ⭐ 추가된 부분: users/{uid}에 shopId 저장
                    self.db.collection("users").document(ownerId)
                        .setData(["shopId": shopId], merge: true)
                    
                    self.showAlert(title: "등록 완료", message: "샵이 성공적으로 등록되었습니다.") {
                        self.existingShopId = shopId
                        self.updateUIForExistingShop()
                    }
                }
            }
        }
    }
    
    // MARK: - 사진 선택 (PHPicker)
    @objc private func selectImages() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - 업로드 미리보기
    private func updateImagePreview() {
        imagePreview.subviews.forEach { $0.removeFromSuperview() }
        
        let padding: CGFloat = 10
        var xOffset: CGFloat = 0
        
        for img in selectedImages {
            let imageView = UIImageView(image: img)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = CGRect(x: xOffset, y: 0, width: 90, height: 90)
            imageView.layer.cornerRadius = 8
            
            imagePreview.addSubview(imageView)
            xOffset += 100
        }
        
        imagePreview.contentSize = CGSize(width: xOffset, height: 90)
    }
    
    
    // MARK: - Firebase Storage 업로드
    private func uploadImages(shopId: String, completion: @escaping ([String]) -> Void) {
        if selectedImages.isEmpty {
            completion([])
            return
        }
        
        var uploadedURLs: [String] = []
        
        let group = DispatchGroup()
        
        for (index, image) in selectedImages.enumerated() {
            group.enter()
            
            let resized = image.resize(toWidth: 800)
            guard let imageData = resized.jpegData(compressionQuality: 0.8) else {
                group.leave()
                continue
            }
            
            let ref = storage.reference().child("shops/\(shopId)/\(index).jpg")
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("이미지 업로드 오류:", error.localizedDescription)
                    group.leave()
                    return
                }
                
                ref.downloadURL { url, _ in
                    if let url = url {
                        uploadedURLs.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }
    
    
    // MARK: - Alert
    private func showAlert(title: String, message: String, okHandle: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in okHandle?() })
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
}


// MARK: - PHPicker Delegate
extension ShopRegisterVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        selectedImages = []
        
        let group = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let img = object as? UIImage {
                        self.selectedImages.append(img)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.updateImagePreview()
        }
    }
}

// MARK: - UIImage Resize Helper
extension UIImage {
    func resize(toWidth width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        
        let newSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImg ?? self
    }
}

extension ShopRegisterVC: MapSelectDelegate {
    func didSelectLocation(latitude: Double, longitude: Double) {
        selectedLatitude = latitude
        selectedLongitude = longitude
        
        locationButton.setTitle("📍 위치 선택됨 (\(String(format: "%.5f", latitude)), \(String(format: "%.5f", longitude)))", for: .normal)
        locationButton.layer.borderColor = UIColor.systemBlue.cgColor
        locationButton.setTitleColor(.systemBlue, for: .normal)
    }
}
