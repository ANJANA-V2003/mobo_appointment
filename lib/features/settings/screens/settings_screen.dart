import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:mobo_appointment_project/core/services/biometric_service.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/core/theme/theme_provider.dart';
import 'package:mobo_appointment_project/features/settings/widgets/cards/custom_card_1.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../login/provider/auth_provider.dart';
import '../models/currency_model.dart';
import '../models/language_model.dart';
import '../models/timezone_model.dart';
import '../providers/currency_provider.dart';
import '../providers/language_provider.dart';
import '../providers/timezone_provider.dart';
import '../widgets/buttons/biometric_switch.dart';
import '../widgets/buttons/social_button.dart';
import '../widgets/cards/custom_card_2.dart';
import '../widgets/cards/custom_card_3.dart';
import '../widgets/cards/custom_card_4.dart';
import '../widgets/cards/custom_card_5.dart';
import '../widgets/buttons/switch_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricEnabled = false;
  bool _isBiometricLoading = false;

  DateTime? _lastUpdated;
  bool _isRefreshing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsData();
      _loadBiometricSetting();
    });
  }

  Future<void> _loadSettingsData() async {
    final authProvider = context.read<AuthProvider>();

    final client = authProvider.client;
    final userId = authProvider.session?.userId;

    if (client == null || userId == null) return;

    await Future.wait([
      context.read<CurrencyProvider>().loadCurrencies(client),
      context.read<TimezoneProvider>().loadTimezones(client, userId),
      context.read<LanguageProvider>().loadLanguage(client, userId),
    ]);
  }

  Future<void> _refreshLanguageRegion() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadSettingsData();

      if (!mounted) return;

      setState(() {
        _lastUpdated = DateTime.now();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _launchUrlSmart(String url, {String? title}) async {
    final uri = Uri.parse(url);

    try {
      if (uri.scheme == 'mailto') {
        if (await canLaunchUrl(uri)) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (ok) return;
        }

        final fallback = Uri.parse('https://www.cybrosys.com/contact/');
        final fbOk = await launchUrl(
          fallback,
          mode: LaunchMode.externalApplication,
        );
        if (!fbOk) {
          final webOk = await launchUrl(
            fallback,
            mode: LaunchMode.inAppBrowserView,
          );
          if (!webOk && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open contact page.')),
            );
          }
        }
        return;
      }

      if (uri.scheme == 'http' || uri.scheme == 'https') {
        bool ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) {
          ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
        if (!ok && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not open link.')));
        }
        return;
      }

      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No app available to open this link.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link. ${e.toString()}')),
      );
    }
  }

  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_app_lock') ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (_isBiometricLoading) return;

    setState(() {
      _isBiometricLoading = true;
    });

    try {
      // Disabling App Lock
      if (!value) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_app_lock', false);

        if (!mounted) return;

        setState(() {
          _isBiometricEnabled = false;
        });

        return;
      }

      // Enabling App Lock
      final available = await _biometricService.isBiometricAvailable();

      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No enrolled biometrics found on this device.'),
            ),
          );
        }
        return;
      }

      final authenticated = await _biometricService.authenticate();

      if (!authenticated) return;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('biometric_app_lock', true);

      if (!mounted) return;

      setState(() {
        _isBiometricEnabled = true;
      });
    } on PlatformException catch (e) {
      debugPrint('Biometric error: ${e.message}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Biometric authentication failed.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.goNamed(AppRoutes.profile),
          icon: HugeIcon(icon: (HugeIconsStrokeRounded.chevronLeft)),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    CustomCard1(
                      icon: HugeIconsStrokeRounded.moon02,
                      title: "Appearance",
                      subtitle: "Dark Mode",
                      description: 'Switch between light and dark themes',
                      trailing: switch_toggle(themeProvider: themeProvider),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    custom_card_2(
                      context: context,
                      icon: HugeIconsStrokeRounded.fingerPrintScan,
                      title: "Security",
                      subtitle: "App Lock",
                      description:
                          'Biometric authentication '
                          'is available but disabled.',
                      trailing: biometric_switch(
                        isDark: isDark,
                        onChanged: (bool value) {
                          _toggleBiometric(value);
                        },
                        value: _isBiometricEnabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 420,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          child: const Text(
                            "Language & Region",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: IconButton(
                            tooltip: 'Refresh',
                            onPressed: _isRefreshing
                                ? null
                                : _refreshLanguageRegion,
                            icon: const Icon(Icons.refresh, size: 18),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    custom_card_3(
                      lastUpdated: _lastUpdated,
                      context: context,
                      icon: HugeIconsStrokeRounded.translate,
                      subtitle: "Language",
                      description: "Select your preferred language",
                      trailing: SizedBox(
                        width: 100,
                        child: SizedBox(
                          width: 100,
                          child: Consumer<LanguageProvider>(
                            builder: (context, provider, child) {
                              return DropdownButton<LanguageModel>(
                                value: provider.selectedLanguage,
                                isExpanded: true,
                                isDense: true,
                                underline: const SizedBox(),
                                iconSize: 18,
                                items: provider.selectedLanguage == null
                                    ? []
                                    : [
                                        DropdownMenuItem<LanguageModel>(
                                          value: provider.selectedLanguage,
                                          child: Text(
                                            provider.selectedLanguage!.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white
                                                  : AppTheme.primaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                onChanged: null,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 28),
                    custom_card_3(
                      lastUpdated: _lastUpdated,
                      context: context,
                      icon: HugeIcons.strokeRoundedDollar02,
                      subtitle: 'Currency',
                      description: 'Default currency for transactions.',
                      trailing: SizedBox(
                        width: 100,
                        child: Consumer<CurrencyProvider>(
                          builder: (context, provider, child) {
                            return DropdownButton<CurrencyModel>(
                              dropdownColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                              value: provider.selectedCurrency,
                              hint: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.primaryText,
                                ),
                              ),
                              underline: const SizedBox(),
                              isDense: true,
                              isExpanded: true,
                              iconSize: 18,

                              selectedItemBuilder: (context) {
                                return provider.currencies.map((currency) {
                                  return DropdownMenuItem<CurrencyModel>(
                                    value: currency,
                                    child: Text(
                                      currency.fullName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.manrope().fontFamily,
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.primaryText,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },

                              items: provider.currencies.map((currency) {
                                return DropdownMenuItem<CurrencyModel>(
                                  value: currency,
                                  child: Text(
                                    currency.fullName,
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.manrope().fontFamily,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.primaryText,
                                    ),
                                  ),
                                );
                              }).toList(),

                              onChanged: (currency) async {
                                if (currency == null) return;

                                await provider.changeCurrency(currency);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 28),

                    custom_card_3(
                      lastUpdated: _lastUpdated,
                      context: context,
                      icon: HugeIcons.strokeRoundedClock01,
                      subtitle: 'Timezone',
                      description: 'Your local timezone',
                      trailing: SizedBox(
                        width: 100,
                        child: Consumer<TimezoneProvider>(
                          builder: (context, provider, child) {
                            return DropdownButton<TimezoneModel>(
                              dropdownColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                              value: provider.selectedTimezone,
                              underline: const SizedBox(),
                              isDense: true,
                              isExpanded: true,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              hint: const Text(''),

                              selectedItemBuilder: (context) {
                                return provider.timezones.map((timezone) {
                                  return DropdownMenuItem<TimezoneModel>(
                                    value: timezone,
                                    child: Text(
                                      timezone.displayName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.manrope().fontFamily,
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.primaryText,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },

                              items: provider.timezones.map((timezone) {
                                return DropdownMenuItem<TimezoneModel>(
                                  value: timezone,
                                  child: Text(
                                    timezone.displayName,
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.manrope().fontFamily,
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.primaryText,
                                    ),
                                  ),
                                );
                              }).toList(),

                              onChanged: provider.isUpdating
                                  ? null
                                  : (timezone) async {
                                      if (timezone == null) return;

                                      final authProvider = context
                                          .read<AuthProvider>();

                                      final client = authProvider.client;
                                      final userId =
                                          authProvider.session?.userId;

                                      if (client == null || userId == null)
                                        return;

                                      final success = await provider
                                          .changeTimezone(
                                            client,
                                            userId,
                                            timezone,
                                          );

                                      if (!context.mounted) return;

                                      if (!success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to update timezone',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 290,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          child: Text(
                            "Help & Support",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              // color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    custom_card_4(
                      context: context,
                      icon: HugeIcons.strokeRoundedHelpCircle,
                      subtitle: "Odoo Help Center",
                      description: "Documentation, guides and resources",
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        size: 20,
                      ),
                      onTap: () => _launchUrlSmart(
                        'https://www.odoo.com/documentation/20.0/',
                      ),
                    ),
                    SizedBox(height: 28),
                    custom_card_4(
                      context: context,
                      icon: HugeIcons.strokeRoundedCustomerSupport,
                      subtitle: "Odoo Support",
                      description: "Create a ticket with Odoo Support",
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        size: 20,
                      ),
                      onTap: () =>
                          _launchUrlSmart('https://www.odoo.com/help '),
                    ),
                    SizedBox(height: 28),
                    custom_card_4(
                      context: context,
                      icon: HugeIcons.strokeRoundedUserGroup,
                      subtitle: "Odoo Community Forum",
                      description: "Ask the community for help",
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        size: 20,
                      ),
                      onTap: () =>
                          _launchUrlSmart('https://www.odoo.com/forum/help-1'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 530,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          child: Text(
                            "About",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              // color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    custom_card_5(
                      context: context,
                      icon: HugeIcons.strokeRoundedGlobe02,
                      subtitle: "Visit Website",
                      description: "www.cybrosys.com",
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                        ),
                      ),
                      onTap: () => _launchUrlSmart(
                        'https://www.cybrosys.com/',
                        title: 'Our Website',
                      ),
                    ),
                    SizedBox(height: 30),
                    custom_card_5(
                      context: context,
                      icon: HugeIcons.strokeRoundedMail01,
                      subtitle: "Contact Us",
                      description: "info@cybrosys",
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                        ),
                      ),
                      onTap: () => _launchUrlSmart('mailto:info@cybrosys.com'),
                    ),
                    SizedBox(height: 28),
                    custom_card_5(
                      context: context,
                      icon: HugeIcons.strokeRoundedPlayStore,
                      subtitle: "More Apps",
                      description: "View our other apps on Play Store",
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                        ),
                      ),
                      onTap: () => _launchUrlSmart(
                        'https://play.google.com/store/apps/dev?id=7163004064816759344',
                        title: 'Play Store',
                      ),
                    ),
                    SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.grey[300]),
                    ),
                    SizedBox(height: 25),
                    Text(
                      "Follow Us",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        // color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        social_button(
                          context: context,
                          imagePath: 'assets/socials/facebook.png',
                          label: 'Facebook',
                          onPressed: () => _launchUrlSmart(
                            'https://www.facebook.com/cybrosystechnologies',
                            title: 'Facebook',
                          ),
                        ),
                        social_button(
                          context: context,
                          imagePath: 'assets/socials/linkedin.png',
                          label: 'LinkedIn',
                          onPressed: () => _launchUrlSmart(
                            'https://www.linkedin.com/company/cybrosys/',
                            title: 'LinkedIn',
                          ),
                        ),
                        social_button(
                          context: context,
                          imagePath: 'assets/socials/instagram.png',
                          label: 'Instagram',
                          onPressed: () => _launchUrlSmart(
                            'https://www.instagram.com/cybrosystech/',
                            title: 'Instagram',
                          ),
                        ),
                        social_button(
                          context: context,
                          imagePath: 'assets/socials/youtube.png',
                          label: 'YouTube',
                          onPressed: () => _launchUrlSmart(
                            'https://www.youtube.com/channel/UCKjWLm7iCyOYINVspCSanjg',
                            title: 'YouTube',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "© ${DateTime.now().year} Cybrosys Technologies",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 50)),
          ],
        ),
      ),
    );
  }
}