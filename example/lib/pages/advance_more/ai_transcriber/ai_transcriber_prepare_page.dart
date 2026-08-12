import 'package:flutter/material.dart';
import 'ai_transcriber_page.dart';

class AITranscriberPreparePage extends StatefulWidget {
  const AITranscriberPreparePage({Key? key}) : super(key: key);

  @override
  State<AITranscriberPreparePage> createState() => _AITranscriberPreparePageState();
}

class _AITranscriberPreparePageState extends State<AITranscriberPreparePage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _sourceLanguage = 'zh';
  final List<String> _selectedTranslationLanguages = ['en'];

  final Map<String, String> _languageOptions = {
    'zh': 'Chinese',
    'en': 'English',
    'ja': 'Japanese',
    'ko': 'Korean',
    'vi': 'Vietnamese',
    'th': 'Thai',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'ru': 'Russian',
  };

  @override
  void dispose() {
    _userIdController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Transcriber')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Room ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sourceLanguage,
                decoration: const InputDecoration(
                  labelText: 'Source Language',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                items: ['zh', 'en'].map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(_languageOptions[code]!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sourceLanguage = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Translation Languages:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _languageOptions.entries
                    .where((e) => e.key != _sourceLanguage)
                    .map((e) => FilterChip(
                          label: Text(e.value),
                          selected: _selectedTranslationLanguages.contains(e.key),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startTranscriber,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Enter Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTranscriber() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AITranscriberPage(
            userId: _userIdController.text,
            roomId: int.parse(_roomIdController.text),
            sourceLanguage: _sourceLanguage,
            translationLanguages: _selectedTranslationLanguages,
          ),
        ),
      );
    }
  }
}
