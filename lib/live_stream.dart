import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:livestream_flutter/main.dart';
import 'package:permission_handler/permission_handler.dart';

class StartLiveStream extends StatefulWidget {
  final bool isBroadcaster;

  const StartLiveStream({super.key, required this.isBroadcaster});

  @override
  State<StartLiveStream> createState() => _StartLiveStreamState();
}

class _StartLiveStreamState extends State<StartLiveStream> {
  int? _remoteUid;
  bool _localUserJoined = false;
  RtcEngine? _engine;

  // Replace with your Agora credentials
  static const String appId = "e44591baf1364511948c78aa83a01d4d";
  static const String token =
      "007eJxTYAj69UjyZNI095hUnQ8fd1Vb6U/QtCm9z7tYOTiXyaovJkqBIdXExNTSMCkxzdDYzMTU0NDSxCLZ3CIx0cI40cAwxSTF9i97ekMgI0OUZQAzIwMEgvh8DMUF+UUlxbrJGYl5eak5DAwA+ScgqQ==";
  static const String channelId =
      "sports-channel"; // Replace with your channel name

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    // Leave the channel and dispose the engine when the screen is disposed
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  Future<void> initAgora() async {
    // Request permissions for camera and microphone
    await [Permission.microphone, Permission.camera].request();

    // Initialize Agora engine
    _engine = createAgoraRtcEngine();
    setState(() {});
    await _engine?.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Register event handlers
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onError: (type, msg) {
          logger.d(type.name);
          logger.d(msg);
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.d("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.d("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          // Handle token renewal here
        },
      ),
    );

    // Set client role based on user selection (broadcaster or audience)
    if (widget.isBroadcaster) {
      await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine?.enableVideo();

      await _engine?.startPreview();
      await _engine?.switchCamera();

      logger.d("Broadcaster is ready and started streaming.");
      await _engine?.joinChannel(
        token: token,
        channelId: channelId,
        uid: 0,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          defaultVideoStreamType: VideoStreamType.videoStreamHigh,
          audienceLatencyLevel:
              AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
        ),
      );
    } else {
      await _engine?.setClientRole(
        role: ClientRoleType.clientRoleAudience,
      );

      await _engine?.joinChannel(
          token: token,
          channelId: channelId,
          uid: 0,
          options: const ChannelMediaOptions(
            autoSubscribeVideo: true,
            autoSubscribeAudio: true,
            clientRoleType: ClientRoleType.clientRoleAudience,
            defaultVideoStreamType: VideoStreamType.videoStreamHigh,
            audienceLatencyLevel:
                AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
          ));
    }

    // Join the channel with a valid token
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isBroadcaster ? "Live Streaming" : "Watching Live Stream",
        ),
      ),
      body: Stack(
        children: [
          widget.isBroadcaster ? _broadcastView() : _audienceView(),
          if (!_localUserJoined)
            const Center(
              child:
                  CircularProgressIndicator(), // Show loading until local user joins
            ),
        ],
      ),
    );
  }

  // Local video view for broadcaster
  Widget _broadcastView() {
    return _engine != null
        ? AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: const VideoCanvas(uid: 0), // Broadcaster's local video
            ),
          )
        : const SizedBox();
  }

  // Remote video view for audience
  Widget _audienceView() {
    if (_engine != null && _remoteUid != null) {
      logger.d(_remoteUid);
      logger.d("Im here");
      return AgoraVideoView(
        onAgoraVideoViewCreated: (viewId) {
          logger.d("View Created");
        },
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid!),
          connection: const RtcConnection(channelId: channelId),
        ),
      );
    } else {
      return const Center(
        child: Text("Waiting for broadcaster to start streaming..."),
      );
    }
  }
}
