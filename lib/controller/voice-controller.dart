import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AnimateMic extends StatefulWidget {
  final Function(String) speaktoWord;
  final Function initMic;

  const AnimateMic(
      {super.key, required this.speaktoWord, required this.initMic});

  @override
  State<AnimateMic> createState() => _AnimateMicState();
}

class _AnimateMicState extends State<AnimateMic> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  double _confidenceLevel = 0;
  String _recognizeSpeak = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    var permission = await Permission.microphone.request();
    if (permission.isGranted) {
      _speechEnabled = await _speech.initialize();

      if (!_speechEnabled) {
        print("Speech not enabled");
      } else {
        print("Speech enabled");
      }
    } else {
      print("Permission not granted");
    }
  }

  void _startListening() async {
    if (!_speech.isListening && await _speech.initialize()) {
      await _speech.listen(onResult: _onSpeechResult);
      setState(() {
        _confidenceLevel = 0;
      });
    }
  }

  void _stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      setState(() {
        _recognizeSpeak = '';
      });
    }
  }

  void _onSpeechResult(result) async {
    logger.d('speaing word');
    logger.d(result.recognizedWords);

    widget.speaktoWord(result.recognizedWords);
    setState(() {
      _recognizeSpeak = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // GestureDetector(
        //     // onTap: () {
        //     //   // Navigator.push(
        //     //   //   context,
        //     //   //   MaterialPageRoute(builder: (context) => const HomeScreen()),
        //     //   // );
        //     // },
        //     onTap: () {
        //       if (_speech.isListening) {
        //         _stopListening();
        //       } else {
        //         _startListening();
        //       }
        //     },
        //     child: Center(
        //       child: SizedBox(
        //         width: 200,
        //         height: 100,
        //         child: Lottie.asset(
        //           'assets/mic.json',
        //           animate: _speech.isListening,
        //         ),
        //       ),
        //     )),
        GestureDetector(
          onTap: () {
            widget.initMic();
            if (_speech.isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
          child: Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: Lottie.asset(
                'assets/mic.json',
                animate: _speech.isListening,
              ),
            ),
          ),
        ),
        Text(
          _speech.isListening ? "Speaking" : "Press to speak",
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
