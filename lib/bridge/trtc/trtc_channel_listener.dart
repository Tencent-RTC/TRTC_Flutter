class TRTCChannelListener {
  const TRTCChannelListener({
    this.handleNativeOnSnapshotComplete,
  });

  final void Function(dynamic arguments)? handleNativeOnSnapshotComplete;
}
