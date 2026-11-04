import 'package:flutter/foundation.dart';

import 'admin_session.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider(this.session) {
    session.addListener(notifyListeners);
  }

  final AdminSession session;
  bool get isAuthenticated => session.isAuthenticated;

  void changed() => notifyListeners();

  @override
  void dispose() {
    session.removeListener(notifyListeners);
    super.dispose();
  }
}
