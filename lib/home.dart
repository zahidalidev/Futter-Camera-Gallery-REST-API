import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/file_input.dart';

class Home extends StatefulWidget {
  @override
  Homepage createState() => Homepage();
}

class Homepage extends State<Home> {
  File imageFile;
  final picker = ImagePicker();
  String base64Image;
  String imageName;
  String imageType = '';
  String alertMessage = '';
  int imageSize = 0;
  bool flag = false;

  // pick and crop
  onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    final ImagePicker _picker = ImagePicker();
    File croppedImage;

    final pickedFile = await _picker.getImage(
      source: source,
    );

    if (pickedFile == null) {
      return;
    }

    final file = File(pickedFile.path);
    final jpg = ImageSizeGetter.isJpg(FileInput(file));
    final webp = ImageSizeGetter.isWebp(FileInput(file));
    final gif = ImageSizeGetter.isGif(FileInput(file));

    String type = jpg
        ? 'jpg'
        : webp
            ? "webp"
            : gif
                ? 'gif'
                : 'png';

    if (jpg || webp || gif) {
      croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.white,
          toolbarTitle: "Flutter Cropper",
        ),
      );
      int imgSize = (croppedImage.lengthSync() / 1024).round();

      setState(() {
        alertMessage = '';
        imageFile = croppedImage ?? imageFile;
        imageSize = imgSize;
        imageType = type;
      });

      if (imgSize > 200) {
        setState(() {
          alertMessage =
              'Image Size is greater then 200kb please compress the Image';
        });
      } else {
        alertMessage = '';
      }
    } else {
      setState(() {
        alertMessage = 'Only jpg, webp and gif images are alowed';
        imageType = type;
      });
    }
  }

  // sending image to server
  Future sendImage() async {
    if (imageFile != null) {
      base64Image = base64Encode(imageFile.readAsBytesSync());
      imageName = imageFile.path.split('/').last;
      final apiURL = Uri.parse('https://pcc.edu.pk/ws/file_upload.php');
      http.post(apiURL, body: {
        "image": base64Image,
        "name": imageName,
      }).then((res) {
        var result = jsonDecode(res.body);
        print(result);
        setState(() {
          alertMessage = result['message'];
        });
      }).catchError((onError) => setState(() {
            alertMessage = 'Error uploading the image';
          }));
    } else {
      setState(() {
        alertMessage = 'Select An Image First';
      });
    }
  }

  // Compress image
  Future compressAndGetFile() async {
    if (imageFile == null) {
      setState(() {
        alertMessage = 'Select An Image First';
      });
      return;
    }
    final filePath = imageFile.absolute.path;
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    File result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      outPath,
      quality: 1,
    );

    setState(() {
      imageFile = result;
      imageSize = (result.lengthSync() / 1024).round();
    });

    int imgSize = (result.lengthSync() / 1024).round();
    if (imgSize > 200) {
      setState(() {
        alertMessage =
            'Image Size is greater then 200kb please compress the Image';
      });
    } else {
      alertMessage = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 100),
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Container(
                    width: 300,
                    margin: EdgeInsets.only(bottom: 20),
                    child: Container(
                      child: Text(
                        alertMessage != '' ? '* $alertMessage' : '',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.red),
                      ),
                    ),
                  ),
                  Container(
                    child: InkWell(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Column(
                            children: [
                              if (imageFile != null) ...[
                                Image.file(
                                  imageFile,
                                  height: 200,
                                  width: 200,
                                )
                              ] else ...[
                                Image.network(
                                  'https://i.pinimg.com/originals/d7/7e/2c/d77e2cc708655672d9313f87689c9cb2.gif',
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
                                  fontSize: 20,
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
                                    size: 22,
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
                                    size: 22,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                        imageSize != 0
                            ? 'Image Size: ${imageSize.toString()} kb'
                            : '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(imageType != '' ? 'Image Type: $imageType' : '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        margin: EdgeInsets.only(left: 10, top: 20, bottom: 20),
                        child: ElevatedButton(
                          child: Text('Clear',
                              style: TextStyle(
                                fontSize: 20,
                              )),
                          style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.blueAccent),
                          onPressed: () {
                            setState(() {
                              alertMessage = '';
                              imageSize = 0;
                              imageType = '';
                              imageFile = null;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 100,
                        margin: EdgeInsets.only(left: 10, top: 20, bottom: 20),
                        child: ElevatedButton(
                          child: Text('Upload',
                              style: TextStyle(
                                fontSize: 20,
                              )),
                          style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.blueAccent),
                          onPressed: () async {
                            await sendImage();
                          },
                        ),
                      ),
                      Container(
                        width: 110,
                        margin: EdgeInsets.only(left: 10, top: 20, bottom: 20),
                        child: ElevatedButton(
                          child: Text('Compress',
                              style: TextStyle(
                                fontSize: 20,
                              )),
                          style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.blueAccent),
                          onPressed: () async {
                            await compressAndGetFile();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
