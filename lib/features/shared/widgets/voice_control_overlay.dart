import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:home_automation_app/features/shared/services/voice_control.service.dart';
import 'package:home_automation_app/styles/styles.dart';

class VoiceControlOverlay extends ConsumerStatefulWidget {
  const VoiceControlOverlay({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const VoiceControlOverlay(),
    );
  }

  @override
  ConsumerState<VoiceControlOverlay> createState() => _VoiceControlOverlayState();
}

class _VoiceControlOverlayState extends ConsumerState<VoiceControlOverlay> {
  String _wordsSpoken = "Listening...";
  String _executionResult = "";
  bool _isListening = false;
  bool _isProcessing = false;
  Timer? _debounceTimer;

  late VoiceControlService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = ref.read(voiceControlServiceProvider);
    _startVoiceSession();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _voiceService.stopListening();
    super.dispose();
  }

  void _startVoiceSession() async {
    setState(() {
      _wordsSpoken = "Listening...";
      _executionResult = "";
      _isListening = true;
      _isProcessing = false;
    });

    await _voiceService.startListening(
      onResult: (words, isFinal) {
        setState(() {
          _wordsSpoken = words.isEmpty ? "Listening..." : words;
        });

        // Cancel previous timer
        _debounceTimer?.cancel();

        if (isFinal) {
          _voiceService.stopListening();
          setState(() {
            _isListening = false;
          });
          _processSpeech();
        } else if (words.isNotEmpty) {
          // If no new words are heard for 1.5s, assume speech is finished and submit
          _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
            if (_isListening) {
              _voiceService.stopListening();
              setState(() {
                _isListening = false;
              });
              _processSpeech();
            }
          });
        }
      },
      onStatus: (status) async {
        if (status == 'notListening' && _isListening) {
          setState(() {
            _isListening = false;
          });
          _processSpeech();
        } else if (status == 'Permission denied') {
          setState(() {
            _wordsSpoken = "Microphone permission denied.";
            _isListening = false;
          });
        }
      },
    );
  }

  void _processSpeech() async {
    if (_wordsSpoken == "Listening..." || _wordsSpoken.isEmpty) {
      setState(() {
        _wordsSpoken = "No speech detected.";
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _executionResult = "Parsing command...";
    });

    final result = await _voiceService.parseAndExecute(_wordsSpoken);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _executionResult = result;
      });
      
      // Auto-dismiss the bottom sheet on successful execution after a short delay so the user sees the feedback
      if (result.contains('Opening') || result.contains('Turning') || result.contains('already')) {
        Future.delayed(1.5.seconds, () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HomeAutomationStyles.mediumSize,
          vertical: HomeAutomationStyles.mediumSize,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(HomeAutomationStyles.smallRadius),
            topRight: Radius.circular(HomeAutomationStyles.smallRadius),
          ),
          border: Border(
            top: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              HomeAutomationStyles.mediumVGap,
              Text(
                'Voice Assistant',
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              HomeAutomationStyles.largeVGap,
              
              // Pulsing Audio Wave Visualizer (Tap to stop and execute)
              GestureDetector(
                onTap: () {
                  if (_isListening) {
                    _voiceService.stopListening();
                    setState(() {
                      _isListening = false;
                    });
                    _processSpeech();
                  }
                },
                child: SizedBox(
                  height: 60,
                  child: _isListening
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(
                            7,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                                .animate(
                                  onPlay: (controller) => controller.repeat(reverse: true),
                                )
                                .scaleY(
                                  begin: 0.2,
                                  end: 1.0,
                                  duration: (300 + (index * 100)).ms,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                        )
                      : Icon(
                          Icons.keyboard_voice_outlined,
                          size: HomeAutomationStyles.largeIconSize,
                          color: _isProcessing ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.5),
                        )
                          .animate(
                            onPlay: (controller) => _isProcessing
                                ? controller.repeat(reverse: true)
                                : controller.stop(),
                          )
                          .scaleXY(
                            begin: 0.9,
                            end: 1.1,
                            duration: 800.ms,
                            curve: Curves.easeInOut,
                          ),
                ),
              ),
              HomeAutomationStyles.xsmallVGap,
              if (_isListening)
                Text(
                  'Tap wave to stop and submit',
                  style: textTheme.labelSmall!.copyWith(
                    color: colorScheme.secondary.withValues(alpha: 0.6),
                  ),
                ),
              HomeAutomationStyles.largeVGap,

              // Words spoken
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _wordsSpoken,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
              ),

              if (_executionResult.isNotEmpty) ...[
                HomeAutomationStyles.mediumVGap,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _executionResult,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _executionResult.contains('Turning')
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
              ],

              HomeAutomationStyles.largeVGap,
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  if (!_isListening && !_isProcessing)
                    ElevatedButton(
                      onPressed: _startVoiceSession,
                      child: const Text('Try Again'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
