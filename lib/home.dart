import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  Homepage createState() => Homepage();
}

class Homepage extends State<Home> {
  File _imageFile;
  final picker = ImagePicker();
  String base64Image;
  String imageName;
  String msg = '';
  bool flag = false;

  // pick and crop
  onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    final ImagePicker _picker = ImagePicker();
    File val;

    final pickedFile = await _picker.getImage(
      source: source,
    );

    val = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxHeight: 700,
      maxWidth: 700,
      compressFormat: ImageCompressFormat.jpg,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.white,
        toolbarTitle: "zahid cropper",
      ),
    );

    setState(() {
      msg = '';
      _imageFile = val ?? _imageFile;
    });
    print("cropper ${val.runtimeType}");
    print(val);
  }

  // sending image to server
  Future sendImage() async {
    if (_imageFile != null) {
      base64Image = base64Encode(_imageFile.readAsBytesSync());
      imageName = _imageFile.path.split('/').last;
      final apiURL = Uri.parse('https://pcc.edu.pk/ws/file_upload.php');
      http.post(apiURL, body: {
        "image": base64Image,
        "name": imageName,
      }).then((res) {
        var result = jsonDecode(res.body);
        print(result);
        setState(() {
          msg = result['message'];
        });
      }).catchError((onError) => setState(() {
            msg = 'Error uploading the image';
          }));
    } else {
      setState(() {
        msg = 'Select An Image First';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 50),
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: InkWell(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Column(
                            children: [
                              if (_imageFile != null) ...[
                                Image.file(_imageFile, height: 200, width: 200)
                              ] else ...[
                                Image.network(
                                  'https://i.pinimg.com/originals/bc/aa/d0/bcaad00d4bf16fd94bc45665ddad18e9.jpg',
                                  height: 200,
                                  width: 200,
                                ),
                              ],
                            ],
                          )),
                      onTap: () async {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text(
                                'Choose an option',
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                              content: Text('Camera or Gallery'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    onImageButtonPressed(
                                      ImageSource.camera,
                                      context: context,
                                    );
                                    // await _pickImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.photo_camera,
                                    size: 20,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    onImageButtonPressed(
                                      ImageSource.gallery,
                                      context: context,
                                    );
                                    // await _pickImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.image,
                                    size: 20,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 100,
                          margin:
                              EdgeInsets.only(left: 30, top: 20, bottom: 20),
                          child: ElevatedButton(
                            child: Text('Clear',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent[700],
                                onPrimary: Colors.white,
                                elevation: 3,
                                shadowColor: Colors.blueAccent),
                            onPressed: () {
                              setState(() {
                                msg = '';
                                _imageFile = null;
                              });
                            },
                          )),
                      Container(
                          width: 100,
                          margin: EdgeInsets.only(
                              left: 10, top: 20, bottom: 20, right: 30),
                          child: ElevatedButton(
                            child: Text('Upload',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent[700],
                                onPrimary: Colors.white,
                                elevation: 3,
                                shadowColor: Colors.blueAccent),
                            onPressed: () async {
                              await sendImage();
                            },
                          ))
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(msg != '' ? '$msg' : '',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
