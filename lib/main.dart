import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upload_image_s3/custom_dialog.dart';
import 'package:upload_image_s3/gallery_item.dart';
import 'package:upload_image_s3/generate_image_url.dart';
import 'package:upload_image_s3/uploadfile.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

const Color kErrorRed = Colors.redAccent;
const Color kDarkGray = Color(0xFFA3A3A3);
const Color kLightGray = Color(0xFFF1F0F5);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

enum PhotoSource { FILE, NETWORK }

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ImagePickerWidget();
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> _photos = [];
  List<String> _photosUrls = [];
  List<PhotoSource> _photosSources = [];

  List<GalleryItem> _galleryItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddPhoto();
                }
                File image = _photos[index - 1];
                PhotoSource source = _photosSources[index - 1];
                return Stack(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.all(5),
                        height: 100,
                        width: 100,
                        color: kLightGray,
                        child: source == PhotoSource.FILE
                            ? Image.file(image)
                            : Image.network(_photosUrls[index - 1]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text('Save'),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  _buildAddPhoto() {
    return InkWell(
      onTap: () => _onAddPhotoClicked(context),
      child: Container(
        margin: EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: kDarkGray,
        child: Center(
          child: Icon(
            Icons.add_to_photos,
            color: kLightGray,
          ),
        ),
      ),
    );
  }

  _onAddPhotoClicked(context) async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      String fileExtension = path.extension(image.path);

      _galleryItems.add(
        GalleryItem(
            id: Uuid().v1(),
            resource: image.path,
            isSvg: fileExtension.toLowerCase() == ".svg",
        ),
      );

      setState(() {
        _photos.add(File(image.path));
        _photosSources.add(PhotoSource.FILE);
      });

      //Changes started
      GenerateImageUrl generateImageUrl = GenerateImageUrl();
      await generateImageUrl.call(fileExtension);

      String uploadUrl;
      if (generateImageUrl.isGenerated != null) {
        uploadUrl = generateImageUrl.uploadUrl.toString();
      } else {
        throw generateImageUrl.message.toString();
      }
      bool isUploaded = await uploadFile(context, uploadUrl, File(image.path));
      if (isUploaded) {
        setState(() {
          _photosUrls.add(generateImageUrl.downloadUrl.toString());
        });
      }

    }
  }

  Future<bool> uploadFile(context, String url, File image) async {
  try {
    UploadFile uploadFile = UploadFile();
    await uploadFile.call(url, image);

    if (uploadFile.isUploaded != null) {
      return true;
    } else {
      throw uploadFile.message.toString();
    }
  } catch (e) {
    throw e;
  }
}

  _showOpenAppSettingsDialog(context) {
  return CustomDialog.show(
    context,
    'Permission needed',
    'Photos permission is needed to select photos',
    'Open settings',
    openAppSettings,
  );
}
}
