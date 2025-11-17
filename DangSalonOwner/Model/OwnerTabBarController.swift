//
//  OwnerTabBarController.swift
//  DangSalonOwner
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class OwnerTabBarController: UITabBarController {
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
        
        fetchUserDataAndSetupTabs()
    }
    
    // 🔥 1) 유저의 role + shopId 가져오기
    private func fetchUserDataAndSetupTabs() {
        guard let uid = Auth.auth().currentUser?.uid else {
            setupTabs(role: "guest", shopId: nil)
            return
        }
        
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            let data = snapshot?.data() ?? [:]
            
            let role = data["role"] as? String ?? "owner"
            let shopId = data["shopId"] as? String   // ⭐ 여기서 바로 가져옴
            
            DispatchQueue.main.async {
                self.setupTabs(role: role, shopId: shopId)
            }
        }
    }
    
    
    // MARK: - 2) 탭 구성
    private func setupTabs(role: String, shopId: String?) {
        
        // 홈
        let homeVC = UINavigationController(rootViewController: OwnerHomeVC())
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), tag: 0)
        
        // 예약 목록
        let reservationVC = UINavigationController(rootViewController: ReservationListVC())
        reservationVC.tabBarItem = UITabBarItem(title: "예약", image: UIImage(systemName: "calendar"), tag: 1)
        
        
        // 🔥 매장 보기 탭
        let shopVC: UINavigationController
        
        if let shopId = shopId {
            // 매장 있음 → MyShopVC로 이동
            shopVC = UINavigationController(rootViewController: MyShopVC(shopId: shopId))
        } else {
            // 매장 없음 → 안내 화면
            shopVC = UINavigationController(rootViewController: NoShopVC())
        }
        
        shopVC.tabBarItem = UITabBarItem(title: "매장", image: UIImage(systemName: "building.2"), tag: 2)
        
        
        // 설정
        let settingVC = UINavigationController(rootViewController: OwnerSettingVC())
        settingVC.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape"), tag: 3)
        
        
        // 🔥 관리자(admin) 계정이면 추가 탭 표시
        if role == "admin" {
            let adminVC = UINavigationController(rootViewController: AdminApprovedListVC())
            adminVC.tabBarItem = UITabBarItem(title: "승인 관리",
                                              image: UIImage(systemName: "checkmark.seal"),
                                              tag: 4)
            
            viewControllers = [homeVC, reservationVC, shopVC, settingVC, adminVC]
        } else {
            // 일반 사장님
            viewControllers = [homeVC, reservationVC, shopVC, settingVC]
        }
    }
}


// MARK: - 매장 없음 안내 VC
final class NoShopVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "매장 없음"
        
        let label = UILabel()
        label.text = "등록된 매장이 없습니다.\n설정 → 샵 등록에서 등록해주세요."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
