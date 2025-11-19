const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const admin = require("firebase-admin");

admin.initializeApp();

// 🟦 새 예약 생성 → 사장님에게 알림
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
      console.log("❌ FCM 토큰 없음");
      return;
    }

    const message = {
      notification: {
        title: "새 예약 요청",
        body: `${data.userName}님이 예약을 요청했습니다.`,
      },
      token: token,
    };

    try {
      await getMessaging().send(message);
      console.log("📨 푸시 알림 전송 성공!");
    } catch (e) {
      console.error("🚨 푸시 알림 실패:", e);
    }
  }
);
