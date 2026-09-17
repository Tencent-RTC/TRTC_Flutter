import 'package:api_example/common/scene_entry_scaffold.dart';
import 'package:api_example/common/user_room_id_form.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'ai_transcriber_page.dart';

class AITranscriberPreparePage extends StatefulWidget {
  const AITranscriberPreparePage({Key? key}) : super(key: key);

  @override
  State<AITranscriberPreparePage> createState() =>
      _AITranscriberPreparePageState();
}

class _AITranscriberPreparePageState extends State<AITranscriberPreparePage> {
  final GlobalKey<UserRoomIdFormState> _formKey = GlobalKey();

  static const _accentColor = Color(0xFF1565C0);

  String _sourceLanguage = 'zh';
  final List<String> _selectedTranslationLanguages = ['en'];

  Map<String, String> _languageOptions(AppLocalizations l10n) => {
        'zh': l10n.languageChinese,
        'en': l10n.languageEnglish,
        'ja': l10n.languageJapanese,
        'ko': l10n.languageKorean,
        'vi': l10n.languageVietnamese,
        'th': l10n.languageThai,
        'fr': l10n.languageFrench,
        'de': l10n.languageGerman,
        'es': l10n.languageSpanish,
        'ru': l10n.languageRussian,
      };

  void _onEnter() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AITranscriberPage(
            userId: _formKey.currentState!.userId,
            roomIdSpec: _formKey.currentState!.roomIdSpec,
            sourceLanguage: _sourceLanguage,
            translationLanguages: _selectedTranslationLanguages,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageOptions = _languageOptions(l10n);
    return SceneEntryScaffold(
      icon: Icons.subtitles_rounded,
      accentColor: _accentColor,
      title: l10n.aiTranscriberTitle,
      subtitle: l10n.descAiTranscriber,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserRoomIdForm(key: _formKey),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _sourceLanguage,
            decoration: InputDecoration(
              labelText: l10n.sourceLanguageLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.language),
            ),
            items: ['zh', 'en'].map((code) {
              return DropdownMenuItem(
                value: code,
                child: Text(languageOptions[code]!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sourceLanguage = value!;
              });
            },
          ),
          const SizedBox(height: 14),
          Text(l10n.translationLanguagesLabel,
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languageOptions.entries
                .where((e) => e.key != _sourceLanguage)
                .map((e) => FilterChip(
                      label: Text(e.value),
                      selected:
                          _selectedTranslationLanguages.contains(e.key),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTranslationLanguages.add(e.key);
                          } else {
                            _selectedTranslationLanguages.remove(e.key);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      ),
      actionLabel: l10n.enterRoom,
      onAction: _onEnter,
    );
  }
}
