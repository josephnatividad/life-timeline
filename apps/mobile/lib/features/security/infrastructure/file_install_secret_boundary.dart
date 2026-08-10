import 'dart:io';

import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Clears stale device-bound secrets when the application container is new.
///
/// In particular, iOS Keychain items can survive uninstall while the app
/// container does not. The non-secret marker follows the container lifecycle,
/// so its absence defines a new installation without relying on Keychain state.
final class FileInstallSecretBoundary implements InstallSecretBoundary {
  FileInstallSecretBoundary(
    this._store, {
    Future<Directory> Function()? supportDirectory,
  }) : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  static const _markerName = '.install-boundary-v1';

  final SecureKeyStore _store;
  final Future<Directory> Function() _supportDirectory;
  Future<void>? _preparing;

  @override
  Future<void> prepare() => _preparing ??= _prepareOnce();

  Future<void> _prepareOnce() async {
    final support = await _supportDirectory();
    final marker = File(p.join(support.path, _markerName));
    if (await marker.exists()) {
      return;
    }
    await _store.clear();
    await marker.parent.create(recursive: true);
    await marker.writeAsString('1', flush: true);
  }
}
