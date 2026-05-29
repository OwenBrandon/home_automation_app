// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeLabel => 'Welcome';

  @override
  String get initializingAppLabel => 'Initializing App';

  @override
  String get loadingDeviceListLabel => 'Loading Device list';

  @override
  String get loadingOutletConfigLabel => 'Loading Outlet Config';

  @override
  String get doneLabel => 'Done';

  @override
  String get errorLoadingAppLabel => 'Error Loading App';

  @override
  String get myEnergyConsumptionInKW => 'My Energy Consumption (kW)';

  @override
  String get quickActionsLabel => 'Quick Actions';

  @override
  String get addNewDeviceLabel => 'Add New Device';

  @override
  String get manageDevicesLabel => 'Manage Devices';

  @override
  String get testConnectivityLabel => 'Test Connectivity';

  @override
  String get aboutFlickyLabel => 'About Flicky';

  @override
  String get myHomeLabel => 'My Home';

  @override
  String get myNetworkLabel => 'My Network';
}
