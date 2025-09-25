import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_message_state.dart';
import 'package:api_example/common/user_list_widget.dart';

class CustomMessagePage extends StatefulWidget {
  final String userId;
  final int roomId;
  const CustomMessagePage({Key? key, required this.userId, required this.roomId}) : super(key: key);

  @override
  State<CustomMessagePage> createState() => _CustomMessagePageState();
}

class _CustomMessagePageState extends State<CustomMessagePage> {
  late CustomMessageState _state;
  final TextEditingController _cmdMsgController = TextEditingController();
  final TextEditingController _cmdIdController = TextEditingController(text: '1');
  bool _cmdReliable = true;
  bool _cmdOrdered = true;
  final TextEditingController _seiMsgController = TextEditingController();
  final TextEditingController _seiRepeatController = TextEditingController(text: '1');
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _state = CustomMessageState();
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
    _state.exitRoom();
    _cmdMsgController.dispose();
    _cmdIdController.dispose();
    _seiMsgController.dispose();
    _seiRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Consumer<CustomMessageState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Custom Message/SEI Example'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  state.exitRoom();
                  Navigator.pop(context);
                },
              ),
            ),
            body: _isInit
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Current Room ID: \t${state.roomId ?? ''}'),
                          const SizedBox(height: 6),
                          Text('Current User ID: ${state.userId ?? ''}'),
                          const SizedBox(height: 6),
                          Text('Status: ${state.statusMessage}'),
                          const Divider(height: 24),
                          const Text('Room User List'),
                          SizedBox(
                            height: 180,
                            child: _state.userListState == null
                                ? const Center(child: CircularProgressIndicator())
                                : ChangeNotifierProvider.value(
                                    value: _state.userListState!,
                                    child: const UserListWidget(),
                                  ),
                          ),
                          const Divider(height: 20),
                          const Text('Received Messages'),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 120,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Consumer<CustomMessageState>(
                                builder: (context, s, _) {
                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    reverse: true,
                                    itemBuilder: (context, index) {
                                      final int reversedIndex = s.messages.length - 1 - index;
                                      final text = s.messages[reversedIndex];
                                      return Text(
                                        text,
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                    separatorBuilder: (context, index) => const Divider(height: 8),
                                    itemCount: s.messages.length,
                                  );
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => context.read<CustomMessageState>().clearMessages(),
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Clear'),
                            ),
                          ),
                          const Divider(height: 20),
                          // Custom message input area
                          TextField(
                            controller: _cmdMsgController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Message Content',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cmdIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'ID',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Reliable'),
                              Switch(
                                value: _cmdReliable,
                                onChanged: (v) {
                                  setState(() {
                                    _cmdReliable = v;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Ordered'),
                              Switch(
                                value: _cmdOrdered,
                                onChanged: (v) {
                                  setState(() {
                                    _cmdOrdered = v;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final msg = _cmdMsgController.text.trim();
                                final cmdId = int.tryParse(_cmdIdController.text.trim()) ?? 1;
                                final reliable = _cmdReliable;
                                final ordered = _cmdOrdered;
                                if (msg.isNotEmpty) {
                                  state.sendCustomCmdMsg(cmdId, msg, reliable: reliable, ordered: ordered);
                                }
                              },
                              child: const Text('Send Custom'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // SEI message input area
                          TextField(
                            controller: _seiMsgController,
                            decoration: const InputDecoration(
                              labelText: 'SEI Message Content',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _seiRepeatController,
                                  decoration: const InputDecoration(
                                    labelText: 'Repeat',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final msg = _seiMsgController.text.trim();
                                final repeat = int.tryParse(_seiRepeatController.text.trim()) ?? 1;
                                if (msg.isNotEmpty) {
                                  state.sendSEIMsg(msg, repeat);
                                }
                              },
                              child: const Text('Send SEI'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}