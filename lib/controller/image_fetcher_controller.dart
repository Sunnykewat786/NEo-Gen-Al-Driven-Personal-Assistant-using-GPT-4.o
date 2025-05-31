import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageFetcherController extends GetxController {
  final RxList<Map<String, dynamic>> images = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final TextEditingController descriptionController = TextEditingController();
  final int imagesPerPage = 30; // Set to 50 images
  final String unsplashAccessKey =
      'ANG437nDwzh5-igUMBsOjlAA9C9gBkTLmCHs4iV2xdo';

  Future<void> fetchImages(String description) async {
    try {
      isLoading(true);
      errorMessage('');
      images.clear();

      final encodedQuery = Uri.encodeComponent(description);
      final response = await http
          .get(
            Uri.parse(
                'https://api.unsplash.com/search/photos?query=$encodedQuery&per_page=$imagesPerPage&client_id=$unsplashAccessKey'),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        if (results.length < imagesPerPage) {
          Get.snackbar('Info', 'Only ${results.length} images available');
        }

        images.value = List<Map<String, dynamic>>.from(results.map((item) => ({
              'id': item['id'],
              'urls': item['urls'],
              'description': item['description'] ??
                  item['alt_description'] ??
                  'No description',
              'source': 'Unsplash',
            })));
      } else {
        errorMessage('API Error: ${response.statusCode}');
        Get.snackbar(
            'Error', 'Failed to fetch images. Status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage('Error: ${e.toString()}');
      Get.snackbar('Error', 'Failed to connect to Unsplash API');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}