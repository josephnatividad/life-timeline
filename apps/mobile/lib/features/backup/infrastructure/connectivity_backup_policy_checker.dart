import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_ports.dart';

final class ConnectivityBackupPolicyChecker
    implements BackupNetworkPolicyChecker {
  ConnectivityBackupPolicyChecker([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> allows(AutomaticBackupNetworkPolicy policy) async {
    final connections = await _connectivity.checkConnectivity();
    if (connections.contains(ConnectivityResult.none)) return false;
    return switch (policy) {
      AutomaticBackupNetworkPolicy.anyNetwork => connections.isNotEmpty,
      AutomaticBackupNetworkPolicy.wifiOnly =>
        connections.contains(ConnectivityResult.wifi) ||
            connections.contains(ConnectivityResult.ethernet),
    };
  }
}
