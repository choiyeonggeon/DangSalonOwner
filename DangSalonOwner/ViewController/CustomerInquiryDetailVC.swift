//
//  CustomerInquiryDetailVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/25/25.
//

// CustomerInquiryDetailVC.swift (새 파일)
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class CustomerInquiryDetailVC: UIViewController {
    
    private let inquiryId: String
    private var inquiry: CustomerInquiry?
    
    // UI Components
    private let titleLabel = UILabel()
    private let contentTextView = UITextView()
    private let answerTextView = UITextView()
    private let answerButton = UIButton(type: .system)
    
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    init(inquiryId: String) {
        self.inquiryId = inquiryId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "문의 상세"
        
        setupUI()
        fetchInquiryData()
    }
    
    // MARK: - Data Fetching
    private func fetchInquiryData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("admins")
            .document(userId) // 사장님 UID 문서
            .collection("inquiries")
            .document(inquiryId)
            .getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                if let document = document, document.exists {
                    self.inquiry = CustomerInquiry(document: document)
                    self.updateUI()
                } else if let error = error {
                    print("문의 상세 불러오기 오류: \(error)")
                }
            }
    }
    
    // MARK: - UI Setup & Update
    private func setupUI() {
        // 레이아웃 설정을 위해 스택 뷰 사용 (생략 가능, 단순 레이아웃 가정)
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentTextView, answerTextView, answerButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 기본 텍스트 스타일 설정
        titleLabel.font = .boldSystemFont(ofSize: 20)
        contentTextView.isEditable = false
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        answerTextView.layer.borderWidth = 1
        answerTextView.layer.borderColor = UIColor.systemBlue.cgColor
        answerTextView.layer.cornerRadius = 5
        answerTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        answerTextView.delegate = self // 답변 작성 시 필요
        answerTextView.text = "사장님의 답변을 여기에 입력하세요..." // Placeholder
        answerTextView.textColor = .lightGray
        
        answerButton.setTitle("답변 완료 및 전송", for: .normal)
        answerButton.addTarget(self, action: #selector(didTapAnswerButton), for: .touchUpInside)
        answerButton.backgroundColor = .systemBlue
        answerButton.setTitleColor(.white, for: .normal)
        answerButton.layer.cornerRadius = 8
        answerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func updateUI() {
        guard let inquiry = inquiry else { return }
        
        titleLabel.text = "문의 제목: \(inquiry.title)"
            contentTextView.text = """
            문의 샵: \(inquiry.shopName)
            문의자: \(inquiry.userEmail) (\(inquiry.userEmail))
            ---
            문의 내용:
            \(inquiry.content)
            """
        
        if let answer = inquiry.answer {
            // 답변이 이미 있는 경우
            answerTextView.text = "사장님 답변:\n\(answer.content)"
            answerTextView.isEditable = false
            answerTextView.textColor = .black
            answerButton.isHidden = true
            title = "답변 완료"
        } else {
            // 답변이 없는 경우
            answerTextView.isEditable = true
            answerButton.isHidden = false
            title = "답변 대기"
        }
    }
    
    // MARK: - Action: 답변 전송
    @objc private func didTapAnswerButton() {
        guard let userId = Auth.auth().currentUser?.uid,
              let answerText = answerTextView.text,
              !answerText.isEmpty,
              answerText != "사장님의 답변을 여기에 입력하세요..."
        else {
            // TODO: Alert: 답변 내용을 입력해주세요.
            return
        }
        
        // 1. 답변 데이터 생성
        let answerData: [String: Any] = [
            "content": answerText,
            "answeredAt": Timestamp(),
            "answeredBy": userId
        ]
        
        // 2. Firestore 업데이트
        db.collection("admins")
            .document(userId)
            .collection("inquiries")
            .document(inquiryId)
            .updateData([
                "isAnswered": true,
                "answer": answerData // 답변 객체 필드 업데이트
            ]) { [weak self] error in
                if let error = error {
                    print("답변 업데이트 오류: \(error)")
                } else {
                    print("답변 전송 완료!")
                    // TODO: Alert: 답변이 성공적으로 전송되었습니다.
                    // 화면 새로고침 또는 뒤로가기
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }
}

// MARK: - UITextViewDelegate (Placeholder 처리)
extension CustomerInquiryDetailVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "사장님의 답변을 여기에 입력하세요..."
            textView.textColor = .lightGray
        }
    }
}
