import 'package:dbus/dbus.dart';
import 'package:meta/meta.dart';

/// Client that connects to the snapcraft launcher
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

  /// If false, the client cannot connect to 'io.snapcraft.Launcher'
  bool get isAvailable => _isAvailable;
  var _isAvailable = false;
  final DBusClient _bus;
  late final DBusRemoteObject _object;

  /// Connects to 'io.snapcraft.Launcher'
  Future<void> connect() async {
    try {
      // Call `openDesktopEntry` with dummy desktop ID to check if we can access
      // 'io.snapcraft.Launcher'
      await openDesktopEntry('invalidname');
    } on Exception catch (e) {
      if (e is! DBusFailedException) {
        _isAvailable = false;
        return;
      }
    }
    _isAvailable = true;
  }

  /// Closes the connection
  Future<void> close() => _bus.close();

  /// Launches the desktop entry given by [desktopFileId]
  Future<void> openDesktopEntry(String desktopFileId) => _object.callMethod(
        'io.snapcraft.PrivilegedDesktopLauncher',
        'OpenDesktopEntry',
        [DBusString(desktopFileId)],
      );
}
