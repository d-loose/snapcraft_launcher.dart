import 'package:dbus/dbus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:test/test.dart';

class MockDBusRemoteObject extends Mock implements DBusRemoteObject {}

class MockDBusClient extends Mock implements DBusClient {}

MockDBusRemoteObject createMockRemoteObject({bool available = true}) {
  final bus = MockDBusClient();
  final object = MockDBusRemoteObject();
  when(() => object.client).thenReturn(bus);
  when(() => object.callMethod('io.snapcraft.PrivilegedDesktopLauncher',
          'OpenDesktopEntry', [const DBusString('invalidname')]))
      .thenThrow(available
          ? DBusFailedException(DBusMethodErrorResponse.failed())
          : DBusAccessDeniedException(DBusMethodErrorResponse.accessDenied()));
  when(() => object.callMethod('io.snapcraft.PrivilegedDesktopLauncher',
          'OpenDesktopEntry', [const DBusString('foobar.desktop')]))
      .thenAnswer((_) async => DBusMethodSuccessResponse());
  return object;
}

void main() {
  test('connect - available', () async {
    final object = createMockRemoteObject();
    final launcher = PrivilegedDesktopLauncher(object: object);
    expect(launcher.isAvailable, isFalse);
    await launcher.connect();
    expect(launcher.isAvailable, isTrue);
    await launcher.close();
  });

  test('connect - unavailable', () async {
    final object = createMockRemoteObject(available: false);
    final launcher = PrivilegedDesktopLauncher(object: object);
    expect(launcher.isAvailable, isFalse);
    await launcher.connect();
    expect(launcher.isAvailable, isFalse);
    await launcher.close();
  });

  test('open desktop entry', () async {
    final object = createMockRemoteObject();
    final launcher = PrivilegedDesktopLauncher(object: object);
    await launcher.connect();
    await launcher.openDesktopEntry('foobar.desktop');
    verify(() => object.callMethod('io.snapcraft.PrivilegedDesktopLauncher',
        'OpenDesktopEntry', [const DBusString('foobar.desktop')])).called(1);
    await launcher.close();
  });
}
