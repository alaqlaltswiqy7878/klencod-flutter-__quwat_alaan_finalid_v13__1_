import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/assistant_engine.dart';

class QuickAssistantFab extends StatefulWidget {
  const QuickAssistantFab({super.key});
  @override
  State<QuickAssistantFab> createState() => _QuickAssistantFabState();
}

class _QuickAssistantFabState extends State<QuickAssistantFab> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _listening = false;
  String? _locale;
  String _buffer = '';
  bool _restarting = false;

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_listening) {
      setState(() => _listening = false);
      await _speech.stop();
      _restarting = false;
      if (_buffer.trim().isNotEmpty) await _send(_buffer.trim());
      return;
    }
    if (!_ready) {
      _ready = await _speech.initialize(onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _listening && !_restarting) _restart();
      }, onError: (_) {
        if (mounted) setState(() => _listening = false);
      });
      if (!_ready) return;
      final locales = await _speech.locales();
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('ar')) {
          _locale = locale.localeId;
          break;
        }
      }
    }
    _buffer = '';
    setState(() => _listening = true);
    await _listen();
  }

  Future<void> _listen() async {
    if (!_listening) return;
    await _speech.listen(
      localeId: _locale,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 2),
      listenMode: ListenMode.dictation,
      onResult: (result) {
        if (mounted && result.recognizedWords.trim().isNotEmpty) {
          setState(() => _buffer = result.recognizedWords.trim());
        }
      },
    );
  }

  Future<void> _restart() async {
    if (_restarting || !_listening) return;
    _restarting = true;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _restarting = false;
    if (mounted && _listening) await _listen();
  }

  Future<void> _send(String text) async {
    final answer = await AssistantEngine.reply(text);
    await AssistantEngine.saveExchange(text, answer);
    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.48);
      await _tts.speak(answer);
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(answer), duration: const Duration(seconds: 4)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _listening ? Colors.redAccent : const Color(0xFF2E7D32);
    return Semantics(
      button: true,
      label: _listening ? 'إيقاف وإرسال المساعد' : 'بدء المساعد الصوتي',
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: _listening ? 66 : 58,
          height: _listening ? 66 : 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.28), blurRadius: _listening ? 20 : 10, spreadRadius: _listening ? 6 : 2),
            ],
          ),
          child: Icon(_listening ? Icons.stop : Icons.auto_awesome, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
