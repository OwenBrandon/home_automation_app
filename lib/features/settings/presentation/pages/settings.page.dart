import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_automation_app/features/devices/data/repositories/outlets.repository.dart';
import 'package:home_automation_app/features/devices/presentation/providers/add_device_providers.dart';
import 'package:home_automation_app/features/shared/providers/shared_providers.dart';
import 'package:home_automation_app/features/shared/widgets/flicky_animated_icons.dart';
import 'package:home_automation_app/features/shared/widgets/main_page_header.dart';
import 'package:home_automation_app/helpers/enums.dart';
import 'package:home_automation_app/helpers/utils.dart';
import 'package:home_automation_app/styles/styles.dart';

class SettingsPage extends ConsumerStatefulWidget {
  static const String route = '/settings';
  
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _ip0Controller;
  late TextEditingController _ip1Controller;
  late TextEditingController _ip2Controller;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(localStorageProvider);
    _ip0Controller = TextEditingController(text: storage.getOutletIp('0', '192.168.68.117'));
    _ip1Controller = TextEditingController(text: storage.getOutletIp('1', '192.168.68.118'));
    _ip2Controller = TextEditingController(text: storage.getOutletIp('2', '192.168.68.119'));
  }

  @override
  void dispose() {
    _ip0Controller.dispose();
    _ip1Controller.dispose();
    _ip2Controller.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final storage = ref.read(localStorageProvider);
    storage.storeOutletIp('0', _ip0Controller.text.trim());
    storage.storeOutletIp('1', _ip1Controller.text.trim());
    storage.storeOutletIp('2', _ip2Controller.text.trim());

    // Invalidate future provider & re-initialize active outlet list provider
    ref.invalidate(outletListRepositoryProvider);
    final newOutlets = await OutletsRepository(ref).getAvailableOutlets();
    ref.read(outletListProvider.notifier).initializeList(newOutlets);

    Utils.showMessageOnSnack('Settings Saved', 'Arduino IP configurations updated successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MainPageHeader(
              icon: FlickyAnimatedIcons(
                icon: FlickyAnimatedIconOptions.barsettings,
                size: FlickyAnimatedIconSizes.large,
                isSelected: true,
              ),
              title: 'My Settings',
            ),
            Padding(
              padding: HomeAutomationStyles.mediumPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Arduino IP Addresses',
                    style: textTheme.titleMedium!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  HomeAutomationStyles.xsmallVGap,
                  Text(
                    'Configure the IP addresses of your ESP32/ESP8266 Wi-Fi microcontrollers to control physical relays.',
                    style: textTheme.bodyMedium!.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                  HomeAutomationStyles.mediumVGap,
                  _buildIpInputCard(
                    title: 'Outlet #0 IP Address',
                    controller: _ip0Controller,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  HomeAutomationStyles.smallVGap,
                  _buildIpInputCard(
                    title: 'Outlet #1 IP Address',
                    controller: _ip1Controller,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  HomeAutomationStyles.smallVGap,
                  _buildIpInputCard(
                    title: 'Outlet #2 IP Address',
                    controller: _ip2Controller,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  HomeAutomationStyles.largeVGap,
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Configurations'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIpInputCard({
    required String title,
    required TextEditingController controller,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: HomeAutomationStyles.mediumPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeAutomationStyles.xsmallRadius),
        color: colorScheme.secondary.withValues(alpha: 0.1),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
          HomeAutomationStyles.xsmallVGap,
          Container(
            padding: HomeAutomationStyles.smallPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(HomeAutomationStyles.xsmallRadius),
              color: colorScheme.secondary.withValues(alpha: 0.15),
            ),
            child: TextFormField(
              controller: controller,
              style: textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'e.g. 192.168.1.100',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}