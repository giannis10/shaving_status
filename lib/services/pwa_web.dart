import 'dart:js_interop';

@JS('installPWA')
external JSPromise? _installPWA();

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
