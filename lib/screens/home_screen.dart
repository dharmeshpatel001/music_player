import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import '../components.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  //define on audio plugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

  //player
  final AudioPlayer _player = AudioPlayer();
  final Components components = Components();

  //request permission
  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  //more variables
  List<SongModel> songs = [];
  String currentSongTitle = '';
  String currentSongDisplayName = '';
  String currentSongDuration = '';
  int currentIndex = 0;
  bool isPlayerVisible = false;

  //define method to set player visible
  void _changePlayerViewVisiblity() {
    setState(() {
      isPlayerVisible = !isPlayerVisible;
    });
  }

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
        _player.positionStream,
        _player.durationStream,
        (position, duration) =>
            DurationState(position: position, total: duration ?? Duration.zero),
      );

  //dispose the player
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isPlayerVisible) {
      return Scaffold(
        backgroundColor: components.bgColor,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, right: 20, left: 20),
            decoration: BoxDecoration(color: components.bgColor),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: _changePlayerViewVisiblity,
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: components.getDecoration(
                              BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Text(
                        currentSongTitle,
                        style: GoogleFonts.jost(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: components.bgSubText),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 300,
                  height: 300,
                  decoration: components.getDecoration(
                      BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(200.0),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //       top: 10, bottom: 20, left: 5, right: 5),
                //   child: Container(
                //     height: 50,
                //     decoration:components.getDecoration(BoxShape.rectangle, const Offset(-1,-1), 1.0, 1.0),
                //     child: Column(
                //       children: [
                //         Text(
                //           currentSongTitle,
                //           style: GoogleFonts.jost(
                //               fontSize: 10,
                //               fontWeight: FontWeight.w600,
                //               color: components.bgSubText),
                //         ),
                //         Text(
                //           currentSongDuration,
                //           style: GoogleFonts.jost(
                //               fontSize: 10,
                //               fontWeight: FontWeight.w600,
                //               color: components.bgSubText),
                //         ),
                //       ],
                //     )
                //   ),
                // ),
                Column(
                  children: [
                    Container(
                      // height: 150,
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 4.0),
                      decoration: components.getRectDecoration(
                          BorderRadius.circular(50.0),
                          Offset(-1,-1), 1.0, 1.0),
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          return ProgressBar(
                            progress: progress,
                            total: total,
                            barHeight: 20.0,
                            baseBarColor: components.bgColor,
                            progressBarColor: const Color(0xEE9E9E9E),
                            thumbColor: Colors.white60.withOpacity(0.99),
                            timeLabelTextStyle: const TextStyle(fontSize: 0),
                            onSeek: (duration) {
                              _player.seek(duration);
                            },
                          );
                        },
                      ),
                    ),
                    StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text(
                                progress.toString().split(".")[0],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                total.toString().split(".")[0],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //skip top previous
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.hasPrevious) {
                              _player.seekToPrevious();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: components.getDecoration(
                                BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                            child: const Icon(Icons.skip_previous),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: components.getDecoration(
                              BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                          child: InkWell(
                            onTap: () {
                              if (_player.playing) {
                                _player.pause();
                              } else {
                                if (_player.currentIndex != null) {
                                  _player.play();
                                }
                              }
                            },
                            child: StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (context, snapshot) {
                                bool? playingState = snapshot.data;
                                if (playingState != null && playingState) {
                                  return const Icon(
                                    Icons.pause,
                                    size: 30,
                                    color: Colors.white70,
                                  );
                                }
                                return const Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: Colors.white70,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.hasNext) {
                              _player.seekToNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: components.getDecoration(
                                BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                            child: const Icon(Icons.skip_next),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //go to playlist btn
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _changePlayerViewVisiblity();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: components.getDecoration(
                                BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                            child: const Icon(
                              Icons.list_alt,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _player.setShuffleModeEnabled(true);
                            components.toast(context, "Shuffling enabled");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.only(right: 30, left: 30),
                            decoration: components.getDecoration(
                                BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                            child: const Icon(Icons.shuffle,
                                color: Colors.white70),
                          ),
                        ),
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              // _player.loopMode == LoopMode.one
                              //     ? _player.setLoopMode(LoopMode.one)
                              //     : _player.loopMode == LoopMode.all;
                              components.toast(
                                  context, "We are working on this feature!");
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: components.getDecoration(
                                BoxShape.circle, const Offset(-1,-1), 1.0, 1.0),
                            child: StreamBuilder<LoopMode>(
                              stream: _player.loopModeStream,
                              builder: (context, snapshot) {
                                final loopMode = snapshot.data;
                                if (LoopMode.one == loopMode) {
                                  return const Icon(
                                    Icons.repeat_one,
                                    size: 30,
                                    color: Colors.white70,
                                  );
                                }
                                return const Icon(
                                  Icons.repeat,
                                  size: 30,
                                  color: Colors.white70,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: components.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Music",
          style: GoogleFonts.almendra(
              color: components.bgApp,
              fontSize: 25,
              fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: components.bgColor,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true),
        builder: (context, item) {
          //loading content indicator
          if (item.data == null) {
            return const CircularProgressIndicator();
          }
          // no song found
          if (item.data!.isEmpty) {
            return const Text("No Songs Found");
          }
          //showing songs
          //add song to song list
          songs.clear();
          songs = item.data!;
          return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: components.bgColor,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 1.0,
                            offset: Offset(-2, -2),
                            color: Colors.white24),
                        BoxShadow(
                            blurRadius: 1.0,
                            offset: Offset(-2, -2),
                            color: Colors.black),
                      ]),
                  child: ListTile(
                    textColor: Colors.white,
                    title: Text(
                      item.data![index].title,
                      style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: components.bgText),
                    ),
                    subtitle: Text(
                      item.data![index].displayName,
                      style: GoogleFonts.prompt(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: components.bgSubText),
                    ),
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
                    ),
                    onTap: () async {
                      _changePlayerViewVisiblity();
                      components.toast(
                          context, "Playing" + item.data![index].title);
                      // String? uri = item.data![index].uri;
                      // await _player
                      //     .setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                      await _player.setAudioSource(createPlaylist(item.data!),
                          initialIndex: index);
                      await _player.play();
                    },
                    trailing: const Icon(Icons.more_vert),
                  ),
                );
              });
        },
      ),
    );
  }

  void requestStoragePermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
        //ensure build method is called
        setState(() {});
      }
    }
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentSongDisplayName = songs[index].displayName;
        currentSongDuration = songs[index].duration as String;
        currentIndex = index;
      }
    });
  }
}

//duration class
class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});

  Duration position, total;
}
