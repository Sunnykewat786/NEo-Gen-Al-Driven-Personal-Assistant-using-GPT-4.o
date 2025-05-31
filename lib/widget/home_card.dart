import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../model/home_type.dart';
import '../helper/pref.dart'; // Import Pref to check Grid/List Mode
import 'package:get/get.dart';

/// A widget that displays a card on the home screen, representing a feature.
class HomeCard extends StatelessWidget {
  final HomeType homeType; // The type of home screen feature this card represents.

  const HomeCard({super.key, required this.homeType});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final RxBool isGridMode =
        Pref.isGridMode.obs; // Check if Grid Mode is enabled, and make it reactive.

    print(
        'HomeCard build called for ${homeType.title}, isGridMode: $isGridMode'); // Debug

    // Use Obx to rebuild only when isGridMode changes.
    return Obx(() {
      return isGridMode.value
          ? _buildGridCard(screenSize)
          : _buildListCard(screenSize);
    });
  }

  /// Builds a card for displaying in list mode.
  Widget _buildListCard(Size screenSize) {
    print('Building List Card for ${homeType.title}'); // Debug
    return Card(
      color: Colors.blue.withOpacity(0.2), // Semi-transparent blue.
      elevation: 0, // No shadow.
      margin: EdgeInsets.only(
          bottom: screenSize.height *
              0.02), // Add margin only to the bottom for spacing.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners.
      ),
      child: InkWell(
        // Wraps the card in an InkWell for tap effect.
        borderRadius: BorderRadius.circular(20), // Ensure InkWell has same radius.
        onTap: homeType.onTap, // Navigate to the feature's screen on tap.
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15), // Padding inside the card for content spacing.
          child: Row(
            // Use a Row to layout Lottie and text horizontally.
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space them apart.
            crossAxisAlignment:
                CrossAxisAlignment.center, // Vertically center items.
            children: homeType.leftAlign
                ? _buildLeftAligned(
                    screenSize) // Build layout with Lottie on the left.
                : _buildRightAligned(
                    screenSize), // Or Lottie on the right.
          ),
        ),
      ),
    );
  }

  /// Builds a card for displaying in grid mode.
  Widget _buildGridCard(Size screenSize) {
    print('Building Grid Card for ${homeType.title}'); // Debug
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15)), // Rounded corners for the card.
      color: Colors.blue.withOpacity(0.2), // Semi-transparent blue.
      elevation: 4, // Add a slight shadow for depth.
      child: InkWell(
        borderRadius: BorderRadius.circular(15), // Ensure InkWell has same radius.
        onTap: homeType
            .onTap, // Navigate to the feature's screen on tap, same as list.
        child: Column(
          // Use a Column to stack Lottie and text vertically.
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically.
          children: [
            Expanded(
              // Lottie takes up available space.
              child: Padding(
                padding: const EdgeInsets.all(
                    10.0), // Padding around the Lottie animation.
                child: Lottie.asset(
                  'assets/lottie/${homeType.lottie}', // Use the Lottie animation.
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error,
                          color: Colors
                              .red), // Show an error icon if Lottie fails to load.
                ),
              ),
            ),
            Container(
              // Container for the text below the Lottie animation.
              width: double.infinity, // Full width of the card.
              padding: const EdgeInsets.symmetric(
                  vertical:
                      10), // Vertical padding for the text container.
              alignment: Alignment.center, // Center the text.
              color: Colors.blue.withOpacity(
                  0.2), // Same background color as the card.
              child: Text(
                homeType.title, // Display the feature title.
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold), // Style the title text.
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the layout for when the Lottie animation is on the left.
  List<Widget> _buildLeftAligned(Size screenSize) {
    print('Building Left Aligned layout for ${homeType.title}');
    return [
      _buildLottie(screenSize), // Lottie on the left.
      Expanded(
        // Title takes up the remaining space.
        child: Text(
          homeType.title, // Display the feature title.
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ),
    ];
  }

  /// Builds the layout for when the Lottie animation is on the right.
  List<Widget> _buildRightAligned(Size screenSize) {
    print('Building Right Aligned layout for ${homeType.title}');
    return [
      Expanded(
        // Title takes up the remaining space.
        child: Text(
          homeType.title, // Display the feature title.
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ),
      _buildLottie(screenSize), // Lottie on the right.
    ];
  }

  /// Builds the Lottie animation widget.
  Widget _buildLottie(Size screenSize) {
    return Container(
      width: screenSize.width *
          0.35, // Lottie width relative to screen width.
      padding:
          homeType.padding, // Use the padding defined for this HomeType.
      child: Lottie.asset(
        'assets/lottie/${homeType.lottie}', // Load Lottie animation from assets.
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error,
                color: Colors
                    .red), // Show an error icon if the animation fails to load.
      ),
    );
  }
}

