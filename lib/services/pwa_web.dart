import 'dart:js_util' as js_util;

Future<void> installPwa() async {
  try {
    if (js_util.hasProperty(js_util.globalThis, 'installPWA')) {
      await js_util.promiseToFuture(
          js_util.callMethod(js_util.globalThis, 'installPWA', []));
    }
  } catch (e) {
    print("PWA install error: $e");
  }
}
