import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GuidedMeditationPage extends StatefulWidget {
  const GuidedMeditationPage({super.key});

  @override
  State<GuidedMeditationPage> createState() => _GuidedMeditationPageState();
}

class _GuidedMeditationPageState extends State<GuidedMeditationPage> {
  final AudioPlayer _meditationPlayer = AudioPlayer();
  final AudioPlayer _relaxationPlayer = AudioPlayer();
  final AudioPlayer _bodyCleansePlayer = AudioPlayer();
  final AudioPlayer _innerConnectivityPlayer = AudioPlayer();
  AudioPlayer? _currentPlayer;

  @override
  void initState() {
    super.initState();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Load assets.
    await _meditationPlayer.setAsset('assets/audio/meditation.mp3');
    await _relaxationPlayer.setAsset('assets/audio/relaxation.mp3');
    await _bodyCleansePlayer.setAsset('assets/audio/body_cleanse.mp3');
    await _innerConnectivityPlayer
        .setAsset('assets/audio/inner_connectivity.mp3');

    // Reset handlers after completion
    for (var player in [
      _meditationPlayer,
      _relaxationPlayer,
      _bodyCleansePlayer,
      _innerConnectivityPlayer,
    ]) {
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.seek(Duration.zero);
          player.pause();
        }
      });
    }
  }

  @override
  void dispose() {
    _meditationPlayer.dispose();
    _relaxationPlayer.dispose();
    _bodyCleansePlayer.dispose();
    _innerConnectivityPlayer.dispose();
    super.dispose();
  }

  void _showNowPlayingSheet({
    required String title,
    required String subtitle,
    required AudioPlayer player,
    required String imagePath,
  }) {
    setState(() {
      _currentPlayer = player;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE6F3FF), Color(0xFFFFF1DB)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: const Color(0xFF0E0F14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF0E0F14).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 30),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final total = player.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          activeColor: const Color(0xFF5B7CFA),
                          inactiveColor: Colors.black12,
                          min: 0.0,
                          max: total.inMilliseconds.toDouble(),
                          value: position.inMilliseconds
                              .clamp(0, total.inMilliseconds)
                              .toDouble(),
                          onChanged: (value) {
                            player.seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF0E0F14)
                                        .withOpacity(0.7)),
                              ),
                              Text(
                                _formatDuration(total),
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF0E0F14)
                                        .withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded,
                          color: Color(0xFF5B7CFA), size: 40),
                      onPressed: () {
                        player.seek(
                            player.position - const Duration(seconds: 10));
                      },
                    ),
                    const SizedBox(width: 20),
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return const CircularProgressIndicator(
                              color: Color(0xFF5B7CFA));
                        }
                        return GestureDetector(
                          onTap: () {
                            if (playing == true) {
                              player.pause();
                            } else {
                              player.play();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF5B7CFA),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF5B7CFA).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              playing == true
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                              .animate()
                              .scale(duration: 300.ms, curve: Curves.easeInOut),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded,
                          color: Color(0xFF5B7CFA), size: 40),
                      onPressed: () {
                        player.seek(
                            player.position + const Duration(seconds: 10));
                      },
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _currentPlayer = null;
      });
    });
  }

  Widget buildAudioCard({
    required String title,
    required String subtitle,
    required AudioPlayer player,
    required Color color,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        _showNowPlayingSheet(
          title: title,
          subtitle: subtitle,
          player: player,
          imagePath: imagePath,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.asset(
                imagePath,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      color.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: const Color(0xFF0E0F14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF0E0F14).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_currentPlayer == player && player.playing)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF5B7CFA),
                        ),
                        child: const Icon(Icons.pause_rounded,
                            color: Colors.white, size: 24),
                      ).animate().shake(duration: 600.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0.0);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE6F3FF),
              Color(0xFFB3E5FC),
              Color(0xFF7ADCB8),
              Color(0xFFFFF1DB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 80,
              left: 40,
              child: _BlurryCircle(
                color: const Color(0xFFFFD166).withOpacity(0.18),
                size: 100,
              ),
            ),
            Positioned(
              top: 180,
              right: 60,
              child: Icon(
                Icons.cloud,
                size: 90,
                color: Colors.white.withOpacity(0.16),
              ),
            ),
            Positioned(
              top: -70,
              left: -60,
              child: _BlurryCircle(
                color: const Color(0xFFB08CFF).withOpacity(0.16),
                size: 160,
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                color: const Color(0xFF5B7CFA).withOpacity(0.14),
                size: 140,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Color(0xFF0E0F14), size: 30),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Guided Meditation',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              color: const Color(0xFF0E0F14),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          "Find Your Peace",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            color: const Color(0xFF0E0F14),
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: 12),
                        Text(
                          "Immerse yourself in calming guided sessions.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF0E0F14).withOpacity(0.7),
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 30),

                        // 🌅 Morning Meditation
                        buildAudioCard(
                          title: '🧘 Morning Meditation',
                          subtitle: 'Start your day with clarity and calm',
                          player: _meditationPlayer,
                          color: const Color(0xFF6BD59A),
                          imagePath: 'assets/images/Meditation.jpg',
                        ),

                        // 🌿 Evening Relaxation
                        buildAudioCard(
                          title: '🌿 Evening Relaxation',
                          subtitle: 'Unwind and let go of stress',
                          player: _relaxationPlayer,
                          color: const Color(0xFF7ADCB8),
                          imagePath: 'assets/images/Relexation.jpg',
                        ),

                        // 🌀 Body Cleansing
                        buildAudioCard(
                          title: '🌀 Body Cleansing',
                          subtitle: 'Release negativity and refresh your body',
                          player: _bodyCleansePlayer,
                          color: const Color(0xFFFFC857),
                          imagePath: 'assets/images/BodyCleanse.jpg',
                        ),

                        // 🔮 Inner Connectivity
                        buildAudioCard(
                          title: '🔮 Inner Connectivity',
                          subtitle: 'Deepen your connection with yourself',
                          player: _innerConnectivityPlayer,
                          color: const Color(0xFF9B5DE5),
                          imagePath: 'assets/images/InnerConnectivity.jpg',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurryCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurryCircle({required this.color, required this.size, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 30, spreadRadius: 6)],
      ),
    );
  }
}
