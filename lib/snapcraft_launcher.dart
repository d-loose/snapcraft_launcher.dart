import 'package:dbus/dbus.dart';
import 'package:meta/meta.dart';

class PrivilegedDesktopLauncher {
  PrivilegedDesktopLauncher({
    DBusClient? bus,
    @visibleForTesting DBusRemoteObject? object,
  }) : _bus = bus ?? DBusClient.session() {
    _object = object ??
        DBusRemoteObject(
          _bus,
          name: 'io.snapcraft.Launcher',
          path: DBusObjectPath('/io/snapcraft/PrivilegedDesktopLauncher'),
        );
  }

  bool get isAvailable => _isAvailable;
  var _isAvailable = false;
  final DBusClient _bus;
  late final DBusRemoteObject _object;

  Future<void> connect() async {
    try {
      await openDesktopEntry('invalidname');
    } on Exception catch (e) {
      if (e is! DBusFailedException) {
        _isAvailable = false;
        return;
      }
    }
    _isAvailable = true;
  }

  Future<void> close() => _bus.close();

  Future<void> openDesktopEntry(String desktopEntry) => _object.callMethod(
        'io.snapcraft.PrivilegedDesktopLauncher',
        'OpenDesktopEntry',
        [DBusString(desktopEntry)],
      );
}
