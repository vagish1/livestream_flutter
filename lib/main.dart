import 'package:flutter/material.dart';
import 'package:livestream_flutter/live_stream.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();
void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiveStreamHome(),
    );
  }
}

class LiveStreamHome extends StatefulWidget {
  const LiveStreamHome({super.key});

  @override
  State<LiveStreamHome> createState() => _LiveStreamHomeState();
}

class _LiveStreamHomeState extends State<LiveStreamHome> {
  final TextEditingController channelId = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: channelId,
                decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Enter Channel Id'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return const StartLiveStream(
                        isBroadcaster: false,
                      );
                    }));
                  },
                  child: const Text("Join Stream ")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return const StartLiveStream(
                        isBroadcaster: true,
                      );
                    }));
                  },
                  child: const Text("Ill stream "))
            ],
          ),
        ),
      ),
    );
  }
}
