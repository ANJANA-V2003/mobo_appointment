import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routing/app_routes.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  int currentIndex = 0;

  static const Color primaryColor = Color(0xFFC03355);
  static const Color backgroundColor = Color(0xFF64182B);

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Your Appointments, All in One Place',
      'description':
          'Book appointments, manage schedules, and keep everything organized effortlessly.',
    },
    {
      'title': 'Stay on Top of Your Schedule',
      'description':
          'Track upcoming appointments and manage your day with ease.',
    },
    {
      'title': 'Simple. Organized. Efficient.',
      'description':
          'Everything you need to manage appointments, right at your fingertips.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider.builder(
            itemCount: onboardingData.length,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return Image.asset(
                "assets/get_started/${index + 1}.jpg", // image is temporary change it
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              );
              //   Container(
              //   width: double.infinity,
              //   color: backgroundColor,
              //   child: Center(
              //     // replace with the image
              //     child: Icon(
              //       Icons.image_outlined,
              //       size: 90,
              //       color: Colors.white.withValues(alpha: 0.4),
              //     ),
              //   ),
              // );
            },
          ),

          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),

                  Text(
                    onboardingData[currentIndex]['title']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.35,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    onboardingData[currentIndex]['description']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();

                        await prefs.setBool('hasSeenGetStarted', true);

                        if (!context.mounted) return;

                        context.goNamed(AppRoutes.serverLogin);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Page indicators
                  DotsIndicator(
                    dotsCount: onboardingData.length,
                    position: currentIndex.toDouble(),
                    decorator: DotsDecorator(
                      activeColor: Colors.white,
                      color: Colors.white38,
                      size: const Size(10, 10),
                      activeSize: const Size(28, 10),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      spacing: const EdgeInsets.symmetric(horizontal: 5),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
