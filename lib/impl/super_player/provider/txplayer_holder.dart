// Copyright (c) 2022 Tencent. All rights reserved.
part of '../super_player.dart';

abstract class TXModel {}

class TXPlayerHolder extends TXModel {
  TXPlayerController controller;

  TXPlayerHolder(this.controller);

  void updateController(TXPlayerController playerController) {
    controller = playerController;
  }
}
