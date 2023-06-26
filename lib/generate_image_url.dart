import 'dart:convert';

import 'package:http/http.dart' as http;

class GenerateImageUrl {
  bool? success;
  String? message;

  bool? isGenerated;
  String? uploadUrl;
  String? downloadUrl;

  Future<void> call(String fileType) async {
    try {
      Map body = {"fileType": fileType};
      var url = Uri.parse('http://192.168.110.249:5000/generatePresignedUrl');
      var response = await http.post(
        url,
        body: body,
      );

      var result = jsonDecode(response.body);
      print("result ===>>> $result");

      if (result['success'] != null) {
        success = result['success'];
        message = result['message'];

        if (response.statusCode == 201) {
          isGenerated = true;
          uploadUrl = result["uploadUrl"];
          downloadUrl = result["downloadUrl"];
        }
      }
    } catch (e) {
      print("error: ${e}");
      throw ('Error getting url');
    }
  }
}
