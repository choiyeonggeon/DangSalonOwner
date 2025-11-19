//
//  AppDelegate.swift
//  DangSalonOwner
//
//  Created by 최영건 on 11/3/25.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        
        // 🔔 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("🔔 푸시 권한: \(granted ? "허용됨" : "거부됨")")
        }
        
        application.registerForRemoteNotifications()
        
        // 🔥 FCM delegate
        Messaging.messaging().delegate = self
        
        // ✅ 로그인 상태 바뀔 때마다 FCM 토큰 저장 시도
        Auth.auth().addStateDidChangeListener { _, user in
            guard let user = user else { return }
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("FCM 토큰 가져오기 실패:", error.localizedDescription)
                    return
                }
                guard let token = token else { return }
                print("🔔 로그인 후 FCM 토큰:", token)
                self.saveOwnerFCMToken(token, ownerId: user.uid)
            }
        }
        
        return true
    }
    
    // APNs → FCM 토큰 연동
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // ✅ 포그라운드에서도 배너 / 사운드 나오게
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // ✅ FCM 토큰 콜백
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("🔔 FCM 토큰(Owner MessagingDelegate): \(fcmToken)")
        
        if let owner = Auth.auth().currentUser {
            saveOwnerFCMToken(fcmToken, ownerId: owner.uid)
        }
    }
    
    // 🔥 owners 컬렉션에 토큰 저장
    private func saveOwnerFCMToken(_ token: String, ownerId: String) {
        let db = Firestore.firestore()
        db.collection("owners")
            .document(ownerId)
            .setData(["fcmToken": token], merge: true) { error in
                if let error = error {
                    print("🚨 FCM 토큰 저장 실패:", error.localizedDescription)
                } else {
                    print("✅ 사장님 FCM 토큰 저장 완료")
                }
            }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
