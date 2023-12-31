import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:machine_learning/live_camera.dart';



class BarCodeScan extends StatefulWidget {
  const BarCodeScan({super.key, required this.title});

  final String title;

  @override
  State<BarCodeScan> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BarCodeScan> {
  final ImagePicker picker = ImagePicker();
  late String result = '';
  File? _image;
  late BarcodeScanner barcodeScanner;
  late CameraController cameraController;

  chooseImages() async {
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        barcodeScanning();
      });
    }
  }

  captureImages() async {
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        barcodeScanning();
      });
    }
  }

  barcodeScanning() async {

    InputImage inputImage = InputImage.fromFile(_image!);
    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect? boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          final barcodeWifi = barcode.value as BarcodeWifi;
          result = barcodeWifi.password!;
          break;
        case BarcodeType.url:
          final barcodeUrl = barcode.value as BarcodeUrl;
          result = barcodeUrl.url!;
          break;
        default:
          break;
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
