// ignore_for_file: non_constant_identifier_names, file_names, must_call_super

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:i_need/Helper.dart';
import 'package:image_picker/image_picker.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with SingleTickerProviderStateMixin {
  // All Variables
  bool isVideoRecording = false;
  bool isLoading = false;
  XFile? _capturedVideo;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>>? emergencyData; // List to hold audio/video data
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool _animationTriggered = false;

  @override
  void initState() {
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _breathingAnimation =
        Tween<double>(begin: 100, end: 200).animate(_breathingController);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  // Emergency process
  void Emergency() async {
    setState(() {
      isLoading = true;
      _animationTriggered = true;
      _breathingController.repeat(reverse: true);
    });

    log("Location Capturing Started");
    Helper.locationfetch();
    videocapture();
  }

  // Video capturing
  void videocapture() async {
    _capturedVideo = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 60),
    );
    setState(() {
      isVideoRecording = true;
    });
    stopvideocapture();
  }

  // Stop video capturing
  Future<void> stopvideocapture() async {
    setState(() {
      isVideoRecording = false;
      _animationTriggered = false;
      _breathingController.stop();
    });
    log("Video file path: ${_capturedVideo?.path}");
    setState(() {
      isLoading = false;
    });
  }

  //  Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Breathing circle
              _animationTriggered
                  ? AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Container(
                          width: _breathingAnimation.value,
                          height: _breathingAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red[50],
                          ),
                        );
                      },
                    )
                  : Container(),
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                          strokeCap: StrokeCap.round,
                        )
                      : OutlinedButton(
                          onPressed: () {
                            Emergency();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red[200],
                            padding: const EdgeInsets.all(20),
                            shape: CircleBorder(),
                          ),
                          child: const Text(
                            "Emergency",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
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
