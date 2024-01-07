import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import 'presentation/live_object_detection.dart';
import 'presentation/object_detection.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Machine learning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LiveCameraPage(title: 'Machine learning'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();
  late ImageLabeler imageLabeler;
  late String result = '';
  File? _image;

  late CameraController cameraController;

  chooseImages() async {
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        imageLabeling();
      });
    }
  }

  captureImages() async {
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        imageLabeling();
      });
    }
  }

  imageLabeling() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      result += text + " " + confidence.toStringAsFixed(2) + "\n";
    }

    setState(() {
      result;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initializeVC();
  }

  Future<void> initializeVC() async {
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await cameraController.initialize();

    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ObjectDetection(
                      title: "",
                    )),
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
            _image != null
                ? Image.file(
                    _image!,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.image,
                    size: MediaQuery.of(context).size.width,
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
