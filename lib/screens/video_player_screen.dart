import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoKey;
  final String title;

  const VideoPlayerScreen({
    Key? key,
    required this.videoKey,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with WidgetsBindingObserver {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  String? _selectedQuality;
  bool _isOfflineMode = false;

  final List<String> _availableQualities = [
    'auto', '144p', '240p', '360p', '480p', '720p', '1080p'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOfflineMode = connectivityResult == ConnectivityResult.none;
    });
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
        forceHD: _selectedQuality == '720p' || _selectedQuality == '1080p',
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  Widget _buildQualitySelector() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      onSelected: (quality) {
        setState(() {
          _selectedQuality = quality;
          _initializePlayer();
        });
      },
      itemBuilder: (context) => _availableQualities
          .map((quality) => PopupMenuItem(
                value: quality,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(quality),
                    if (quality == _selectedQuality)
                      const Icon(Icons.check, color: Colors.blue),
                  ],
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              title: Text(widget.title),
              actions: [
                _buildQualitySelector(),
              ],
            ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    YoutubePlayerBuilder(
                      onExitFullScreen: () {
                        if (_isFullScreen) {
                          _toggleFullScreen();
                        }
                      },
                      player: YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.red,
                          handleColor: Colors.redAccent,
                        ),
                        onReady: () {
                          print('Player is ready.');
                        },
                        topActions: [
                          IconButton(
                            icon: Icon(
                              _isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: _toggleFullScreen,
                          ),
                        ],
                        bottomActions: [
                          CurrentPosition(),
                          ProgressBar(
                            isExpanded: true,
                            colors: const ProgressBarColors(
                              playedColor: Colors.red,
                              handleColor: Colors.redAccent,
                            ),
                          ),
                          RemainingDuration(),
                          const PlaybackSpeedButton(),
                        ],
                      ),
                      builder: (context, player) {
                        return Column(
                          children: [
                            player,
                            if (!_isFullScreen) ...[
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    // Add video info or description here
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}