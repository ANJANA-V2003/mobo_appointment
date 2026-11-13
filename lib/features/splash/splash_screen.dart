import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobo_appointment_project/core/constants/user_role.dart';
import 'package:mobo_appointment_project/core/providers/role_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  Timer? _safetyTimer;

  bool _isVideoInitialized = false;
  bool _isSplashComplete = false;
  bool _isRestoreComplete = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _startSafetyTimer();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreUserSession();
    });
  }

  Future<void> _restoreUserSession() async {
    await context.read<AuthProvider>().restoreSession();

    if (!mounted) return;

    _isRestoreComplete = true;

    _navigateBasedOnSession();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/splash/splash-video.mp4',
      );

      _videoController = controller;

      await controller.initialize().timeout(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isVideoInitialized = true;
      });

      controller.addListener(_checkVideoCompletion);

      await controller.play();
    } catch (e) {
      debugPrint('Splash video error: $e');
    }
  }

  void _checkVideoCompletion() {
    final controller = _videoController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.position >= controller.value.duration &&
        controller.value.duration > Duration.zero) {
      _finishSplash();
    }
  }

  void _startSafetyTimer() {
    _safetyTimer = Timer(const Duration(seconds: 3), _finishSplash);
  }

  void _finishSplash() {
    if (_isSplashComplete || !mounted) return;

    _isSplashComplete = true;
    _safetyTimer?.cancel();

    _navigateBasedOnSession();
  }

  Future<void> _navigateBasedOnSession() async {
    if (!mounted ||
        !_isSplashComplete ||
        !_isRestoreComplete ||
        _hasNavigated) {
      return;
    }

    _hasNavigated = true;

    final authProvider = context.read<AuthProvider>();

    // Module was missing in the previous login.
    if (authProvider.shouldOpenServerLogin) {
      context.goNamed(AppRoutes.serverLogin);
      return;
    }

    // Valid session and module installed.
    if (authProvider.isLoggedIn && authProvider.isModuleInstalled) {
      final client = authProvider.client;

      if (client == null) return;

      final roleProvider = context.read<RoleProvider>();
      await roleProvider.detectRole(client);

      if (!mounted) return;

      switch (roleProvider.role) {
        case UserRole.manager:
          context.goNamed(AppRoutes.dashboard);
          break;
        case UserRole.staff:
          context.go('/staff/dashboard');
          break;
        // case UserRole.customer:
        //   context.go('/customer/home');
        case null:
          break;
      }
      return;
    }

    // No active session.
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final hasSeenGetStarted = prefs.getBool('hasSeenGetStarted') ?? false;

    if (hasSeenGetStarted) {
      context.goNamed(AppRoutes.serverLogin);
    } else {
      context.goNamed(AppRoutes.getStarted);
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();

    _videoController?.removeListener(_checkVideoCompletion);
    _videoController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          const Center(child: Text('Splash')),

          Positioned.fill(child: Container(color: AppTheme.primaryColor)),

          if (_isVideoInitialized && _videoController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
        ],
      ),

    );
  }
}
