const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewReservationNotification = onDocumentCreated(
  "reservations/{reservationId}",
  async (event) => {
    const data = event.data.data();
    const ownerId = data.ownerId;

    if (!ownerId) {
      console.log("❌ ownerId 없음");
      return;
    }

    // owner의 FCM 토큰 가져오기
    const ownerDoc = await admin.firestore()
      .collection("owners")
      .doc(ownerId)
      .get();

    if (!ownerDoc.exists) {
      console.log("❌ owner 문서 없음:", ownerId);
      return;
    }

    const token = ownerDoc.data().fcmToken;

    if (!token) {
      console.log("❌ 사장님 FCM 토큰 없음");
      return;
    }

    // 🔥 iOS 푸시 완전 호환 메시지
    const message = {
      token,
      notification: {
        title: "📢 새 예약 도착!",
        body: `${data.userName}님이 예약을 요청했습니다.`,
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: "📢 새 예약 도착!",
              body: `${data.userName}님이 예약을 요청했습니다.`,
            },
            sound: "default",
            badge: 1,
            contentAvailable: 1,
          },
        },
        headers: {
          "apns-priority": "10",
        },
      },
      data: {
        reservationId: event.params.reservationId,
        ownerId: ownerId,
      },
    };

    try {
      await getMessaging().send(message);
      console.log("📨 iOS 푸시 전송 성공!");
    } catch (e) {
      console.error("🚨 푸시 전송 실패:", e);
    }
  }
);
