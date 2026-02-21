import 'package:flutter/foundation.dart';

base class ApiEndpoints {
  static const String socketUrl = _LocalHostWifi.socketUrl;

  static const String baseUrl = _LocalHostWifi.baseUrl;

  // static const String socketUrl = _RemoteServer.socketUrl;

  // static const String baseUrl = _RemoteServer.baseUrl;

  // ---------------------- AUTH -----------------------------
  static const String login = _Auth.login;
  static const String register = _Auth.register;
  static const String forgetPassword = _Auth.forgetPassword;
  static const String verifyOtp = _Auth.verifyOtp;
  static const String verifyEmail = _Auth.verifyEmail;
  static const String resetPassword = _Auth.resetPassword;
  static const String logout = _Auth.logout;
  static const String changePassword = _Auth.changePassword;
  static const String switchRole = _Auth.switchRole;
  static const String socialLogin = _Auth.socialLogin;
  static const String refreshToken = _Auth.refreshToken;
  static const String requestHistory = _Requests.requestHistory;
  static const String services = _Services.services;
  static const String bookingRequests = _Services.bookingRequests;
  static const String applyCoupon = _Coupons.applyCoupon;
  static const String myCoupons = _Coupons.myCoupons;
  static const String updateProfessionalStatus =
      _Professional.updateProfessionalStatus;
  static const String getProfile = _User.getProfile;
  static const String updateProfile = _User.updateProfile;
  static const String profileChangePassword = _User.changePassword;
  static const String deleteAccount = _User.deleteAccount;
  static const String trainingToday = _Training.today;
  static const String trainingMine = _Training.mine;
  static const String trainingCreate = _Training.create;
  static const String attendanceMine = _Attendance.mine;
  static const String nutritionToday = _Nutrition.today;
  static const String nutritionMine = _Nutrition.mine;
  static const String subscriptions = _Subscription.list;
  static const String products = _Product.all;
  static const String createProduct = _Product.create;
  static const String notifications = _Notification.me;
  static const String cart = _Cart.get;
  static const String cartAdd = _Cart.add;
  static const String cartUpdateQuantity = _Cart.updateQuantity;
  static const String cartRemoveItem = _Cart.removeItem;
  static const String cartClear = _Cart.clear;
  static const String paymentCreate = _Payment.create;
  static const String paymentConfirm = _Payment.confirm;
  static const String paymentConfig = _Payment.config;
  static const String paymentHistory = _Payment.history;
  static const String paymentMembershipSummary = _Payment.membershipSummary;

  // ---------------------- USER -----------------------------
  static const String user = '$baseUrl/user';
  static const String professional = '$baseUrl/professional';

  // ---------------------- category -----------------------------
  static const String categories = '$baseUrl/categories';
  static String serviceById(String id) => _Services.serviceById(id);
  static String bookingRequestById(String id) =>
      _Services.bookingRequestById(id);
  static String cancelService(String id) => _Services.cancelService(id);
  static String cancelBookingRequest(String id) =>
      _Services.cancelBookingRequest(id);
  static String repeatService(String id) => _Services.repeatService(id);
  static String repeatBookingRequest(String id) =>
      _Services.repeatBookingRequest(id);
  static String productById(String id) => _Product.byId(id);
  static String updateProduct(String id) => _Product.update(id);
  static String deleteProduct(String id) => _Product.delete(id);
  static String markNotificationRead(String id) => _Notification.markRead(id);

  //---------------------subcategory-------------------------
  // ✅ subcategory by categoryId
  static String subcategoriesByCategoryId(String categoryId) =>
      '$baseUrl/subcategories/category/$categoryId';
}

class _RemoteServer {
  static const String socketUrl = 'https://api.handynaijaapp.com';

  static const String baseUrl = 'https://api.handynaijaapp.com/api/v1';
}

// ignore: unused_element
class _LocalHostWifi {
  // ignore: unused_field
  static const String socketUrl = 'http://10.10.5.98:5000';

