import '../../../core/network/api_service/token_meneger.dart';

class QrHomeController {
  Future<String> getDisplayName() async {
    final name = (await TokenManager.getUserName())?.trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }

    final email = (await TokenManager.getEmail())?.trim() ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return 'Member';
  }
}
