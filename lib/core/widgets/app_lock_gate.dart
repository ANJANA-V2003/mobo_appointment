import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();

  bool _isLocked = true;
  bool _isChecking = true;
  bool _isAuthenticating = false;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _checkAppLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Check whether App Lock is enabled.
  Future<void> _checkAppLock() async {
    if (_isAuthenticating) return;

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('biometric_app_lock') ?? false;

    if (!mounted) return;

    if (!enabled) {
      setState(() {
        _isLocked = false;
        _isChecking = false;
      });
      return;
    }

    await _authenticate();
  }

  // Authenticate and unlock the app.
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    _isAuthenticating = true;

    if (mounted) {
      setState(() {
        _isLocked = true;
        _isChecking = true;
      });
    }

    try {
      final authenticated = await _biometricService.authenticate();

      if (!mounted) return;

      setState(() {
        _isLocked = !authenticated;
        _isChecking = false;
      });
    } catch (e) {
      debugPrint('App lock authentication error: $e');

      if (mounted) {
        setState(() {
          _isLocked = true;
          _isChecking = false;
        });
      }
    } finally {
      _isAuthenticating = false;
    }
  }

  // Detect when the app moves to the background
  // and when it returns to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    }

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;

      if (!_isAuthenticating) {
        _checkAppLock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/login/loginbg.png", fit: BoxFit.cover),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.calendar02,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "mobo appointment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    'App Locked',
                    style: TextStyle(
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Please authenticate to continue',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 34),

                  if (_isChecking)
                    const CircularProgressIndicator()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(120, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    12,
                                  ),
                                ),
                              ),
                              onPressed: _authenticate,
                              child: const Text(
                                'Try Again',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
