import 'dart:convert';
import 'dart:io';
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
  File _image;
  bool uploadStatus = false;

  _imageFromCamera() async {
    final PickedFile pickedImage =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedImage == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    final File fileImage = File(pickedImage.path);

    if (imageConstraint(fileImage))
      setState(() {
        _image = fileImage;
      });
  }

  _imageFromGallery() async {
    final PickedFile pickedImage =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedImage == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    final File fileImage = File(pickedImage.path);
    if (imageConstraint(fileImage))
      setState(() {
        _image = fileImage;
      });
  }

  bool imageConstraint(File image) {
    if (!['bmp', 'jpg', 'jpeg']
        .contains(image.path.split('.').last.toString())) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Image format should be jpg/jpeg/bmp.");
      return false;
    }
    if (image.lengthSync() > 100000) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Image Size should be less than 100KB.");
      return false;
    }
    return true;
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
              : Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
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
                              ? FileImage(_image)
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
      ),
    );
  }
}
