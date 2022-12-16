import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  Future<void> handleImagePicker() async {
    // print("K is web");
    if (!kIsWeb) {
      final permStatus = await Permission.mediaLibrary.request();
      if (!permStatus.isGranted) {
        print("Cannot access photo gallery");
        return;
      }
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print("No image has been picked");
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var file = await image.readAsBytes();
        setState(() {
          webImage = file;
          _pickedImage = File('a');
        });
      } else {
        print("No image has been picked");
      }
    } else {
      print("Something went wrong");
    }
  }

  Future<void> uploadImageToServer() async {
    if(kIsWeb){
      var uri=Uri.parse("http://localhost:5000/image_upload");
      if(webImage!=null){
        var request=http.MultipartRequest('POST', uri)
          ..fields['data']='this is the data'
          ..files.add(http.MultipartFile.fromBytes('image', webImage,
              filename: "image.jpg"
          )
          );
        var response=await request.send();
        if(response.statusCode==200) print("File uploaded successfully");
      }else{
        print("The webImage is null");
      }
    }else{
      var uri=Uri.parse("http://localhost:5000/image_upload");
      print("in phone");
      if(_pickedImage==null) {
        print("No image selected");
        return;
      }
      var request=http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes("image",
          File((_pickedImage?.path)!).readAsBytesSync(),
        filename: "image.jpg"
        )
      );
      var response=await request.send();
      if(response.statusCode==200) print("File uploaded successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double _getSize(defaultSize, minSize, maxSize) {
      double currentSize = defaultSize * width;
      if (currentSize < minSize)
        return minSize;
      else if (currentSize > maxSize)
        return maxSize;
      else
        return currentSize;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Click the button to select an image',
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: _getSize(0.4, 100, 300),
                  height: _getSize(0.4, 100, 300),
                  color: Colors.grey.withAlpha(30),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        handleImagePicker();
                      },
                      iconSize: 50,
                      icon: const Icon(
                        Icons.add,
                        // size: 50,
                      ),
                    ),
                  ),
                ),
                if (_pickedImage != null)
                  Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      width: _getSize(0.4, 100, 300),
                      height: _getSize(0.4, 100, 300),
                      child: kIsWeb
                          ? Image.memory(webImage, fit: BoxFit.cover)
                          : Image.file(_pickedImage!, fit: BoxFit.cover)),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: uploadImageToServer,
                child: const Text('Upload image to the server'))
          ],
        ),
      ),
    );
  }
}
