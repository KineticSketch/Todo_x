import 'dart:convert';
import 'dart:io';

class DataTransferHelper {
  static String exportToJson(List<Map<String, dynamic>> data) {
    return jsonEncode(data);
  }

  static List<Map<String, dynamic>> importFromJson(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static String generateQrData(String jsonString) {
    final bytes = utf8.encode(jsonString);
    final compressed = GZipCodec().encode(bytes);
    return base64Encode(compressed);
  }

  static String parseQrData(String qrData) {
    final compressed = base64Decode(qrData);
    final bytes = GZipCodec().decode(compressed);
    return utf8.decode(bytes);
  }
}
