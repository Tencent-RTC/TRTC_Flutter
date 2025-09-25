import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'user_list_state.dart';

class UserListItem extends StatelessWidget {
  final UserInfo user;
  final bool isVideoMode;

  const UserListItem({
    Key? key,
    required this.user,
    this.isVideoMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<UserListState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              children: [
                if (isVideoMode)
                  TRTCCloudVideoView(
                    key: Key(user.userId),
                    onViewCreated: (viewId) {
                      user.viewId = viewId;
                      state.startStreamView(user.userId, TRTCVideoStreamType.big);
                      state.refreshUserListWidget();
                    },
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      user.userId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserListWidget extends StatelessWidget {
  final bool isVideoMode;

  const UserListWidget({
    Key? key,
    this.isVideoMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserListState>(
      builder: (context, state, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: state.users.values.map((user) {
                return ChangeNotifierProvider.value(
                  value: user,
                  child: UserListItem(user: user, isVideoMode: true),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}