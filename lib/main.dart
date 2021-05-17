import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_uploader/AlertDialog.dart';
import 'package:image_uploader/bottompicker_sheet.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Uploader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  PickedFile _image;
  bool uploadStatus = false;

  _imageFromCamera() async {
    final PickedFile image =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  _imageFromGallery() async {
    final PickedFile image =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  uploadImage() async {
    if (_image == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    setState(() {
      uploadStatus = true;
    });
    var response = await http
        .post(Uri.parse('https://pcc.edu.pk/ws/file_upload.php'), body: {
      "image": _image.readAsBytes().toString(),
      "name": _image.path.split('/').last.toString()
    });
    print('response');
    if (response.statusCode != 200) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Server Side Error.");
    } else {
      var result = jsonDecode(response.body);
      print(result);
      showAlertDialog(
          context: context, title: "Image Sent!", content: result['message']);
    }
    setState(() {
      uploadStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Uploader'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // Display Progress Indicator if uploadStatus is true
          child: uploadStatus
              ? Container(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 7,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        bottomPickerSheet(
                            context, _imageFromCamera, _imageFromGallery);
                      },
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 6,
                        backgroundColor: Colors.grey,
                        backgroundImage: _image != null
                            ? FileImage(io.File(_image.path))
                            : AssetImage('assets/camera_img.png'),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: uploadImage,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.file_upload),
                            Text(
                              'Upload Image',
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
