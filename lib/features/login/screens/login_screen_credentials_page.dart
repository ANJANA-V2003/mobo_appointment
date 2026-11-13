import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_appointment_project/core/constants/user_role.dart';
import 'package:mobo_appointment_project/core/providers/role_provider.dart';
import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/login/models/login_model.dart';
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';
import 'package:mobo_appointment_project/shared/widgets/form/app_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreenCredentialsPage extends StatefulWidget {
  final String serverUrl;
  final String database;

  LoginScreenCredentialsPage({
    super.key,
    required this.serverUrl,
    required this.database,
  });

  @override
  State<LoginScreenCredentialsPage> createState() =>
      _LoginScreenCredentialsPageState();
}

class _LoginScreenCredentialsPageState
    extends State<LoginScreenCredentialsPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _showErrorIcon = false;

  bool obscure = true;

  void _showModuleNotInstalledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final authProvider = context.watch<AuthProvider>();

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.alertCircle,
                    color: AppTheme.primaryColor,
                    size: 22,
                    strokeWidth: 2,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Module Missing',
                    style: TextStyle(
                      fontFamily: GoogleFonts.manrope().fontFamily,
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  authProvider.moduleError ??
                      'The required "Appointment" module is not installed. '
                          'Please contact your administrator to enable it.',
                  style: TextStyle(
                    fontFamily: GoogleFonts.manrope().fontFamily,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          fixedSize: const Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontFamily: GoogleFonts.manrope().fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> handleLogin() async {
    setState(() {
      _showErrorIcon = true;
    });

    if (!formKey.currentState!.validate()) {
      return;
    }

    final credentials = LoginModel(
      userName: emailController.text.trim(),
      password: passwordController.text,
    );

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      serverUrl: widget.serverUrl,
      database: widget.database,
      credentials: credentials,
    );

    if (!mounted) return;

    if (!success) return;

    final client = authProvider.client;

    if (client == null) return;

    // Step 1: Detect the logged-in user's role.
    final roleProvider = context.read<RoleProvider>();

    await roleProvider.detectRole(client);

    if (!mounted) return;

    // Step 2: Navigate according to the role.
    switch (roleProvider.role) {
      // case UserRole.customer:
      //   context.go('/customer/home');
      //   break;

      case UserRole.manager:
        context.goNamed(AppRoutes.dashboard);
        break;
      case UserRole.staff:
        context.go('/staff/dashboard');
        break;

        // Only internal users need the backend module check.
        await authProvider.checkAppointmentModule();

        if (!mounted) return;

        if (authProvider.isModuleInstalled) {
          if (roleProvider.role == UserRole.manager) {
            context.goNamed(AppRoutes.dashboard);
          } else {
            context.go('/staff/dashboard');
          }
        } else {
          _showModuleNotInstalledDialog();
        }
        break;

      case null:
        break;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.primaryColor,
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Stack(
          children: [
            Image.asset("assets/login/loginbg.png", fit: BoxFit.cover),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: HugeIcon(
                    icon: HugeIconsStrokeRounded.chevronLeft,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.goNamed(AppRoutes.serverLogin);
                  },
                ),
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
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

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 4),

                Expanded(
                  flex: 7,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final keyboardHeight = MediaQuery.viewInsetsOf(
                        context,
                      ).bottom;
                      return AnimatedPadding(
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        duration: Duration(milliseconds: 200),

                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sign In",
                                style: TextStyle(
                                  fontFamily: GoogleFonts.manrope().fontFamily,
                                  color: AppTheme.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Enter your credentials to continue",
                                style: TextStyle(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                  color: Color(0xbffafafa),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 35),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: AppTextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  hintText: 'Email',
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required';
                                    }

                                    return null;
                                  },
                                  suffixIcon:
                                      _showErrorIcon &&
                                          emailController.text.trim().isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(13),
                                          child: HugeIcon(
                                            icon: HugeIconsStrokeRounded
                                                .alertCircle,
                                            color: Colors.red,
                                            size: 10,
                                          ),
                                        )
                                      : null,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedMail01,
                                      size: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: AppTextField(
                                  isObscure: obscure,
                                  onChanged: (value) {
                                    setState(() {});
                                  },

                                  suffixIcon:
                                      _showErrorIcon &&
                                          passwordController.text.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(13),
                                          child: HugeIcon(
                                            icon: HugeIconsStrokeRounded
                                                .alertCircle,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscure = !obscure;
                                            });
                                          },
                                          icon: obscure
                                              ? HugeIcon(
                                                  icon: HugeIconsStrokeRounded
                                                      .eyeClosed,
                                                  size: 20,
                                                  color: Colors.grey[800],
                                                )
                                              : HugeIcon(
                                                  icon: HugeIconsStrokeRounded
                                                      .view,
                                                  size: 20,
                                                  color: Colors.grey[800],
                                                ),
                                        ),
                                  controller: passwordController,
                                  hintText: 'Password',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedLockPassword,
                                      size: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(right: 40),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.manrope().fontFamily,
                                          color: Color(0xbffafafa),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 23),
                              if (authProvider.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 45,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      HugeIcon(
                                        icon:
                                            HugeIconsStrokeRounded.alertCircle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Login failed .Please check your credentials",
                                        // authProvider.errorMessage!,
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.manrope().fontFamily,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: authProvider.isLoading
                                            ? null
                                            : handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(120, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: authProvider.isLoading
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Signing In',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          GoogleFonts.manrope()
                                                              .fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  LoadingAnimationWidget.staggeredDotsWave(
                                                    color: Colors.white,
                                                    size: 25,
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      GoogleFonts.manrope()
                                                          .fontFamily,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
