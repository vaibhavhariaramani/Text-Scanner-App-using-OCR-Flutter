/*

Authours :-

    Aditya - 18BCS6152
    Hrithik - 18BCS6145
    Kshitij - 18BCS6146
    Sahil - 18BCS6224
    Vaibhav - 18BCS6136

An OCR application!

*/

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vision/image_detail.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.black, // status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    // Formatting Date and Time
    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');
    print("Formatted: $formattedDateTime");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision\ Images';
    await Directory(visionDir).create(recursive: true);
    final String imagePath = '$visionDir/image_$formattedDateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      await _controller.takePicture(imagePath);
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Text Scanner',
          style: TextStyle(fontFamily: 'Valera'),
        ),
      ),
      body: _controller.value.isInitialized
          ? Stack(
              children: <Widget>[
                Transform.scale(
                  scale: _controller.value.aspectRatio / deviceRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: deviceRatio * 65.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: deviceRatio * 75.0,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: deviceRatio * 70.0),
                  child: IconButton(
                    iconSize: deviceRatio * 100.0,
                    color: Colors.red,
                    icon: Icon(Icons.camera_alt_rounded),
                    onPressed: () async {
                      await _takePicture().then((String path) {
                        if (path != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(path),
                            ),
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
