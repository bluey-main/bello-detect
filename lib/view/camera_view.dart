import 'package:bello_detect/controller/scan_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: Text(
            'Emotion Detection',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Column(
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              width: 300,
                              height: 500,
                              child: controller.isLoading.value
                                  ? Center(child: CircularProgressIndicator())
                                  : CameraPreview(controller.cameraController),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top:18.0),
                              child: Text(
                                controller.label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20)
                            ),
                            
                            onPressed: () async {
                              await controller.switchToFrontCamera();
                            },
                            child: Icon(Icons.camera_front, size: 50, color: Colors.green,),
                          ),
                          SizedBox(width: 40,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20)
                            ),
                            
                            onPressed: () async {
                              await controller.switchToBackCamera();
                            },
                            child: Icon(Icons.camera_rear, size: 50, color: Colors.orange,),
                          ),
                        ],
                      )
                    ],
                  )
                : Center(
                    child: Text('LOADING PREVIEW ....'),
                  );
          },
        ),
      ),
    );
  }
}
