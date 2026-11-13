import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mobo_appointment_project/features/login/server/provider/server_provider.dart';
import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../services/session_service.dart';

class LoginScreenServerPage extends StatefulWidget {
  const LoginScreenServerPage({super.key});

  @override
  State<LoginScreenServerPage> createState() => _LoginScreenServerPageState();
}

class _LoginScreenServerPageState extends State<LoginScreenServerPage> {
  final TextEditingController serverController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Timer? debounceTimer;

  final FocusNode serverFocusNode = FocusNode();

  String? savedServerUrl;
  String? savedUrl;
  String savedProtocol = 'https://';

  bool showSavedUrlSuggestion = false;

  void onServerChanged(String value) {
    debounceTimer?.cancel();

    final serverProvider = context.read<ServerProvider>();

    serverProvider.updateUrl(value);

    if (value.trim().isEmpty) return;
    if (serverProvider.databases.isNotEmpty) return;

    debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      serverProvider.fetchDatabases();
    });
  }

  Future<void> _loadSavedServerDetails() async {
    final details = await SessionService().getServerDetails();

    if (!mounted || details == null) return;

    final serverUrl = details['serverUrl']!;
    final database = details['database']!;

    final uri = Uri.tryParse(serverUrl);

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return;

    final provider = context.read<ServerProvider>();

    final protocol = '${uri.scheme}://';

    final url =
        '${uri.host}'
        '${uri.hasPort ? ':${uri.port}' : ''}'
        '${uri.path == '/' ? '' : uri.path}';

    // Restore protocol and URL.
    provider.updateProtocol(protocol);
    provider.updateUrl(url);

    serverController.text = url;

    // Fetch databases from the restored server.
    await provider.fetchDatabases();

    if (!mounted) return;

    // Select saved database only if it exists.
    final databaseExists = provider.databases.any(
          (db) => db.name == database,
    );

    if (databaseExists) {
      provider.updateDatabase(database);
    }

    setState(() {
      savedServerUrl = serverUrl;
      savedProtocol = protocol;
      savedUrl = url;
      showSavedUrlSuggestion = false;
    });
  }

  void _handleServerFocus() {
    if (!mounted) return;

    setState(() {
      showSavedUrlSuggestion =
          serverFocusNode.hasFocus &&
          savedServerUrl != null &&
          serverController.text.trim().isEmpty;
    });
  }

  void _selectSavedServerUrl() {
    if (savedUrl == null) return;

    final provider = context.read<ServerProvider>();

    provider.updateProtocol(savedProtocol);

    serverController.text = savedUrl!;

    onServerChanged(savedUrl!);

    serverFocusNode.unfocus();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final provider = context.read<ServerProvider>();

    final savedUri = Uri.tryParse(provider.serverConfig.fullUrl);

    if (savedUri != null && savedUri.hasScheme && savedUri.host.isNotEmpty) {
      serverController.text =
          '${savedUri.host}'
          '${savedUri.hasPort ? ':${savedUri.port}' : ''}'
          '${savedUri.path == '/' ? '' : savedUri.path}';
    }

    serverFocusNode.addListener(_handleServerFocus);

    _loadSavedServerDetails();
  }

  @override
  void dispose() {
    debounceTimer?.cancel();

    serverFocusNode.removeListener(_handleServerFocus);
    serverFocusNode.dispose();

    serverController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServerProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.primaryColor,
      body: Form(
        key: formKey,
        child: Stack(
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

            SafeArea(
              child: Column(
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
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.manrope().fontFamily,
                                    color: AppTheme.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Configure your server connection",
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    color: Color(0xbffafafa),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 40),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  child: CustomAppTextField(
                                    isLoading: provider.isLoading,
                                    controller: serverController,
                                    initialProtocol: provider.protocol,
                                    focusNode: serverFocusNode,
                                    onChanged: onServerChanged,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter server address';
                                      }
                                      return null;
                                    },
                                    onProtocolChanged: (value) {
                                      context
                                          .read<ServerProvider>()
                                          .updateProtocol(value);
                                      onServerChanged(serverController.text);
                                    },
                                  ),
                                ),


                                // suggestion url
                                if (showSavedUrlSuggestion &&
                                    savedServerUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withAlpha(
                                              5,
                                            ), // Shadow color
                                            spreadRadius: 5,
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: ListTile(
                                          dense: true,
                                          title: Text(
                                            savedServerUrl!,
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.manrope()
                                                  .fontFamily,
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          onTap: _selectSavedServerUrl,
                                        ),
                                      ),
                                    ),
                                  ),

                                //db dropdown
                                const SizedBox(height: 10),

                                if (provider.databases.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: DatabaseDropdown(
                                      databases: provider.databases
                                          .map((database) => database.name)
                                          .toList(),
                                      selectedDatabase:
                                          provider.selectedDatabase,
                                      onChanged: (value) {
                                        context
                                            .read<ServerProvider>()
                                            .updateDatabase(value);
                                      },
                                    ),
                                  ),
                                ],
                                SizedBox(height: 50),
                                // error message
                                if (provider.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 40,bottom: 5
                                    ),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon: HugeIconsStrokeRounded
                                              .alertCircle,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Network error occurred . Please check your internet connection and server URL",
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.manrope()
                                                  .fontFamily,
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
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
                                          onPressed:
                                              provider.selectedDatabase ==
                                                      null ||
                                                  provider.isLoading
                                              ? null
                                              : () {
                                                  final config = context
                                                      .read<ServerProvider>()
                                                      .serverConfig;

                                                  context.goNamed(
                                                    AppRoutes.credentialLogin,
                                                    extra: {
                                                      'serverUrl':
                                                          config.fullUrl,
                                                      'database':
                                                          config.database,
                                                    },
                                                  );
                                                },
                                          child: Text(
                                            "Next",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              fontFamily: GoogleFonts.manrope()
                                                  .fontFamily,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            disabledBackgroundColor:
                                                Colors.black26,
                                            fixedSize: Size(120, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    12,
                                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseDropdown extends StatefulWidget {
  final List<String> databases;
  final String? selectedDatabase;
  final ValueChanged<String?> onChanged;
  final String initialValue;

  const DatabaseDropdown({
    super.key,
    required this.databases,
    required this.selectedDatabase,
    required this.onChanged,
    this.initialValue = "mobo_appointments",
  });

  @override
  State<DatabaseDropdown> createState() => _DatabaseDropdownState();
}

class _DatabaseDropdownState extends State<DatabaseDropdown> {
  final OverlayPortalController overlayController = OverlayPortalController();

  final LayerLink layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: overlayController,
      overlayChildBuilder: (context) {
        return CompositedTransformFollower(
          link: layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.white,
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width - 90,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: widget.databases.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No databases found'),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: widget.databases.length,
                          itemBuilder: (context, index) {
                            final database = widget.databases[index];

                            return InkWell(
                              onTap: () {
                                widget.onChanged(database);
                                overlayController.hide();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Text(
                                  database,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: layerLink,
        child: GestureDetector(
          onTap: () {
            if (widget.databases.isNotEmpty) {
              overlayController.toggle();
            }
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIconsStrokeRounded.database,
                  size: 18,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    widget.selectedDatabase ?? ('Select Database'),
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String initialProtocol;

  final Function(String) onProtocolChanged;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isLoading;
  final FocusNode? focusNode;

  final Function(String) onChanged;

  const CustomAppTextField({
    super.key,
    required this.controller,
    required this.onProtocolChanged,
    this.initialProtocol = 'https://',
    this.hintText = 'Enter Server Address',
    this.validator,
    this.isLoading = false,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<CustomAppTextField> createState() => _CustomAppTextFieldState();
}

class _CustomAppTextFieldState extends State<CustomAppTextField> {
  late String selectedProtocol;

  final OverlayPortalController protocolOverlayController =
      OverlayPortalController();

  final LayerLink protocolLayerLink = LayerLink();

  Widget _buildProtocolOption(String protocol) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedProtocol = protocol;
        });

        widget.onProtocolChanged(protocol);

        protocolOverlayController.hide();
      },

      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: Text(
          protocol,
          style: TextStyle(
            fontFamily: GoogleFonts.manrope().fontFamily,
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomAppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialProtocol != widget.initialProtocol) {
      selectedProtocol = widget.initialProtocol;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedProtocol = widget.initialProtocol;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.serverStack01,
            size: 18,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          OverlayPortal(
            controller: protocolOverlayController,
            overlayChildBuilder: (context) {
              return CompositedTransformFollower(
                link: protocolLayerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.white,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(5),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: 88,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProtocolOption('http://'),
                          _buildProtocolOption('https://'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: CompositedTransformTarget(
              link: protocolLayerLink,

              child: GestureDetector(
                onTap: () {
                  protocolOverlayController.toggle();
                },

                child: SizedBox(
                  width: 75,
                  height: 52,

                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            selectedProtocol,
                            style: TextStyle(
                              fontFamily: GoogleFonts.manrope().fontFamily,
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade700,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            height: 35,
            width: 1,
            color: Colors.grey.shade500,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          Expanded(
            child: TextFormField(
              cursorColor: Colors.black,
              controller: widget.controller,
              validator: widget.validator,
              onChanged: widget.onChanged,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.url,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontFamily: GoogleFonts.manrope().fontFamily,
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: GoogleFonts.manrope().fontFamily,
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,

                suffixIcon: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
