import 'dart:js_interop';

@JS('installPWA')
external JSPromise? _installPWA();

@JS('isPwaInstalled')
external JSBoolean _isPwaInstalled();

bool isPwaInstalled() {
  try {
    return _isPwaInstalled().toDart;
  } catch (_) {
    return false;
  }
}

Future<void> installPwa() async {
  try {
    final promise = _installPWA();
    if (promise != null) {
      await promise.toDart;
    }
  } catch (e) {
    print("PWA install error: $e");
  }
}
