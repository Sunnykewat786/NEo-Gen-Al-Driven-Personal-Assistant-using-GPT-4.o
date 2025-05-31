import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;       // Correct web import
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';

import '../apis/apis.dart';
import '../helper/my_dialog.dart';

enum Status { none, loading, complete }

class ImageController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final Rx<Status> status = Status.none.obs;
  final RxString imagePath = ''.obs;
  final http.Client _client = http.Client();

  @override
  void onClose() {
    textC.dispose();
    _client.close();
    super.onClose();
  }

  Future<void> searchAiImage() async {
    final prompt = textC.text.trim();
    if (prompt.isEmpty) {
      MyDialog.error('Please describe the image you want to create');
      return;
    }

    status.value = Status.loading;
    imagePath.value = '';

    try {
      final path = await APIs.generateStableDiffusionImage(prompt);
      imagePath.value = path;
      status.value = Status.complete;
      MyDialog.success('Image created successfully!');
    } catch (e) {
      status.value = Status.none;
      if (e.toString().contains('Credit limit exceeded')) {
        MyDialog.error('You\'ve used all 25 free images this month');
      } else if (e is SocketException) {
        MyDialog.error('No internet connection');
      } else {
        MyDialog.error('Failed to generate image: ${e.toString()}');
      }
    }
  }

  Future<void> downloadImage() async {
    if (imagePath.value.isEmpty) {
      return MyDialog.error('No image to download!');
    }
    if (kIsWeb) {
      await _downloadWeb();
    } else {
      await _downloadNative();
    }
  }

  Future<void> _downloadWeb() async {
    try {
      MyDialog.showLoadingDialog();
      final response = await http.get(Uri.parse(imagePath.value));
      if (response.statusCode != 200) {
        throw Exception('Failed to load image');
      }
      final bytes = response.bodyBytes;
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = url;
      anchor.download = 'neo_ai_image_${DateTime.now().millisecondsSinceEpoch}.png';
      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      Get.back();
      MyDialog.success('Image download started!');
    } catch (e) {
      Get.back();
      log('downloadWeb error: $e');
      MyDialog.error('Error downloading on web: ${e.toString()}');
    }
  }

  Future<void> _downloadNative() async {
    try {
      MyDialog.showLoadingDialog();
      final file = File(imagePath.value);
      if (!await file.exists()) {
        Get.back();
        return MyDialog.error('Image file not found!');
      }

      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        Get.back();
        return MyDialog.error('Storage permission denied');
      }

      final mediaStore = MediaStore();
      final result = await mediaStore.saveFile(
        tempFilePath: file.path,
        dirType: DirType.photo,
        dirName: DirName.dcim,
        relativePath: 'NeoAI',
      );

      Get.back();
      if (result != null) {
        MyDialog.success('Image saved to gallery!');
      } else {
        MyDialog.error('Failed to save image.');
      }
    } catch (e) {
      Get.back();
      log('downloadNative error: $e');
      MyDialog.error('Error: ${e.toString()}');
    }
  }

  Future<void> shareImage() async {
    if (imagePath.value.isEmpty) return MyDialog.error('No image to share!');

    try {
      MyDialog.showLoadingDialog();
      final file = File(imagePath.value);

      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'AI Generated Image from Neo Assistant',
        );
        MyDialog.success('Image shared!');
      } else {
        MyDialog.error('Image file not found!');
      }
    } catch (e) {
      log('shareImage error: $e');
      MyDialog.error('Error sharing: ${e.toString()}');
    } finally {
      Get.back();
    }
  }
}