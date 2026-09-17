import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'render_params_state.dart';

class RenderParamsPage extends StatefulWidget {
  final String userId;
  final RoomIdSpec roomIdSpec;

  const RenderParamsPage({
    Key? key,
    required this.userId,
    required this.roomIdSpec,
  }) : super(key: key);

  @override
  State<RenderParamsPage> createState() => _RenderParamsPageState();
}

class _RenderParamsPageState extends State<RenderParamsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RenderParamsState _state;

  static const _accentColor = Color(0xFF00796B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _state = RenderParamsState(
      userId: widget.userId,
      roomIdSpec: widget.roomIdSpec,
    );
    _state.addListener(_onStateChanged);
    _state.initialize();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── Label helpers ──

  String _rotationLabel(TRTCVideoRotation r) {
    switch (r) {
      case TRTCVideoRotation.rotation0:
        return '0°';
      case TRTCVideoRotation.rotation90:
        return '90°';
      case TRTCVideoRotation.rotation180:
        return '180°';
      case TRTCVideoRotation.rotation270:
        return '270°';
    }
  }

  IconData _rotationIcon(TRTCVideoRotation r) {
    switch (r) {
      case TRTCVideoRotation.rotation0:
        return Icons.crop_rotate;
      case TRTCVideoRotation.rotation90:
        return Icons.rotate_90_degrees_ccw;
      case TRTCVideoRotation.rotation180:
        return Icons.flip;
      case TRTCVideoRotation.rotation270:
        return Icons.rotate_90_degrees_cw;
    }
  }

  String _fillModeLabel(TRTCVideoFillMode m, AppLocalizations l10n) {
    switch (m) {
      case TRTCVideoFillMode.fill:
        return l10n.fillModeFill;
      case TRTCVideoFillMode.fit:
        return l10n.fillModeFit;
      case TRTCVideoFillMode.scaleFill:
        return l10n.fillModeScaleFill;
    }
  }

  IconData _fillModeIcon(TRTCVideoFillMode m) {
    switch (m) {
      case TRTCVideoFillMode.fill:
        return Icons.crop_free;
      case TRTCVideoFillMode.fit:
        return Icons.crop_din;
      case TRTCVideoFillMode.scaleFill:
        return Icons.aspect_ratio;
    }
  }

  String _mirrorLabel(TRTCVideoMirrorType m, AppLocalizations l10n) {
    switch (m) {
      case TRTCVideoMirrorType.auto:
        return l10n.mirrorAuto;
      case TRTCVideoMirrorType.enable:
        return l10n.mirrorEnable;
      case TRTCVideoMirrorType.disable:
        return l10n.mirrorDisable;
    }
  }

  IconData _mirrorIcon(TRTCVideoMirrorType m) {
    switch (m) {
      case TRTCVideoMirrorType.auto:
        return Icons.auto_awesome;
      case TRTCVideoMirrorType.enable:
        return Icons.flip_outlined;
      case TRTCVideoMirrorType.disable:
        return Icons.do_not_disturb;
    }
  }

  String _streamTypeLabel(TRTCVideoStreamType t, AppLocalizations l10n) {
    switch (t) {
      case TRTCVideoStreamType.big:
        return l10n.streamTypeBig;
      case TRTCVideoStreamType.small:
        return l10n.streamTypeSmall;
      case TRTCVideoStreamType.sub:
        return l10n.streamTypeSub;
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.renderParamsTitle),
          actions: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _state.isEnterRoom ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildVideoArea(l10n),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: _accentColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: l10n.localRenderParamsTab),
                      Tab(text: l10n.remoteRenderParamsTab),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLocalRenderSettings(l10n),
                        _buildRemoteRenderSettings(l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    _state.exitRoom();
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.exitRoomButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Video area ──

  Widget _buildVideoArea(AppLocalizations l10n) {
    final remotes = _state.remoteUsers.where((u) => u.isVideoAvailable).toList();
    final hasRemote = remotes.isNotEmpty;

    return SizedBox(
      height: hasRemote ? 280 : 200,
      child: hasRemote ? _buildVideoGrid(l10n, remotes) : _buildLocalOnly(l10n),
    );
  }

  Widget _buildLocalOnly(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            TRTCCloudVideoView(
              onViewCreated: (viewId) => _state.setLocalViewId(viewId),
            ),
            Positioned(
              top: 8,
              left: 12,
              child: _videoLabel(l10n.localPreview, _accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(
      AppLocalizations l10n, List<RemoteRenderUser> remotes) {
    final all = [
      _VideoTileData(isLocal: true, label: l10n.localPreview),
      ...remotes.map((u) => _VideoTileData(
            isLocal: false,
            label: '${l10n.remoteUser}: ${u.userId}',
            userId: u.userId,
          )),
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: all.length,
      itemBuilder: (context, index) => _buildVideoTile(all[index]),
    );
  }

  Widget _buildVideoTile(_VideoTileData data) {
    final isSelected = !data.isLocal &&
        data.userId == _state.selectedRemoteUserId;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: _accentColor, width: 2)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (data.isLocal)
              TRTCCloudVideoView(
                onViewCreated: (viewId) => _state.setLocalViewId(viewId),
              )
            else
              TRTCCloudVideoView(
                onViewCreated: (viewId) =>
                    _state.setRemoteViewId(data.userId!, viewId),
              ),
            Positioned(
              top: 6,
              left: 10,
              child: _videoLabel(
                data.label,
                data.isLocal ? _accentColor : Colors.teal,
              ),
            ),
            if (!data.isLocal && isSelected)
              Positioned(
                top: 6,
                right: 10,
                child: _videoLabel(
                  _streamTypeShortLabel(_state.remoteStreamType.value, AppLocalizations.of(context)!),
                  Colors.amber,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _streamTypeShortLabel(TRTCVideoStreamType t, AppLocalizations l10n) {
    switch (t) {
      case TRTCVideoStreamType.big:
        return 'Big';
      case TRTCVideoStreamType.small:
        return 'Small';
      case TRTCVideoStreamType.sub:
        return 'Sub';
    }
  }

  Widget _videoLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Card builders ──

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: _accentColor),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Chip selector for enum values with icons.
  Widget _buildChipSelector<T>({
    required ValueNotifier<T> notifier,
    required List<T> values,
    required String Function(T) label,
    required IconData Function(T) icon,
  }) {
    return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, selected, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((v) {
            final isSelected = v == selected;
            return GestureDetector(
              onTap: () => notifier.value = v,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accentColor.withOpacity(0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? _accentColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon(v),
                        size: 16,
                        color: isSelected
                            ? _accentColor
                            : Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(label(v),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? _accentColor
                              : Colors.grey.shade700,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600)),
    );
  }

  // ── Local render settings tab ──

  Widget _buildLocalRenderSettings(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: l10n.rotationAngleLabel,
            icon: Icons.rotate_right,
            children: [
              _buildLabel(l10n.renderParamsRotationHint),
              _buildChipSelector<TRTCVideoRotation>(
                notifier: _state.localRotation,
                values: TRTCVideoRotation.values,
                label: _rotationLabel,
                icon: _rotationIcon,
              ),
            ],
          ),
          _buildSectionCard(
            title: l10n.fillModeLabel,
            icon: Icons.aspect_ratio,
            children: [
              _buildLabel(l10n.renderParamsFillModeHint),
              _buildChipSelector<TRTCVideoFillMode>(
                notifier: _state.localFillMode,
                values: TRTCVideoFillMode.values,
                label: (m) => _fillModeLabel(m, l10n),
                icon: _fillModeIcon,
              ),
            ],
          ),
          _buildSectionCard(
            title: l10n.mirrorModeLabel,
            icon: Icons.flip,
            children: [
              _buildLabel(l10n.renderParamsMirrorHint),
              _buildChipSelector<TRTCVideoMirrorType>(
                notifier: _state.localMirrorType,
                values: TRTCVideoMirrorType.values,
                label: (m) => _mirrorLabel(m, l10n),
                icon: _mirrorIcon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Remote render settings tab ──

  Widget _buildRemoteRenderSettings(AppLocalizations l10n) {
    final availableRemotes = _state.remoteUsers.toList();

    if (availableRemotes.isEmpty) {
      return Center(
        child: Text(l10n.noRemoteUser,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      );
    }

    final selectedId = _state.selectedRemoteUserId;
    final dropdownValue = (selectedId != null &&
            _remoteUsersContains(selectedId))
        ? selectedId
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Remote user selector
          _buildSectionCard(
            title: l10n.remoteUserLabel,
            icon: Icons.person_outline,
            children: [
              _buildRemoteUserDropdown(l10n, availableRemotes, dropdownValue),
              if (dropdownValue != null) ...[
                const SizedBox(height: 16),
                _buildLabel(l10n.streamTypeLabel),
                _buildStreamTypeSelector(l10n, dropdownValue),
              ],
            ],
          ),
          if (dropdownValue != null) ...[
            _buildSectionCard(
              title: l10n.rotationAngleLabel,
              icon: Icons.rotate_right,
              children: [
                _buildLabel(l10n.renderParamsRotationHint),
                _buildChipSelector<TRTCVideoRotation>(
                  notifier: _state.remoteRotation,
                  values: TRTCVideoRotation.values,
                  label: _rotationLabel,
                  icon: _rotationIcon,
                ),
              ],
            ),
            _buildSectionCard(
              title: l10n.fillModeLabel,
              icon: Icons.aspect_ratio,
              children: [
                _buildLabel(l10n.renderParamsFillModeHint),
                _buildChipSelector<TRTCVideoFillMode>(
                  notifier: _state.remoteFillMode,
                  values: TRTCVideoFillMode.values,
                  label: (m) => _fillModeLabel(m, l10n),
                  icon: _fillModeIcon,
                ),
              ],
            ),
            _buildSectionCard(
              title: l10n.mirrorModeLabel,
              icon: Icons.flip,
              children: [
                _buildLabel(l10n.renderParamsMirrorHint),
                _buildChipSelector<TRTCVideoMirrorType>(
                  notifier: _state.remoteMirrorType,
                  values: TRTCVideoMirrorType.values,
                  label: (m) => _mirrorLabel(m, l10n),
                  icon: _mirrorIcon,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRemoteUserDropdown(
      AppLocalizations l10n,
      List<RemoteRenderUser> availableRemotes,
      String? dropdownValue) {
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: InputDecoration(
        labelText: l10n.selectRemoteUser,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: const Icon(Icons.person_search, size: 20),
      ),
      items: availableRemotes
          .map((u) => DropdownMenuItem(
                value: u.userId,
                child: Text(u.userId, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: (v) => _state.selectRemoteUser(v),
    );
  }

  Widget _buildStreamTypeSelector(
      AppLocalizations l10n, String remoteUserId) {
    final user = _state.remoteUsers.firstWhere((u) => u.userId == remoteUserId);
    return ValueListenableBuilder<TRTCVideoStreamType>(
      valueListenable: _state.remoteStreamType,
      builder: (context, selected, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TRTCVideoStreamType.values.map((t) {
            final isSelected = t == selected;
            final bool available = _isStreamAvailableForUser(user, t);
            return GestureDetector(
              onTap: available
                  ? () => _state.changeRemoteStreamType(t)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accentColor.withOpacity(0.12)
                      : (available
                          ? Colors.grey.shade100
                          : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? _accentColor
                        : (available
                            ? Colors.transparent
                            : Colors.grey.shade300),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t == TRTCVideoStreamType.big
                          ? Icons.hd_outlined
                          : t == TRTCVideoStreamType.small
                              ? Icons.speed
                              : Icons.screen_share,
                      size: 16,
                      color: isSelected
                          ? _accentColor
                          : available
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _streamTypeLabel(t, l10n),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? _accentColor
                            : available
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  bool _isStreamAvailableForUser(
      RemoteRenderUser user, TRTCVideoStreamType type) {
    switch (type) {
      case TRTCVideoStreamType.big:
        return user.isVideoAvailable;
      case TRTCVideoStreamType.small:
        return user.isVideoAvailable;
      case TRTCVideoStreamType.sub:
        return user.isSubStreamAvailable;
    }
  }

  bool _remoteUsersContains(String userId) {
    return _state.remoteUsers.any((u) => u.userId == userId);
  }
}

class _VideoTileData {
  final bool isLocal;
  final String label;
  final String? userId;

  _VideoTileData({required this.isLocal, required this.label, this.userId});
}
