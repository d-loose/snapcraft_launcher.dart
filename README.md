# snapcraft_launcher.dart

Native Dart client library to access the snapd [desktop-launch interface](https://snapcraft.io/docs/desktop-launch-interface).


```dart
import 'package:snapcraft_launcher/snapcraft_launcher.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('please provide a desktop file ID');
    return;
  }

  final launcher = PrivilegedDesktopLauncher();
  await launcher.connect();
  if (launcher.isAvailable) {
    await launcher.openDesktopEntry(args.first);
  } else {
    print('Cannot access io.snapcraft.PrivilegedDesktopLauncher');
  }
  await launcher.close();
}
```