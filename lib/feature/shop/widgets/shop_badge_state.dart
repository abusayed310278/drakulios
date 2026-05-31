import 'package:flutter/foundation.dart';

class ShopBadgeState {
  static final ValueNotifier<int> cartCount = ValueNotifier<int>(0);
  static final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);

  static void incrementCart() => cartCount.value = cartCount.value + 1;
  static void setCartCount(int count) {
    cartCount.value = count < 0 ? 0 : count;
  }

  static void incrementNotification() =>
      notificationCount.value = notificationCount.value + 1;
  static void decrementNotification() {
    final next = notificationCount.value - 1;
    notificationCount.value = next < 0 ? 0 : next;
  }

  static void setNotificationCount(int count) {
    notificationCount.value = count < 0 ? 0 : count;
  }
}
