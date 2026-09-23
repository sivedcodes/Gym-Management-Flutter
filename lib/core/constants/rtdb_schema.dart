// RTDB logical structure for Total Fit Gym (single database, no Firestore).
//
// /
// ├── meta/
// │   └── gym/ { name, qrJoinUrl, ownerUid, updatedAt }
// ├── users/
// │   └── {uid}/ { displayName, email, photoUrl, phone, role, createdAt, fcmTokens/{tokenId: true} }
// ├── plans/
// │   └── {planId}/ { name, price, durationDays, desc, active, createdAt }
// ├── registrations/
// │   └── {regId}/ { uid, phone, planId, status: pending|approved|denied, createdAt, decidedAt, decidedBy }
// ├── memberships/
// │   └── {uid}/ { planId, startAt, endAt, status: active|expiring_soon|expired, lastRegId }
// └── devices/
//     └── {uid}/{tokenId}/ { token, platform, updatedAt }
//
// Rules model (to enforce in Firebase console, not in client):
// - users/{uid}: owner read-all; user read/write-own (role field owner-only).
// - plans: all-authed read active; owner full write.
// - registrations: owner read/write-all; member create-own + read-own.
// - memberships: owner read/write-all; member read-own.
// - devices/{uid}: owner+self read; self write.
// - Never trust client role/status — validate in rules + owner double-check.
//
// Denormalization: memberships/{uid} mirrors current plan window so the
// owner dashboard (expiry list) is a single ordered query by endAt.
abstract final class RtdbSchema {
  static const version = 1;
}
