import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class JoinLiveStream extends StatefulWidget {
  final String channelId;
  const JoinLiveStream({super.key, required this.channelId});

  @override
  State<JoinLiveStream> createState() => _JoinLiveStreamState();
}

class _JoinLiveStreamState extends State<JoinLiveStream> {
  late RtcEngine _engine;

  @override
  void initState() {
    initAgora();
    super.initState();
  }

  Future<void> initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "e44591baf1364511948c78aa83a01d4d",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.joinChannel(
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
      token:
          '007eJxTYCjKnN+4dzLvgmcacZ82vq79fppP0eHgpfDOm+XXe7xnH5uvwJBqYmJqaZiUmGZobGZiamhoaWKRbG6RmGhhnGhgmGKSotnJnt4QyMjQWG3MysgAgSA+F4NzRmJeXmpOvE8QAwMAppQiag==',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 94984893),
          connection: const RtcConnection(channelId: "channel-LR"),
        ),
      ),
    );
  }
}
