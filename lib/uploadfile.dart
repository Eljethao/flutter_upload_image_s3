import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadFile {
  bool? success;
  String? message;

  bool? isUploaded;

  Future<void> call(String url, File image) async {
    try {
      var _url = Uri.parse(url);
      var response = await http.put(_url, body: image.readAsBytesSync());
      print("response: ${response.body}}");
      if (response.statusCode == 200) {
        isUploaded = true;
      }
    } catch (e) {
      print("error: $e");
      throw ('Error uploading photo');
    }
  }
}