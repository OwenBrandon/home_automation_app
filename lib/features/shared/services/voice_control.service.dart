import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:home_automation_app/features/devices/presentation/providers/device_providers.dart';
import 'package:home_automation_app/features/devices/presentation/providers/add_device_providers.dart';
import 'package:home_automation_app/features/devices/presentation/widgets/add_device_sheet.dart';
import 'package:home_automation_app/features/devices/data/models/device.model.dart';
import 'package:home_automation_app/features/navigation/providers/navigation_providers.dart';
import 'package:home_automation_app/helpers/utils.dart';

final voiceControlServiceProvider = Provider((ref) {
  return VoiceControlService(ref);
});

class VoiceControlService {
  final Ref ref;
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  VoiceControlService(this.ref);

  Future<bool> initSpeech() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (val) => print('SpeechToText onError: $val'),
        onStatus: (val) => print('SpeechToText onStatus: $val'),
      );
    } catch (e) {
      _isInitialized = false;
      print('SpeechToText Exception: $e');
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String, bool) onResult,
    required Function(String) onStatus,
  }) async {
    final hasPerm = await initSpeech();
    if (!hasPerm) {
      onStatus('Permission denied');
      return;
    }
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;

  /// Parses speech command and performs actions (navigation, adding devices, toggles) with visual feedback.
  Future<String> parseAndExecute(String command) async {
    final text = command.toLowerCase().trim();
    if (text.isEmpty) return 'No speech detected.';

    // 1. Navigation Command intent parsing
    if (text.startsWith('go to') || 
        text.startsWith('open') || 
        text.startsWith('show') || 
        text.startsWith('navigate to') ||
        text.contains('page') ||
        text.contains('tab') ||
        text == 'settings' || 
        text == 'rooms' || 
        text == 'home' || 
        text == 'devices' ||
        text == 'dashboard') {
      
      String? targetRoute;
      String pageName = "";
      if (text.contains('settings')) {
        targetRoute = '/settings';
        pageName = "Settings";
      } else if (text.contains('rooms') || text.contains('room')) {
        targetRoute = '/rooms';
        pageName = "Rooms";
      } else if (text.contains('devices') || text.contains('device')) {
        targetRoute = '/devices';
        pageName = "Devices";
      } else if (text.contains('home') || text.contains('dashboard')) {
        targetRoute = '/home';
        pageName = "Home Dashboard";
      }

      if (targetRoute != null) {
        final navItems = ref.read(bottomBarVMProvider);
        try {
          final targetItem = navItems.firstWhere((item) => item.route == targetRoute);
          ref.read(bottomBarVMProvider.notifier).selectedItem(targetItem);
          final feedback = 'Opening $pageName page';
          Utils.showMessageOnSnack('Voice Assistant', feedback);
          return '$feedback.';
        } catch (e) {
          return 'Failed to navigate to $pageName.';
        }
      }
    }

    // 2. Add Device Command intent parsing
    if (text.contains('add device') || 
        text.contains('new device') || 
        text.contains('register device') || 
        text.contains('add new device')) {
      
      Utils.showUIModal(
        Utils.mainNav.currentContext!,
        const AddDeviceSheet(),
        onDismissed: () {
          Future.delayed(0.25.seconds, () {
            ref.read(saveAddDeviceVMProvider.notifier).resetAllValues();
          });
        }
      );
      final feedback = 'Opening Add New Device sheet';
      Utils.showMessageOnSnack('Voice Assistant', feedback);
      return '$feedback.';
    }

    // 3. Device Toggle Command intent parsing
    bool? desiredState;
    if (text.contains('turn on') || 
        text.contains('activate') || 
        text.contains('enable') || 
        text.contains('start') || 
        text.contains('encender') ||
        text.contains('prender') ||
        text.endsWith('on')) {
      desiredState = true;
    } else if (text.contains('turn off') || 
               text.contains('deactivate') || 
               text.contains('disable') || 
               text.contains('stop') || 
               text.contains('shut down') || 
               text.contains('apagar') ||
               text.endsWith('off')) {
      desiredState = false;
    }

    if (desiredState == null) {
      return 'I heard: "$command". Try saying "open settings" or "turn on [device]".';
    }

    // Match device
    final devices = ref.read(deviceListVMProvider);
    DeviceModel? matchedDevice;

    for (final device in devices) {
      final label = device.label.toLowerCase().replaceAll('\n', ' ').trim();
      final query = text
          .replaceAll('turn on', '')
          .replaceAll('turn off', '')
          .replaceAll('activate', '')
          .replaceAll('deactivate', '')
          .replaceAll('enable', '')
          .replaceAll('disable', '')
          .replaceAll('encender', '')
          .replaceAll('apagar', '')
          .replaceAll('prender', '')
          .trim();

      if (query.isNotEmpty && (label.contains(query) || query.contains(label))) {
        matchedDevice = device;
        break;
      }
    }

    if (matchedDevice == null) {
      final commandWords = text.split(' ');
      for (final device in devices) {
        final labelWords = device.label.toLowerCase().replaceAll('\n', ' ').split(' ');
        for (final word in labelWords) {
          if (word.length > 2 && commandWords.contains(word)) {
            matchedDevice = device;
            break;
          }
        }
        if (matchedDevice != null) break;
      }
    }

    if (matchedDevice == null) {
      return 'I heard: "$command", but couldn\'t find a matching device.';
    }

    final cleanLabel = matchedDevice.label.replaceAll('\n', ' ');
    if (matchedDevice.isSelected == desiredState) {
      final feedback = '$cleanLabel is already ${desiredState ? 'on' : 'off'}';
      Utils.showMessageOnSnack('Voice Assistant', feedback);
      return '$feedback.';
    }

    // Toggle
    await ref.read(deviceToggleVMProvider.notifier).toggleDevice(matchedDevice);
    final feedback = 'Turning ${desiredState ? 'on' : 'off'} $cleanLabel';
    Utils.showMessageOnSnack('Voice Assistant', feedback + '...');
    return '$feedback...';
  }
}
