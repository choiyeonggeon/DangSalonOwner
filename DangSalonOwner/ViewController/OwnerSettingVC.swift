//
//  OwnerSettingVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/4/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class OwnerSettingVC: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var isLoggedIn: Bool { Auth.auth().currentUser != nil }
    
    private let sections = ["계정", "고객센터", "공지사항", "앱 정보"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "설정"
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

// MARK: - TableView
extension OwnerSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return isLoggedIn ? 3 : 2   // 내정보 / 로그인or로그아웃 / 회원탈퇴
        case 1: return 2
        case 2: return 1
        case 3: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.accessoryType = .disclosureIndicator
        
        switch (indexPath.section, indexPath.row) {
            
            // MARK: - 계정
        case (0, 0):
            cell.textLabel?.text = "내 정보"
            
        case (0, 1):
            cell.textLabel?.text = isLoggedIn ? "로그아웃" : "로그인"
            cell.textLabel?.textColor = isLoggedIn ? .systemRed : .systemBlue
            cell.accessoryType = .none
            
        case (0, 2):
            if isLoggedIn {
                cell.textLabel?.text = "회원탈퇴"
                cell.textLabel?.textColor = .systemRed
                cell.accessoryType = .none
            }
            
            // MARK: - 고객센터
        case (1, 0):
            cell.textLabel?.text = "고객센터"
            
        case (1, 1):
            cell.textLabel?.text = "매장 등록"
            
            // MARK: - 공지사항
        case (2, 0):
            cell.textLabel?.text = "공지사항"
            
            // MARK: - 앱 정보
        case (3, 0):
            cell.textLabel?.text = "앱 버전"
            let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
            cell.detailTextLabel?.text = ver
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
        case (3, 1):
            cell.textLabel?.text = "개인정보 처리방침"
            
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - 선택 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
            
            // MARK: 내 정보
        case (0, 0):
            navigationController?.pushViewController(OwnerProfileVC(), animated: true)
            
            // MARK: 로그인 / 로그아웃
        case (0, 1):
            if isLoggedIn {
                showLogoutAlert()
            } else {
                navigationController?.pushViewController(LoginVC(), animated: true)
            }
            
            // MARK: 회원탈퇴
        case (0, 2):
            if isLoggedIn { showDeleteAccountAlert() }
            
            // MARK: 고객센터
        case (1, 0):
            navigationController?.pushViewController(CustomerServiceVC(), animated: true)
            
        case (1, 1):
            navigationController?.pushViewController(ShopRegisterVC(), animated: true)
            
            // MARK: 공지사항
        case (2, 0):
            navigationController?.pushViewController(NoticeVC(), animated: true)
            
            // MARK: 개인정보 처리방침
        case (3, 1):
            navigationController?.pushViewController(PDFViewrVC(), animated: true)
            
        default:
            break
        }
    }
}

// MARK: ALERTS
extension OwnerSettingVC {
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                self.tableView.reloadData()
                self.showAlert(title: "로그아웃 완료", message: "다시 로그인해주세요.")
            } catch {
                self.showAlert(title: "오류", message: error.localizedDescription)
            }
        })
        present(alert, animated: true)
    }
    
    private func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "회원탈퇴",
            message: "탈퇴 시 계정 정보와 데이터가 삭제됩니다.\n정말 탈퇴하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "회원탈퇴", style: .destructive) { _ in
            self.deleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Firestore에서도 사용자 정보 삭제
        Firestore.firestore().collection("users")
            .document(user.uid)
            .delete()
        
        // Auth 계정 삭제
        user.delete { error in
            if let error = error {
                self.showAlert(title: "오류", message: error.localizedDescription)
                return
            }
            
            self.showAlert(title: "탈퇴 완료", message: "계정이 삭제되었습니다.")
            self.tableView.reloadData()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }
}
