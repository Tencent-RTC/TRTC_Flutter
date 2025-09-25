import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'switch_room_state.dart';
import 'package:api_example/common/user_list_widget.dart';

class SwitchRoomPage extends StatefulWidget {
  final String userId;
  final int roomId;
  const SwitchRoomPage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<SwitchRoomPage> createState() => _SwitchRoomPageState();
}

class _SwitchRoomPageState extends State<SwitchRoomPage> {
  late SwitchRoomState _state;
  final TextEditingController _switchRoomIdController = TextEditingController();
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _state = SwitchRoomState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    await _state.enterRoom(widget.userId, widget.roomId);
    setState(() {
      _isInit = true;
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Consumer<SwitchRoomState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SwitchRoom Example'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  state.exitRoom();
                  Navigator.pop(context);
                },
              ),
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: _isInit
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Current Room ID: ${state.roomId ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Current User ID: ${state.userId ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Status: ${state.statusMessage}'),
                        const Divider(height: 32),
                        const Text('Room User List'),
                        Expanded(
                          child: _state.userListState == null
                              ? const Center(child: CircularProgressIndicator())
                              : ChangeNotifierProvider.value(
                                  value: _state.userListState!,
                                  child: const UserListWidget(),
                                ),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _switchRoomIdController,
                                decoration: const InputDecoration(
                                  labelText: 'Target Room ID',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                final newRoomId = int.tryParse(_switchRoomIdController.text.trim());
                                if (newRoomId != null) {
                                  state.switchRoom(newRoomId);
                                }
                              },
                              child: const Text('Switch Room'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                    : const Center(child: CircularProgressIndicator())),
          );
        },
      ),
    );
  }
}
