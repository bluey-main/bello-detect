import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  var isModelBusy = false.obs;
  var cameraIndex = 1;

  var x = 0.0;
  var y = 0.0;
  var w = 0.0;
  var h = 0.0;
  var label = "";

   // Add variables to store the bounding box coordinates
  var boundingBoxX = 0.0.obs;
  var boundingBoxY = 0.0.obs;
  var boundingBoxWidth = 0.0.obs;
  var boundingBoxHeight = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    initTFLite(); // Load the TFLite model during initialization
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }
  

  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();

      cameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.max,
      );

      await cameraController.initialize();

      cameraController.startImageStream((image) {
        if (!isModelBusy.value) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            runObjectDetector(image);
          }
        }
        update();
      });

      isCameraInitialized(true);
      update();
    } else {
      print('PERMISSION DENIED');
    }
  }

    var isLoading = false.obs;

  Future<void> switchToCamera(int index) async {
    try {
      // Set isLoading to true while switching
      isLoading(true);
      
      // Dispose of the current camera controller
      await cameraController.dispose();

      // Set the cameraIndex to the specified index
      cameraIndex = index;

      // Initialize the new camera controller
      cameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.max,
      );

      await cameraController.initialize();

      // Start image stream for the new camera
      cameraController.startImageStream((image) {
        if (!isModelBusy.value) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            runObjectDetector(image);
          }
        }
        update();
      });

      update(); // Update the UI
    } catch (e) {
      print('Error switching camera: $e');
    } finally {
      // Set isLoading to false after the switching process
      isLoading(false);
    }
  }

  Future<void> switchToFrontCamera() async {
    await switchToCamera(1); // Assuming front camera index is 1, adjust if needed
  }

  Future<void> switchToBackCamera() async {
    await switchToCamera(0); // Assuming back camera index is 0, adjust if needed
  }

  Future<void> initTFLite() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  Future<void> runObjectDetector(CameraImage image) async {
    isModelBusy.value = true;

    try {
      var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        asynch: true,
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 1,
        rotation: 90,
        threshold: 0.4,
      );

      if (detector != null && detector.isNotEmpty) {
        var ourDetectedObject = detector.first;
        var confidenceInClass = ourDetectedObject['confidenceInClass'];

        log('Result is $detector');
        label = detector.first['label'];
        // h = ourDetectedObject['rect']['h'] ?? 0.0;
        // w = ourDetectedObject['rect']['w'] ?? 0.0;
        // x = ourDetectedObject['rect']['x'] ?? 0.0;
        // y = ourDetectedObject['rect']['y'] ?? 0.0;
      }
    } finally {
      isModelBusy.value = false;
    }
  }
}
