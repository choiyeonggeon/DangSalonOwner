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
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {

        // Firebase 초기화
        FirebaseApp.configure()

        // 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("🔔 알림 권한: \(granted ? "허용됨" : "거부됨")")
        }

        // APNs 등록
        application.registerForRemoteNotifications()

        // FCM delegate
        Messaging.messaging().delegate = self

        // 로그인 상태 바뀔 때마다 FCM 토큰 저장
        _ = Auth.auth().addStateDidChangeListener { _, user in
            guard let user = user else { return }
            
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("❌ FCM 토큰 가져오기 실패:", error.localizedDescription)
                    return
                }
                guard let token = token else { return }
                print("🔔 로그인 후 FCM 토큰:", token)
                self.saveFCMToken(token, for: user.uid)
            }
        }

        return true
    }

    // MARK: - APNs 등록 성공
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("📬 APNs 토큰 등록됨:", tokenString)

        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: - APNs 등록 실패
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs 등록 실패:", error.localizedDescription)
    }

    // MARK: - FCM 토큰 수신 콜백
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("🔔 FCM 토큰(Delegate):", token)

        if let user = Auth.auth().currentUser {
            saveFCMToken(token, for: user.uid)
        }
    }

    // MARK: - 포그라운드 알림 (iOS 14+)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - Firestore에 토큰 저장
    private func saveFCMToken(_ token: String, for ownerId: String) {
        Firestore.firestore()
            .collection("owners")
            .document(ownerId)
            .setData(["fcmToken": token], merge: true) { error in
                if let error = error {
                    print("❌ FCM 토큰 저장 실패:", error.localizedDescription)
                } else {
                    print("✅ Firestore에 FCM 토큰 저장 완료")
                }
            }
    }

    // MARK: - Scene 세팅
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}
