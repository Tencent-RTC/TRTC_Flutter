import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen_share_state.dart';
import 'package:api_example/common/user_list_widget.dart';

class ScreenSharePage extends StatefulWidget {
  final String userId;
  final String roomId;
  const ScreenSharePage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<ScreenSharePage> createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  late ScreenShareState _state;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _state = ScreenShareState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    await _state.enterRoom(widget.userId, int.tryParse(widget.roomId) ?? 0);
    setState(() {
      _isInit = true;
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );

  Widget _sectionDivider() => const Divider(height: 32, thickness: 1.2);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Consumer<ScreenShareState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Screen Share Test')),
            body: _isInit
                ? Column(
                    children: [
                      Expanded(
                        flex: 0,
                        child: state.userListState == null
                            ? const Center(child: CircularProgressIndicator())
                            : ChangeNotifierProvider.value(
                                value: state.userListState!,
                                child: const SizedBox(
                                  height: 220,
                                  child: UserListWidget(isVideoMode: true),
                                ),
                              ),
                      ),
                      const Divider(height: 24),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Screen Share Controls'),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.startScreenShare : null,
                                  child: const Text('Start Screen Share'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                                  onPressed: state.isEntered ? state.stopScreenShare : null,
                                  child: const Text('Stop Screen Share'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _sectionDivider(),
                              _sectionTitle('Callback / Log'),
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  itemCount: state.logs.length,
                                  itemBuilder: (context, idx) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(state.logs[idx], style: const TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
} 