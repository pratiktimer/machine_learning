import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:machine_learning/presentation/live_camera.dart';

class ObjectDetection extends StatefulWidget {
  const ObjectDetection({super.key, required this.title});

  final String title;

  @override
  State<ObjectDetection> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetection> {
  final ImagePicker picker = ImagePicker();
  late String result = '';
  File? _image;
  late ObjectDetector objectDetector;
  late CameraController cameraController;
  late List<DetectedObject> objects;
  var image;
  chooseImages() async {
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        detectObject();
      });
    }
  }

  captureImages() async {
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        detectObject();
      });
    }
  }

  detectObject() async {
    result = "";
    final inputImage = InputImage.fromFile(_image!);
    objects = await objectDetector.processImage(inputImage);
    drawRectanglesAroundObjects();
  }

  drawRectanglesAroundObjects() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      image;
      objects;
      result;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Options to configure the detector while using with base model.
    final options = ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true);

    objectDetector = ObjectDetector(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 350,
              height: 350,
              margin: const EdgeInsets.only(
                top: 45,
              ),
              child: image != null
                  ? Center(
                      child: FittedBox(
                        child: SizedBox(
                          width: image.width.toDouble(),
                          height: image.height.toDouble(),
                          child: CustomPaint(
                            painter: ObjectPainter(
                                objectList: objects, imageFile: image),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.pinkAccent,
                      width: 350,
                      height: 350,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 53,
                      ),
                    ),
            ),
            ElevatedButton(
                onPressed: chooseImages,
                onLongPress: captureImages,
                child: const Text("Choose / Capture")),
            Text(result,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }
}

class ObjectPainter extends CustomPainter {
  List<DetectedObject> objectList;
  dynamic imageFile;
  ObjectPainter({required this.objectList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 4;

    for (DetectedObject rectangle in objectList) {
      canvas.drawRect(rectangle.boundingBox, p);
      var list = rectangle.labels;
      for (Label label in list) {
        print("${label.text}   ${label.confidence.toStringAsFixed(2)}");
        TextSpan span = TextSpan(
            text: label.text,
            style: const TextStyle(fontSize: 25, color: Colors.blue));
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas,
            Offset(rectangle.boundingBox.left, rectangle.boundingBox.top));
        break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
