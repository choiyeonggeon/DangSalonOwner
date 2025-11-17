//
//  OwnerSettingVC.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/4/25.
//

import UIKit
import SnapKit
import FirebaseAuth

final class OwnerSettingVC: UIViewController {
    
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    // ✅ 내 정보 제거 후 섹션 재정렬
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
        case 0: return 1   // 계정
        case 1: return 2   // 고객센터
        case 2: return 1   // 공지사항
        case 3: return 2   // 앱 정보(버전 + 개인정보처리방침)
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
        cell.textLabel?.textColor = .label
        cell.accessoryType = .disclosureIndicator
        
        switch (indexPath.section, indexPath.row) {
            
            // MARK: 계정
        case (0, 0):
            cell.textLabel?.text = isLoggedIn ? "로그아웃" : "로그인"
            cell.textLabel?.textColor = isLoggedIn ? .systemRed : .systemBlue
            cell.accessoryType = .none
            
            // MARK: 고객센터
        case (1, 0):
            cell.textLabel?.text = "고객센터"
            
        case (1, 1):
            cell.textLabel?.text = "매장 등록"
            
            // MARK: 공지사항
        case (2, 0):
            cell.textLabel?.text = "공지사항"
            
            // MARK: 앱 버전
        case (3, 0):
            cell.textLabel?.text = "앱 버전"
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
            cell.detailTextLabel?.text = version
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
            // MARK: 개인정보 처리방침
        case (3, 1):
            cell.textLabel?.text = "개인정보 처리방침"
            
        default:
            break
        }
        
        return cell
    }
    
    // MARK: 셀 선택 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
            
            // MARK: 로그인 / 로그아웃
        case (0, 0):
            if isLoggedIn {
                let alert = UIAlertController(title: "로그아웃",
                                              message: "정말 로그아웃하시겠습니까?",
                                              preferredStyle: .alert)
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
            } else {
                let vc = LoginVC()
                navigationController?.pushViewController(vc, animated: true)
            }
            
            // MARK: 고객센터
        case (1, 0):
            let vc = CustomerServiceVC()
            navigationController?.pushViewController(vc, animated: true)
            
        case (1, 1):
            navigationController?.pushViewController(ShopRegisterVC(), animated: true)
            
            // MARK: 공지사항
        case (2, 0):
            let vc = NoticeVC()
            navigationController?.pushViewController(vc, animated: true)
            
            // MARK: 개인정보 처리방침
        case (3, 1):
            let vc = WebViewController(urlString: "https://your-privacy-policy-link.com")
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
}

// MARK: Alert Helper
extension OwnerSettingVC {
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - WebView (개인정보처리방침)
final class WebViewController: UIViewController {
    private let webView = UIWebView()
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "개인정보 처리방침"
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        if let url = URL(string: urlString) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
}
