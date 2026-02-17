import 'package:flutter/material.dart';

enum StatusType { success, error, warning, loading }

class StatusManager {
  static final _instance = StatusManager._internal();
  factory StatusManager() => _instance;
  StatusManager._internal();

  /// Show status (loading, success, error, warning)
  Future<StatusType?> showStatus(
    BuildContext context, {
    required StatusType status,
    String? message,
    Duration loadingDuration = const Duration(seconds: 2),
  }) async {
    IconData icon;
    Color color;

    switch (status) {
      case StatusType.success:
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case StatusType.error:
        icon = Icons.error_outline_rounded;
        color = Colors.red;
        break;
      case StatusType.warning:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case StatusType.loading:
        icon = Icons.hourglass_top_rounded;
        color = Colors.blue;
        break;
    }

    if (status == StatusType.loading) {
      Future.delayed(loadingDuration, () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, StatusType.loading);
        }
      });
    }

    return showModalBottomSheet<StatusType>(
      context: context,
      isDismissible: status != StatusType.loading,
      enableDrag: status != StatusType.loading,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              status == StatusType.loading
                  ? CircularProgressIndicator(color: color, strokeWidth: 4)
                  : Icon(icon, color: color, size: 60),
              SizedBox(height: 20),
              Text(
                message ?? status.name.toUpperCase(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (status != StatusType.loading)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Universal handler for any async task
  Future<T?> handleTask<T>(
    BuildContext context,
    Future<T> Function() task, {
    String loadingMessage = "Loading...",
    String successMessage = "Success!",
    String errorMessage = "Something went wrong!",
  }) async {
    try {
      await showStatus(
        context,
        status: StatusType.loading,
        message: loadingMessage,
      );
      final result = await task();
      await showStatus(
        context,
        status: StatusType.success,
        message: successMessage,
      );
      return result;
    } catch (e) {
      await showStatus(
        context,
        status: StatusType.error,
        message: errorMessage,
      );
      return null;
    }
  }
}

// Global instance
final statusManager = StatusManager();

/* void fetchUserData(BuildContext context) async {
  final result = await statusManager.handleTask(
    context,
    () async {
      final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/todos/1"));
      if (response.statusCode != 200) throw Exception("API failed");
      return json.decode(response.body);
    },
    loadingMessage: "Fetching user data...",
    successMessage: "User data loaded!",
    errorMessage: "Failed to fetch user data",
  );

  print(result); // API response
}
 */

void saveLocalData(BuildContext context) async {
  await statusManager.handleTask(
    context,
    () async {
      await Future.delayed(Duration(seconds: 2)); // simulate save
      return true;
    },
    loadingMessage: "Saving data...",
    successMessage: "Data saved successfully!",
    errorMessage: "Failed to save data",
  );
}
