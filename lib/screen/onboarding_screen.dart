import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:neo_ai_assistant/widget/custom_btn.dart'; // Import custom button widget

import '../model/onboard.dart'; // Import the Onboard model class
import 'home_screen.dart'; // Import the home screen

/// The onboarding screen displayed on the first app launch.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('OnboardingScreen build called'); // Print statement for debugging

    // Initialize PageController to manage page navigation.
    final PageController controller = PageController();

    // List of Onboard data for each onboarding page.
    final List<Onboard> onboardingList = [
      const Onboard(
          title: 'Ask me Anything',
          subtitle:
              'I can be your Best Friend & You can ask me anything & I will help you!',
          lottie: 'ai_ask_me'),
      const Onboard(
          title: 'Imagination to Reality',
          subtitle:
              'Just Imagine anything & let me know, I will create something wonderful for you!',
          lottie: 'ai_play'),
      const Onboard(
          title: 'Language Translation',
          subtitle:
              'Just think a sentence & let me know, I will translate to any language you want!',
          lottie: 'ai_translate'),
      const Onboard(
          title: 'Note Taking',
          subtitle: 'Easily take and manage your notes anytime.',
          lottie: 'note_taking'),
      const Onboard(
          title: 'Calendar To-Do',
          subtitle: 'Keep track of your daily tasks efficiently.',
          lottie: 'calendar_animation'),
      const Onboard(
          title: 'Smart Summarizer',
          subtitle: 'Just just a text & I will Summarize',
          lottie: 'ai_404_robot'),
    ];

    // Splitting onboarding into 2 pages (3 items per page).  This is done to control the layout of the onboarding cards.
    final List<List<Onboard>> pages = [
      onboardingList.sublist(0, 3), // First page with the first 3 items
      onboardingList.sublist(3, 6), // Second page with the last 2 items
    ];

    return Scaffold(
      body: PageView.builder(
        controller:
            controller, // Assign the PageController to the PageView.builder.
        itemCount:
            pages.length, // Set the number of pages based on the 'pages' list.
        itemBuilder: (context, index) {
          print(
              'PageView.builder itemBuilder called for index: $index'); // Print index
          // Check if it is the last page.
          final bool isLastPage = index == pages.length - 1;

          // Build the content for each page.
          return Column(
            children: [
              const SizedBox(height: 50),

              // Onboarding Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pages[index]
                      .length, // Number of items on the current page
                  itemBuilder: (context, i) {
                    final Onboard item = pages[index]
                        [i]; // Get the Onboard item for the current index.
                    print(
                        'ListView.builder itemBuilder called for item: ${item.title}');
                    // Build the UI for each onboarding item.
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors
                            .blueGrey[100], // Background color for the card
                        borderRadius: BorderRadius.circular(
                            15), // Rounded corners for the card
                        boxShadow: [
                          // Add a shadow to the card for a lifted effect
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Lottie Animation
                          Lottie.asset(
                            'assets/lottie/${item.lottie}.json', // Load Lottie animation
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(width: 20),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the start
                              children: [
                                Text(
                                  item.title, // Display the title
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.subtitle, // Display the subtitle
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Dots Indicator.  Visual indicator of the current page.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length, // Generate dots for the number of pages
                  (i) => AnimatedContainer(
                    // Animate the size and color of the dot.
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i == index ? 15 : 10, // Active dot is wider
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == index
                          ? Colors.blue
                          : Colors.grey, // Active dot is blue, inactive is grey
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners for the dots
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Next / Finish Button
              CustomBtn(
                onTap: () {
                  print(
                      'Button tapped. isLastPage: $isLastPage, currentPage: $index');
                  // Navigate to the next page or finish onboarding.
                  if (isLastPage) {
                    Get.off(() =>
                        const HomeScreen()); // Go to home screen and remove onboarding from history
                  } else {
                    controller.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve:
                            Curves.ease); // Go to the next page with animation
                  }
                },
                text: isLastPage ? 'Finish' : 'Next', // Change button text
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
