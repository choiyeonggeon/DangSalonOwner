//
//  MyShopEditVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/8/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseStorage

final class MyShopEditVC: UIViewController {
    
    // MARK: - Properties
    private let shopId: String
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private let nameField = MyShopEditVC.makeTextField(placeholder: "매장 이름")
    private let addressField = MyShopEditVC.makeTextField(placeholder: "매장 주소")
    private let phoneField = MyShopEditVC.makeTextField(placeholder: "전화번호 (010-XXXX-XXXX)")
    
    private let descView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 10
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.text = "매장 소개를 입력하세요."
        tv.textColor = .lightGray
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return tv
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장하기", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return btn
    }()
    
    // 선택된 이미지
    private var selectedImage: UIImage?
    
    // MARK: - Init
    init(shopId: String) {
        self.shopId = shopId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "매장 정보 수정"
        view.backgroundColor = .systemGroupedBackground
        setupLayout()
        loadShopData()
        
        // 터치 이벤트
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(tap)
        descView.delegate = self
        
        let tab = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tab.cancelsTouchesInView = false
        view.addGestureRecognizer(tab)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
    }
    
    // MARK: - UI Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [imageView, nameField, addressField, phoneField, descView, saveButton].forEach { contentView.addSubview($0) }
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(140)
        }
        nameField.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        addressField.snp.makeConstraints {
            $0.top.equalTo(nameField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        phoneField.snp.makeConstraints {
            $0.top.equalTo(addressField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        descView.snp.makeConstraints {
            $0.top.equalTo(phoneField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(140)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(descView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    // MARK: - Load Data
    private func loadShopData() {
        db.collection("shops").document(shopId).getDocument { snap, error in
            if let error = error {
                print("샵 불러오기 실패:", error.localizedDescription)
                return
            }
            guard let data = snap?.data() else { return }
            
            DispatchQueue.main.async {
                self.nameField.text = data["name"] as? String ?? ""
                self.addressField.text = data["address"] as? String ?? ""
                self.phoneField.text = data["phone"] as? String ?? ""
                self.descView.text = data["description"] as? String ?? ""
                self.descView.textColor = .label
                
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
    
    // MARK: - Image Picker
    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: - Keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Save Action
    @objc private func saveTapped() {
        guard
            let name = nameField.text, !name.isEmpty,
            let address = addressField.text, !address.isEmpty,
            let phone = phoneField.text, !phone.isEmpty,
            let desc = descView.text, !desc.isEmpty
        else {
            showAlert(title: "입력 오류", message: "모든 정보를 입력해주세요.")
            return
        }
        
        var data: [String: Any] = [
            "name": name,
            "address": address,
            "phone": phone,
            "description": desc
        ]
        
        // 이미지 변경 시 업로드
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            
            let ref = storage.reference().child("shops/\(shopId)/main.jpg")
            ref.putData(imageData) { _, error in
                if let error = error {
                    self.showAlert(title: "업로드 실패", message: error.localizedDescription)
                    return
                }
                ref.downloadURL { url, _ in
                    if let url = url {
                        data["imageURLs"] = [url.absoluteString]
                    }
                    self.updateFirestore(with: data)
                }
            }
        } else {
            updateFirestore(with: data)
        }
    }
    
    private func updateFirestore(with data: [String: Any]) {
        db.collection("shops").document(shopId).updateData(data) { error in
            if let error = error {
                self.showAlert(title: "저장 실패", message: error.localizedDescription)
                return
            }
            self.showAlert(title: "저장 완료", message: "매장 정보가 수정되었습니다.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    static func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }
}

// MARK: - UITextViewDelegate
extension MyShopEditVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "매장 소개를 입력하세요."
            textView.textColor = .lightGray
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension MyShopEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            selectedImage = image
        }
    }
}
