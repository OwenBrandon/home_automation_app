import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_automation_app/features/devices/data/models/outlet.model.dart';
import 'package:home_automation_app/features/shared/providers/shared_providers.dart';

class OutletsRepository {

  final dynamic ref;
  OutletsRepository([this.ref]);

  Future<List<OutletModel>> getAvailableOutlets() {
    final storage = ref?.read(localStorageProvider);

    return Future.value([
      OutletModel(
        id: '0',
        label: 'Outlet #0',
        ip: storage?.getOutletIp('0', '192.168.68.117') ?? '192.168.68.117',
      ),
      OutletModel(
        id: '1',
        label: 'Outlet #1',
        ip: storage?.getOutletIp('1', '192.168.68.118') ?? '192.168.68.118',
      ),
      OutletModel(
        id: '2',
        label: 'Outlet #2',
        ip: storage?.getOutletIp('2', '192.168.68.119') ?? '192.168.68.119',
      )
    ]);
  }
}