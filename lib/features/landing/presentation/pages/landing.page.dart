import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_automation_app/features/landing/presentation/responsiveness/landing_page_responsive.config.dart';
import 'package:home_automation_app/features/navigation/presentation/widgets/home_automation_bottombar.dart';
import 'package:home_automation_app/features/navigation/presentation/widgets/main_appbar.dart';
import 'package:home_automation_app/features/navigation/presentation/widgets/side_drawer.dart';
import 'package:home_automation_app/features/shared/widgets/voice_control_overlay.dart';

class LandingPage extends ConsumerStatefulWidget {
  static const String route = '/landing';
  final Widget child;

  const LandingPage({
    required this.child,
    super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  static const _channel = MethodChannel('com.example.home_automation_app/voice_launcher');

  @override
  void initState() {
    super.initState();
    _initMethodChannel();
  }

  void _initMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'launchVoiceAssistant') {
        if (mounted) {
          VoiceControlOverlay.show(context);
        }
      }
    });

    // Check if the app was opened by the tile when cold-started
    _channel.invokeMethod<bool>('checkLaunchVoice').then((shouldLaunch) {
      if (shouldLaunch == true && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            VoiceControlOverlay.show(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final config = LandingPageResponsiveConfig.landingPageConfig(context);

    return Scaffold(
      drawer: const Drawer(
        child: SideDrawer(),
      ),
      appBar: const HomeAutomationAppBar(),
      body: Center(
        child: Flex(
          verticalDirection: config.contentVerticalDirection,
          direction: config.contentDirection,
          children: [
            Expanded(child: SafeArea(child: widget.child)),
            const HomeAutomationBottomBar(),
          ].reverse(config.reverseContent),
        ),
      )
    );
  }
}

extension ReversedList on List<Widget> {

  List<Widget> reverse(bool reverse) {
    return reverse ? reversed.toList() : this;
  }
}