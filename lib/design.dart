//importing libraries
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storyplayer/bloc/event.dart';
import 'package:video_player/video_player.dart';

import 'bloc/state.dart';
//design class
// ignore: camel_case_types
class design extends StatefulWidget {
  const design({super.key});

  @override
  State<design> createState() => _designState();
}

var timercount = 0;
var touchdiff = 0;
double poseval = 0;

// disgn state class
// ignore: camel_case_types
class _designState extends State<design> {
  final _pageNotifier = ValueNotifier(0.0);
  late VideoPlayerController _controller;
  late StoryBloc mainbloc;
  late Timer watcher;

  PageController controller = PageController();
  double currentPageValue = 0.0;
  void _listener() {
    _pageNotifier.value = controller.page!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.addListener(_listener);
    });
    _controller = VideoPlayerController.network(
      'https://www.pexels.com/download/video/3112280/',
    );

    mainbloc = StoryBloc();

// In this list each story object corresponds to a story.
// It uses web sources.
// Sources are listes with url: 'url_here'
// To change the content just change one of the the links below
    mainbloc.add(LoadStoryEvent(storylist: [
      [
        Story(
          isseen: false,
          name: 'photo_codeway',
          url:
              'https://mobidictum.com/wp-content/uploads/2023/04/codeway.jpg',
          mediaType: MediaType.image,
          duration: 5,
        ),
        Story(
          isseen: false,
          name: 'video_1',
          url:
              'https://www.pexels.com/download/video/3112280/',
          mediaType: MediaType.video,
          duration: 20,
        ),
        
         Story(
          isseen: false,
          name: 'levent',
          url:
              'https://upload.wikimedia.org/wikipedia/commons/8/85/View_of_Levent_financial_district_from_Istanbul_Sapphire.jpg',
          mediaType: MediaType.image,
          duration: 5,
        ),
      ],
      // this part is for second cubic 
      // It's like stories of the second user
      [
        Story(
          isseen: false,
          name: 'video_2',
          url:
              'https://www.pexels.com/download/video/3112280/',
          mediaType: MediaType.video,
          duration: 20,
        ),
        Story(
          isseen: false,
          name: 'thank_you',
          url:
              'https://media.istockphoto.com/id/1319184864/tr/vekt%C3%B6r/tropikal-yapraklar-%C3%BCzerinde-te%C5%9Fekk%C3%BCr-vekt%C3%B6r-yaz%C4%B1s%C4%B1-izole.jpg?s=612x612&w=0&k=20&c=kYuohcPYWEaqUQRjvFI8ID55C1kB_nspYEB92fjPG3I=',
          mediaType: MediaType.image,
          duration: 5,
        ),
      
      ]
    ]));
// end of stories
// controller 
    _controller.initialize();
    mainbloc.add(PlayPauseEvent(true));
    _watchingProgress();
  }

  @override
  void dispose() {
    super.dispose();
    watcher.cancel();
    _controller.dispose();
  }
// story reset function
  // ignore: non_constant_identifier_names
  void story_reset() {
    watcher.cancel();
    timercount = 0;
    mainbloc.add(PlayPauseEvent(false));
    mainbloc.add(ProgressTrackerInitiate(0));
    _controller.pause();
    _controller.seekTo(Duration.zero);

    _watchingProgress();
  }
// action function
  void _onTap(double dx) {
    if (dx < (MediaQuery.of(context).size.width / 2)) {
      if (mainbloc.state.currentStoryIndex > 0) {
        story_reset();

        mainbloc.add(PreviousStoryEvent(1));
      } else if (mainbloc.state.currentStoryIndex ==
              mainbloc.state.stories[mainbloc.state.currenstorylistindex]
                      .length -
                  1 &&
          mainbloc.state.currenstorylistindex !=
              mainbloc.state.stories.length - 1) {
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));
      } else if (mainbloc.state.currentStoryIndex == 0 &&
          mainbloc.state.currenstorylistindex != 0) {
        controller.previousPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(PreviousStoryGroup(mainbloc.state.currenstorylistindex));

        story_reset();
      }
    } else {
      if (mainbloc.state.currentStoryIndex <
          mainbloc.state.stories[mainbloc.state.currenstorylistindex].length -
              1) {
        mainbloc.add(NextStoryEvent(1));
        story_reset();
      } else {
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));

        story_reset();
      }
    }
  }
