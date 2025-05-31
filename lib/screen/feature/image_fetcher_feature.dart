import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../controller/image_fetcher_controller.dart';

class ImageFetcherFeature extends StatelessWidget {
  final ImageFetcherController _controller = Get.put(ImageFetcherController());

  ImageFetcherFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Fetcher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Get.dialog(
              AlertDialog(
                title: const Text('Image Search'),
                content: const Text(
                    'Search for images using keywords. Tap any image to view details.'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Search images',
                      hintText: 'e.g. "cat with hat"',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            _controller.descriptionController.clear(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.descriptionController.text.isNotEmpty) {
                      _controller
                          .fetchImages(_controller.descriptionController.text);
                    } else {
                      Get.snackbar('Error', 'Please enter a search term');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Loading images...'),
                    ],
                  ),
                );
              }

              if (_controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 50, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(
                        _controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _controller.fetchImages(
                            _controller.descriptionController.text),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (_controller.images.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/hand_upwards.json',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      const Icon(Icons.image_search,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter a search term to find images',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _controller
                    .fetchImages(_controller.descriptionController.text),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _controller.images.length,
                  itemBuilder: (context, index) {
                    final image = _controller.images[index];
                    return GestureDetector(
                      onTap: () => Get.to(() => ImageDetailView(image: image)),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image['urls']['small'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 30),
                                  SizedBox(height: 5),
                                  Text('Failed to load',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ImageDetailView extends StatefulWidget {
  final Map<String, dynamic> image;

  const ImageDetailView({super.key, required this.image});

  @override
  State<ImageDetailView> createState() => _ImageDetailViewState();
}

class _ImageDetailViewState extends State<ImageDetailView> {
  bool _showFullDescription = false;
  bool _isDownloading = false;
  bool _isSharing = false;

  Future<void> _downloadImage(String url) async {
    try {
      setState(() => _isDownloading = true);

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar('Error', 'Storage permission required');
        return;
      }

      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/image_$timestamp.jpg';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes);

      final mediaStore = MediaStore();
      final result = await mediaStore.saveFile(
        tempFilePath: tempFilePath,
        dirType: DirType.photo,
        dirName: DirName.dcim,
        relativePath: 'NeoAI',
      );

      if (result != null) {
        Get.snackbar('Success', 'Image saved to gallery',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to save image',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Download failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _shareImage(String url) async {
    try {
      setState(() => _isSharing = true);
      await Share.share(
        'Check out this amazing image from Neo AI Assistant: $url',
        subject: 'AI Generated Image',
      );
    } catch (e) {
      Get.snackbar('Error', 'Sharing failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final description =
        widget.image['description'] ?? 'No description available';
    final shouldShowExpand = description.length > 50;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowExpand && !_showFullDescription)
              Text(
                '${description.substring(0, 50)}...',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 14),
              ),
            if (!shouldShowExpand || _showFullDescription)
              Text(
                description,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 14),
              ),
          ],
        ),
        actions: [
          if (shouldShowExpand)
            IconButton(
              icon: Icon(
                _showFullDescription ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
            ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: () =>
            setState(() => _showFullDescription = !_showFullDescription),
        child: Center(
          child: InteractiveViewer(
            maxScale: 5.0,
            child: Image.network(
              widget.image['urls']['regular'],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 50, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load image\n${error.toString()}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'download',
            onPressed: _isDownloading
                ? null
                : () => _downloadImage(widget.image['urls']['full']),
            child: _isDownloading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.download),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'share',
            onPressed: _isSharing
                ? null
                : () => _shareImage(widget.image['urls']['full']),
            child: _isSharing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}