  // ignore: unused_field
  static const String baseUrl = 'http://10.10.5.98:5000/api/v1';
}

abstract class _Auth {
  @protected
  static const String _authRoute = '${ApiEndpoints.baseUrl}/auth';
  // example
  static const String login = '$_authRoute/login';
  static const String register = '$_authRoute/register';
  static const String forgetPassword = '$_authRoute/forget';
  static const String verifyOtp = '$_authRoute/verify-otp';
  static const String verifyEmail = '$_authRoute/verify';
  static const String resetPassword = '$_authRoute/reset-password';
  static const String logout = '$_authRoute/logout';
  static const String changePassword = '$_authRoute/change-password';
  static const String switchRole = '$_authRoute/switch-role';
  static const String socialLogin = '$_authRoute/social-login';
  static const String refreshToken = '$_authRoute/refresh-token';
}

class _Requests {
  @protected
  static const String _requestRoute = ApiEndpoints.baseUrl;
  static const String requestHistory = '$_requestRoute/request-history';
}

class _Services {
  @protected
  static const String _servicesRoute = ApiEndpoints.baseUrl;
  static const String services = '$_servicesRoute/services';
  static const String bookingRequests = '$_servicesRoute/bookings/requests';

  static String serviceById(String id) => '$services/$id';
  static String bookingRequestById(String id) => '$bookingRequests/$id';
  static String cancelService(String id) => '$services/$id/cancel';
  static String cancelBookingRequest(String id) =>
      '$bookingRequests/$id/cancel';
  static String repeatService(String id) => '$services/$id/repeat';
  static String repeatBookingRequest(String id) =>
      '$bookingRequests/$id/repeat';
}

class _Professional {
  @protected
  static const String _professionalRoute =
      '${ApiEndpoints.baseUrl}/professional';
  static const String updateProfessionalStatus =
      '$_professionalRoute/update-status';
}

class _Coupons {
  @protected
  static const String _couponRoute = '${ApiEndpoints.baseUrl}/coupon';
  static const String applyCoupon = '$_couponRoute/apply-coupon';
  static const String myCoupons = '$_couponRoute/my-coupons';
}

class _User {
  @protected
  static const String _userRoute = '${ApiEndpoints.baseUrl}/user';
  static const String getProfile = '$_userRoute/profile';
  static const String updateProfile = '$_userRoute/update-profile';
  static const String changePassword = '$_userRoute/change-password';
  static const String deleteAccount = '$_userRoute/delete-account';
}

class _Training {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/training';
  static const String create = _route;
  static const String today = '$_route/today';
  static const String mine = '$_route/me';
}

class _Nutrition {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/nutration';
  static const String today = '$_route/today';
  static const String mine = '$_route/me';
}

class _Subscription {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/subscription';
  static const String list = _route;
}

class _Product {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/product';
  static const String create = '$_route/create-product';
  static const String all = '$_route/all';

  static String byId(String id) => '$_route/$id';
  static String update(String id) => '$_route/$id';
  static String delete(String id) => '$_route/$id';
}

class _Notification {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/notification';
  static const String me = '$_route/me';
  static String markRead(String id) => '$_route/$id/read';
}

class _Cart {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/cart';
  static const String add = '$_route/add';
  static const String get = _route;
  static const String updateQuantity = '$_route/update-quantity';
  static const String removeItem = '$_route/remove-item';
  static const String clear = '$_route/clear';
}

class _Payment {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/payment';
  static const String create = '$_route/create-payment';
  static const String config = '$_route/config';
  static const String confirm = '$_route/confirm-payment';
  static const String history = '$_route/history';
  static const String membershipSummary = '$_route/membership-summary';
}

class _Attendance {
  @protected
  static const String _route = '${ApiEndpoints.baseUrl}/attendance';
  static const String mine = '$_route/me';
}