// watching control function
// This function is used to actions while watching such as stopping video by touching
// This function sets up a periodic Timer to track the progress of a story

  void _watchingProgress() {
    watcher = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mainbloc.state.runnedseconds < 1 &&
          mainbloc
                  .state
                  .stories[mainbloc.state.currenstorylistindex]
                      [mainbloc.state.currentStoryIndex]
                  .mediaType ==
              MediaType.image) {
        mainbloc.add(PlayPauseEvent(true));
        (mainbloc.state.isPlaying) ? timercount = timercount + 100 : null;
        mainbloc.add(ProgressTrackerInitiate((timercount) /
            (mainbloc
                    .state
                    .stories[mainbloc.state.currenstorylistindex]
                        [mainbloc.state.currentStoryIndex]
                    .duration *
                1000)));
// If the story is a video and the timer has just started, begin playing it
        if (mainbloc.state.storygroupslastseenindex.isNotEmpty) {
          var modiflist = mainbloc.state.storygroupslastseenindex;

          modiflist[mainbloc.state.currenstorylistindex] =
              mainbloc.state.currentStoryIndex;

          mainbloc.add(lastseeningroup(modiflist));
        }
      } else if (mainbloc.state.runnedseconds < 1 &&
          mainbloc
                  .state
                  .stories[mainbloc.state.currenstorylistindex]
                      [mainbloc.state.currentStoryIndex]
                  .mediaType ==
              MediaType.video) {
        mainbloc.state.runnedseconds < 0.1 &&
                _controller.value.buffered.isNotEmpty &&
                (_controller.value.buffered[0].end -
                        _controller.value.buffered[0].start) ==
                    _controller.value.duration &&
                !_controller.value.isPlaying
            ? _controller.play().then((value) {
                timercount = timercount + 100;
                mainbloc.add(PlayPauseEvent(true));
                mainbloc.add(ProgressTrackerInitiate(
                    timercount / _controller.value.duration.inMilliseconds));
              })
            : _controller.value.buffered.isNotEmpty &&
                    _controller.value.isPlaying
                ? {
                    timercount = timercount + 100,
                    mainbloc.add(PlayPauseEvent(true)),
                    mainbloc.add(ProgressTrackerInitiate(timercount /
                        _controller.value.duration.inMilliseconds)),
                  }
                : null;
// If the user has seen previous stories in this group, update the last-seen index
        if (mainbloc.state.storygroupslastseenindex.isNotEmpty &&
            mainbloc
                    .state
                    .stories[mainbloc.state.currenstorylistindex]
                        [mainbloc.state.currentStoryIndex]
                    .mediaType ==
                MediaType.video) {
          var modiflist = mainbloc.state.storygroupslastseenindex;

          modiflist[mainbloc.state.currenstorylistindex] =
              mainbloc.state.currentStoryIndex;

          mainbloc.add(lastseeningroup(modiflist));
        }
      } else if (mainbloc.state.runnedseconds >= 1) {
        timercount = 0;
        timer.cancel();

        if (mainbloc.state.currentStoryIndex <
            mainbloc.state.stories[mainbloc.state.currenstorylistindex].length -
                1) {
          mainbloc.add(NextStoryEvent(1));
          story_reset();
        } else {
          if (mainbloc.state.currenstorylistindex <
              mainbloc.state.stories.length - 1) {
            mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));

            controller
                .animateToPage(1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linear)
                .then((value) {
              story_reset();
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var phowidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                mainbloc.add(PlayPauseEvent(false));
                watcher.cancel();
                _controller.pause();
                touchdiff = event.timeStamp.inMilliseconds;
                poseval = event.position.dx;
              },
              onPointerUp: (event) {
                if ((event.timeStamp.inMilliseconds - touchdiff).abs() < 100 &&
                    (poseval - event.position.dx).abs() < 10) {
                  _onTap(event.position.dx);
                } else if ((poseval - event.position.dx).abs() <= 20) {
                  mainbloc
                              .state
                              .stories[mainbloc.state.currenstorylistindex]
                                  [mainbloc.state.currentStoryIndex]
                              .mediaType ==
                          MediaType.video
                      ? _controller.play()
                      : null;

                  _watchingProgress();
                } else {
                  story_reset();
                }
              },
              child: Container(
                width: phowidth,
                color: Colors.black,
                child: ValueListenableBuilder(
                    valueListenable: _pageNotifier,
                    builder: (BuildContext context, value, child) {
                      return PageView.builder(
                          controller: controller,
                          onPageChanged: (pagech) {
                            if (pagech != mainbloc.state.currenstorylistindex) {
                              if (pagech >=
                                  mainbloc.state.currenstorylistindex) {
                                mainbloc.add(NextStoryGroup(
                                    mainbloc.state.currenstorylistindex));
                              } else if (pagech <=
                                  mainbloc.state.currenstorylistindex) {
                                mainbloc.add(PreviousStoryGroup(
                                    mainbloc.state.currenstorylistindex));
                              }
                              story_reset();
                            }
                          },
                          itemCount: mainbloc.state.stories.isNotEmpty
                              ? mainbloc
                                  .state
                                  .stories[mainbloc.state.currenstorylistindex]
                                  .length
                              : null,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          itemBuilder: (BuildContext context, position) {
                            double? opacu =
                                lerpDouble(0, 1, (position - value).abs());

                            return BlocBuilder<StoryBloc, StoryState>(
                                bloc: mainbloc,
                                builder: (BuildContext context, state) {
                                  if (state.stories.isNotEmpty) {
                                    if (state.stories.isNotEmpty &&
                                        state.storygroupslastseenindex
                                            .isNotEmpty) {
                                      return Opacity(
                                        opacity: 1 - opacu!,
                                        child: Transform(
                                          transform: Matrix4.identity()
                                            ..rotateY(-(pi / 180) *
                                                (lerpDouble(0, 90,
                                                        position - value)!
                                                    .toInt()))
                                            ..setEntry(3, 2, 0.8),
                                          alignment: (position -
                                                      _pageNotifier.value) <=
                                                  0
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Stack(
                                            children: [
                                              state
                                                          .stories[state
                                                                  .currenstorylistindex]
                                                              [state
                                                                  .currentStoryIndex]
                                                          .mediaType ==
                                                      MediaType.video
                                                  ? _controller.value.buffered
                                                              .isNotEmpty ||
                                                          _controller
                                                              .value.isPlaying
                                                      ? videoplayerwidget(
                                                          videourl: mainbloc
                                                              .state
                                                              .stories[mainbloc
                                                                      .state
                                                                      .currenstorylistindex]
                                                                  [mainbloc
                                                                      .state
                                                                      .currentStoryIndex]
                                                              .url,
                                                          controller:
                                                              _controller,
                                                        )
                                                      : const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                  : Center(
                                                      child: Image.network(
                                                        state
                                                            .stories[state
                                                                    .currenstorylistindex]
                                                                [state
                                                                    .currentStoryIndex]
                                                            .url,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          if (loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes! !=
                                                              1) {
                                                            watcher.cancel();
                                                            mainbloc.add(
                                                                PlayPauseEvent(
                                                                    false));
                                                          } else {
                                                            story_reset();
                                                          }

                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : 0,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                              state
                                                              .stories[state
                                                                      .currenstorylistindex]
                                                                  [state
                                                                      .currentStoryIndex]
                                                              .mediaType ==
                                                          MediaType.video &&
                                                      (!_controller.value
                                                              .isInitialized ||
                                                          !_controller.value
                                                              .isPlaying) &&
                                                      timercount == 0
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              mainbloc.state.stories.isNotEmpty
                                                  ? SafeArea(
                                                      child: _buildBars(mainbloc
                                                          .state
                                                          .stories[state
                                                              .currenstorylistindex]
                                                          .length),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  return const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 5,
                                  );
                                });
                          });
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBars(int count) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < count; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TweenAnimationBuilder<double>(
                    duration: mainbloc.state.runnedseconds == 0
                        ? Duration.zero
                        : const Duration(milliseconds: 100),
                    curve: Curves.linear,
                    tween: Tween<double>(
                      begin: 0,
                      end: mainbloc.state.runnedseconds,
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          color: Colors.white,
                          value: mainbloc.state.currentStoryIndex == i
                              ? value
                              : mainbloc.state.currentStoryIndex < i
                                  ? 0
                                  : 1,
                        )),
              ),
            )
        ],
      ),
    );
  }
}
// videoplayer
// ignore: camel_case_types
class videoplayerwidget extends StatefulWidget {
  const videoplayerwidget(
      {super.key, required this.videourl, required this.controller});
  final String videourl;
  final VideoPlayerController controller;

  @override
  State<videoplayerwidget> createState() => _videoplayerwidgetState();
}

// ignore: camel_case_types
class _videoplayerwidgetState extends State<videoplayerwidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller)),
    );
  }
}