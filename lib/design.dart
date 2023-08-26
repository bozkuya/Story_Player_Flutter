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

// design state class
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
      'https://cdn.coverr.co/videos/coverr-friends-walking-down-a-road-7441/1080p.mp4?download=true',
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
          name: 'photo',
          url:
              'https://th.bing.com/th/id/R.2326f864b017d6d4edda5b2f1a15ebd6?rik=qaWh3vpmwuP%2f5Q&pid=ImgRaw&r=0',
          mediaType: MediaType.image,
          duration: 5,
        ),
        Story(
          isseen: false,
          name: 'video_1',
          url:
              'https://cdn.coverr.co/videos/coverr-friends-walking-down-a-road-7441/1080p.mp4?download=true',
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
              'https://cdn.coverr.co/videos/coverr-friends-walking-down-a-road-7441/1080p.mp4?download=true',
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
// This function is called when the user taps on the screen
  void _onTap(double dx) {
    // Check if the user tapped on the left side of the screen
    if (dx < (MediaQuery.of(context).size.width / 2)) {
      // If the current story is not the first one, go to the previous story
      if (mainbloc.state.currentStoryIndex > 0) {
        // Reset the current story to its initial state
        story_reset();

        mainbloc.add(PreviousStoryEvent(1));
        // If the current story is the last one in the current story list and there are more story lists, go to the next story list
      } else if (mainbloc.state.currentStoryIndex ==
              mainbloc.state.stories[mainbloc.state.currenstorylistindex]
                      .length -
                  1 &&
          mainbloc.state.currenstorylistindex !=
              mainbloc.state.stories.length - 1) {
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
            // Trigger an event to go to the next story list
        mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));
        // If the current story is the first one in the current story list and there are previous story lists, go to the previous story list
      } else if (mainbloc.state.currentStoryIndex == 0 &&
          mainbloc.state.currenstorylistindex != 0) {
        controller.previousPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
        mainbloc.add(PreviousStoryGroup(mainbloc.state.currenstorylistindex));

        story_reset();
      }
      // If the user tapped on the right side of the screen
    } else {
      if (mainbloc.state.currentStoryIndex <
          mainbloc.state.stories[mainbloc.state.currenstorylistindex].length -
              1) {
        mainbloc.add(NextStoryEvent(1));
        story_reset();
        // Go to the next page in the PageView
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
// Check if the list of last seen story groups is not empty
        if (mainbloc.state.storygroupslastseenindex.isNotEmpty) {
          var modiflist = mainbloc.state.storygroupslastseenindex;

          modiflist[mainbloc.state.currenstorylistindex] =
              mainbloc.state.currentStoryIndex;

          mainbloc.add(lastseeningroup(modiflist));
        }
        // If the current story is a video and less than 1 second has elapsed
      } else if (mainbloc.state.runnedseconds < 1 &&
      // If the video has not started playing and has finished buffering, start playing the video and trigger events to update the UI
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
              // If the video is already playing and has buffered data, trigger events to update the UI
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
         // Create a copy of the list of last seen story groups
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
        // If the story has been running for at least 1 second
      } else if (mainbloc.state.runnedseconds >= 1) {
        timercount = 0;
        timer.cancel();
        // Check if there are more stories in the current story list
        if (mainbloc.state.currentStoryIndex <
            mainbloc.state.stories[mainbloc.state.currenstorylistindex].length -
                1) {
          mainbloc.add(NextStoryEvent(1));
          story_reset();
        } else {
          if (mainbloc.state.currenstorylistindex <
              mainbloc.state.stories.length - 1) {
            mainbloc.add(NextStoryGroup(mainbloc.state.currenstorylistindex));
            // Animate to the second page in the PageView and reset the current story to its initial state
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
    // Get the width of the device screen
    var phowidth = MediaQuery.of(context).size.width;

    return Scaffold(
       // Set the background color of the scaffold
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Listener(
              // When the user starts touching the screen
              onPointerDown: (event) {
                // Pause the video and stop the progress watcher
                mainbloc.add(PlayPauseEvent(false));
                watcher.cancel();
                _controller.pause();
                touchdiff = event.timeStamp.inMilliseconds;
                poseval = event.position.dx;
              },
              // When the user stops touching the screen
              onPointerUp: (event) {
                // If the touch was short and still, trigger an onTap event
                if ((event.timeStamp.inMilliseconds - touchdiff).abs() < 100 &&
                    (poseval - event.position.dx).abs() < 10) {
                  _onTap(event.position.dx);
                  // If the touch was short and moved slightly, play the video and start the progress watcher.
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
                  // If the touch was long or moved significantly, reset the story
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
                          // When the page changes
                          onPageChanged: (pagech) {
                            // If the new page is a different story group than the current one
                            if (pagech != mainbloc.state.currenstorylistindex) {
                              // If the new page is after the current one, trigger an event to go to the next story group
                              if (pagech >=
                                  mainbloc.state.currenstorylistindex) {
                                mainbloc.add(NextStoryGroup(
                                    mainbloc.state.currenstorylistindex));
                                    // If the new page is before the current one, trigger an event to go to the previous story group
                              } else if (pagech <=
                                  mainbloc.state.currenstorylistindex) {
                                mainbloc.add(PreviousStoryGroup(
                                    mainbloc.state.currenstorylistindex)); 
                              }
                              // Reset the current story to its initial state
                              story_reset();
                            }
                          },
                          // Set the number of items in the PageView
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
                            // Calculate the opacity of the item based on its position
                            double? opacu =
                                lerpDouble(0, 1, (position - value).abs());

                            return BlocBuilder<StoryBloc, StoryState>(
                                bloc: mainbloc,
                                builder: (BuildContext context, state) {
                                  // Check if there are any stories
                                  if (state.stories.isNotEmpty) {
                                    if (state.stories.isNotEmpty &&
                                        state.storygroupslastseenindex
                                            .isNotEmpty) {
                                      // Create a stack with the story content
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
                                               // Display the video or image based on the media type
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
class videoplayerwidget extends StatelessWidget {
  const videoplayerwidget({Key? key, required this.videourl, required this.controller}) : super(key: key);
  final String videourl;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}

