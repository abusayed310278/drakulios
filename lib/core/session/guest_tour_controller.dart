import 'package:get/get.dart';

class GuestTourController extends GetxController {
  final RxBool _isGuestMode = false.obs;

  bool get isGuestMode => _isGuestMode.value;
  RxBool get isGuestModeRx => _isGuestMode;

  void enterGuestMode() {
    if (_isGuestMode.value) return;
    _isGuestMode.value = true;
    _resetUserFlowInstances();
  }

  void exitGuestMode() {
    if (!_isGuestMode.value) return;
    _isGuestMode.value = false;
    _resetUserFlowInstances();
  }

  void _resetUserFlowInstances() {}
}
