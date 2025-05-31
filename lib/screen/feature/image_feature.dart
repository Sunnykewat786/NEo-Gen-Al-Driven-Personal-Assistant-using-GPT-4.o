import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controller/image_controller.dart';
import '../../helper/global.dart';
import '../../widget/custom_btn.dart';
import '../../widget/custom_loading.dart';
import 'image_fetcher_feature.dart';

class ImageFeature extends StatefulWidget {
  const ImageFeature({super.key});

  @override
  State<ImageFeature> createState() => _ImageFeatureState();
}

class _ImageFeatureState extends State<ImageFeature> {
  final _c = Get.put(ImageController());

  Future<void> _handleImageGeneration() async {
    if (_c.status.value != Status.loading) {
      await _c.searchAiImage();
    }
  }

  @override
  void dispose() {
    Get.delete<ImageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size; // Screen dimensions
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Creator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_search),
            onPressed: () => Get.to(() => ImageFetcherFeature()),
          ),
          Obx(() => Visibility(
                visible:
                    _c.status.value == Status.complete && _c.imagePath.value.isNotEmpty,
                child: IconButton(
                  padding: const EdgeInsets.only(right: 6),
                  onPressed: _c.shareImage,
                  icon: const Icon(Icons.share),
                ),
              )),
        ],
      ),
      floatingActionButton: Obx(() => Visibility(
            visible:
                _c.status.value == Status.complete && _c.imagePath.value.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6),
              child: FloatingActionButton(
                onPressed: _c.downloadImage,  // 🔄 Updated to new unified method
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: const Icon(Icons.save_alt_rounded, size: 26),
              ),
            ),
          )),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.02,
        ),
        children: [
          TextFormField(
            controller: _c.textC,
            textAlign: TextAlign.center,
            minLines: 2,
            maxLines: null,
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              hintText:
                  'Imagine something wonderful & innovative\nType here & I will create for you 😃',
              hintStyle: TextStyle(fontSize: 13.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          SizedBox(height: mq.height * 0.015),
          Container(
            height: mq.height * 0.5,
            alignment: Alignment.center,
            child: _buildImageContent(mq),
          ),
          const SizedBox(height: 20),
          Obx(() => CustomBtn(
                onTap: _c.status.value == Status.loading
                    ? () {}
                    : () => _handleImageGeneration(),
                text: _c.status.value == Status.loading ? 'Creating...' : 'Create',
              )),
          SizedBox(height: mq.height * 0.015),
        ],
      ),
    );
  }

  Widget _buildImageContent(Size mq) {
    return Obx(() {
      switch (_c.status.value) {
        case Status.none:
          return Lottie.asset(
            'assets/lottie/ai_sit.json',
            height: mq.height * 0.3,
          );
        case Status.loading:
          return const CustomLoading();
        case Status.complete:
          return _c.imagePath.value.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_c.imagePath.value),
                    fit: BoxFit.cover,
                  ),
                )
              : const SizedBox.shrink();
      }
    });
  }
}