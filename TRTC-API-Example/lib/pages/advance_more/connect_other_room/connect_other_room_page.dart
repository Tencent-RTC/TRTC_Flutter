import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connect_other_room_state.dart';
import 'package:api_example/common/user_list_widget.dart';

class ConnectOtherRoomPage extends StatefulWidget {
  final String userId;
  final int roomId;
  const ConnectOtherRoomPage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<ConnectOtherRoomPage> createState() => _ConnectOtherRoomPageState();
}

class _ConnectOtherRoomPageState extends State<ConnectOtherRoomPage> {
  late ConnectOtherRoomState _state;
  final TextEditingController _targetRoomIdController = TextEditingController();
  final TextEditingController _targetUserIdController = TextEditingController();
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _state = ConnectOtherRoomState();
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
      child: Consumer<ConnectOtherRoomState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Connect Other Room Example'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  state.exitRoom();
                  Navigator.pop(context);
                },
              ),
            ),
            body: _isInit
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
                        TextField(
                          controller: _targetRoomIdController,
                          decoration: const InputDecoration(
                            labelText: 'Target Room ID',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _targetUserIdController,
                          decoration: const InputDecoration(
                            labelText: 'Target User ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final targetRoomId = int.tryParse(_targetRoomIdController.text.trim());
                                  final targetUserId = _targetUserIdController.text.trim();
                                  if (targetRoomId != null && targetUserId.isNotEmpty) {
                                    state.connectOtherRoom(targetRoomId, targetUserId);
                                  }
                                },
                                child: const Text('Connect'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state.isConnected ? state.disconnectOtherRoom : null,
                                child: const Text('Disconnect'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
