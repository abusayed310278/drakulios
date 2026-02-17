// //const String baseUrl = "https://your-live-url.com";
// const String baseUrl = "https://api.handynaijaapp.com";
// //const String baseUrl = "http://10.10.5.89:5001";

// const String apiVersion = "api/v1";
// String get baseApiUrl => "$baseUrl/$apiVersion";

// /// ===========================
// ///        AUTH
// /// ===========================
// class AuthEndpoints {
//   static String register = "$baseApiUrl/auth/register";
//   static String login = "$baseApiUrl/auth/login";
//   static String forgetPassword = "$baseApiUrl/auth/forgot-password";
//   static String resetPassword = "$baseApiUrl/auth/reset-password";
//   static String verifyEmail = "$baseApiUrl/auth/verify-email";
//   static String changePassword = "$baseApiUrl/auth/change-password";
//   static String refreshToken = "$baseApiUrl/auth/refresh-token";
//   static String logout = "$baseApiUrl/auth/logout";
// }

// /// ===========================
// ///         USER
// /// ===========================
// class UserEndpoints {
//   // backend: /api/v1/users/profile
//   static String userprofile = "$baseApiUrl/users/profile";

//   // CHANGED: backend: /api/v1/users/update-profile
//   static String updateProfile = "$baseApiUrl/users/update-profile";
// }

// /// ===========================
// ///         PROVIDER
// /// ===========================
// class ProviderEndpoints {
//   static String onboard = "$baseApiUrl/provider/onboard";
//   static String myServices = "$baseApiUrl/provider/services";
//   static String serviceDetails(String id) =>
//       "$baseApiUrl/provider/services/$id";
//   static String updateService(String id) => "$baseApiUrl/provider/services/$id";
//   static String toggleOnline = "$baseApiUrl/provider/toggle-online";
// }

// class Services {
//   static String all = "$baseApiUrl/services";
//   static String byId(String id) => "$baseApiUrl/services/$id";
//   static String create = "$baseApiUrl/services";
//   static String update(String id) => "$baseApiUrl/services/$id";
//   static String delete(String id) => "$baseApiUrl/services/$id";
// }

// /// ===========================
// ///        BOOKINGS
// /// ===========================
// class BookingEndpoints {
//   static String create = "$baseApiUrl/bookings";
//   static String getAll = "$baseApiUrl/bookings";
//   static String byId(String id) => "$baseApiUrl/bookings/$id";
//   static String updateStatus(String id) => "$baseApiUrl/bookings/$id/status";
//   static String history(String status) =>
//       "$baseApiUrl/bookings/requests?status=$status";

//   // live-join
//   static String liveJoin = "$baseApiUrl/booking/live-join";
// }

// /// ===========================
// ///      NOTIFICATION
// /// ===========================
// class NotificationEndpoints {
//   static String getAll = "$baseApiUrl/notifications";
//   static String markRead(String id) => "$baseApiUrl/notification/$id/read";
// }

// /// ===========================
// ///        PAYMENT
// /// ===========================
// class PaymentEndpoints {
//   static String addFunds = "$baseApiUrl/payment/add-funds";
//   static String wallet = "$baseApiUrl/payment/wallet";
//   static String process = "$baseApiUrl/payment/process";
//   static String verify2FA = "$baseApiUrl/payment/verify-2fa";
// }

// /// ===========================
// ///        ADMIN PANEL
// /// ===========================
// class AdminEndpoints {
//   static String dashboard = "$baseApiUrl/admin/dashboard";
//   static String credits = "$baseApiUrl/admin/credits";
//   static String deleteCredit(String id) => "$baseApiUrl/admin/credits/$id";

//   static String revenue = "$baseApiUrl/admin/revenue";
//   static String bookings = "$baseApiUrl/admin/bookings";
//   static String customers = "$baseApiUrl/admin/customers";
//   static String deleteCustomer(String id) => "$baseApiUrl/admin/customers/$id";
// }

// /// ===========================
// ///        Booking PANEL
// /// ===========================

// class Review {
//   static String create = "$baseApiUrl/reviews"; // POST

//   // GET reviews by provider
//   static String getByProvider(String providerId) =>
//       "$baseApiUrl/api/v1/reviews/provider/$providerId";
// }

// /* class Review {
//   static String providerReviews(String providerId) =>
//       "$baseApiUrl/api/v1/reviews/provider/$providerId";

//   static String create = "$baseApiUrl/api/v1/reviews";
//   static String update(String id) => "$baseApiUrl/api/v1/reviews/$id";
//   static String delete(String id) => "$baseApiUrl/api/v1/reviews/$id";
// } */
