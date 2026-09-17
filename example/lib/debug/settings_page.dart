import 'package:api_example/common/locale_controller.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';

/// Settings page with the language selection feature.
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const _accentColor = Color(0xFF00796B);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TRTCCloud? _trtcCloud;
  String _sdkVersion = '...';

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  Future<void> _initSdk() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    final version = _trtcCloud?.getSDKVersion();
    if (mounted && version != null) {
      setState(() => _sdkVersion = version);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeController = context.watch<LocaleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLanguageCard(context, l10n, localeController),
            const SizedBox(height: 12),
            _buildSdkInfoCard(context, l10n),
          ],
        ),
      ),
    );
  }

  // ── SDK info card ──

  Widget _buildSdkInfoCard(BuildContext context, AppLocalizations l10n) {
    return _buildCard(
      context: context,
      icon: Icons.info_outline,
      title: l10n.sdkInfoCard,
      children: [
        Row(
          children: [
            Text(l10n.sdkVersionLabel,
                style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              _sdkVersion,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  // ── Log settings card ──

  // ── Section card builder ──

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final color = accentColor ?? SettingsPage._accentColor;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  // ── Language card ──

  Widget _buildLanguageCard(BuildContext context, AppLocalizations l10n,
      LocaleController localeController) {
    final currentLocale = localeController.locale;
    return _buildCard(
      context: context,
      icon: Icons.language,
      title: l10n.language,
      children: [
        _buildLocaleChip(
          label: l10n.followSystem,
          icon: Icons.settings_system_daydream,
          isSelected: currentLocale == null,
          onTap: () => localeController.setLocale(null),
        ),
        const SizedBox(height: 8),
        _buildLocaleChip(
          label: l10n.chinese,
          icon: Icons.translate,
          isSelected: currentLocale?.languageCode == 'zh',
          onTap: () => localeController.setLocale(const Locale('zh')),
        ),
        const SizedBox(height: 8),
        _buildLocaleChip(
          label: l10n.english,
          icon: Icons.abc,
          isSelected: currentLocale?.languageCode == 'en',
          onTap: () => localeController.setLocale(const Locale('en')),
        ),
      ],
    );
  }

  Widget _buildLocaleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? SettingsPage._accentColor.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SettingsPage._accentColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? SettingsPage._accentColor : Colors.grey.shade500),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? SettingsPage._accentColor : Colors.grey.shade700,
                )),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, size: 18, color: SettingsPage._accentColor),
          ],
        ),
      ),
    );
  }
}
