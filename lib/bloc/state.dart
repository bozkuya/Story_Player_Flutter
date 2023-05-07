//import libraries
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storyplayer/bloc/event.dart';
// define the state of the story
class StoryState extends Equatable {
  final List<List> stories;
  final int currentStoryIndex;
  final int currenstorylistindex;
  final bool isPlaying;
  final double runnedseconds;
  final List<int> storygroupslastseenindex;
// constructor
  const StoryState({
    this.currenstorylistindex = 0,
    this.stories = const [],
    this.currentStoryIndex = 0,
    this.isPlaying = false,
    this.runnedseconds = 0.0,
    this.storygroupslastseenindex = const [],
  });
// copy constructor
  StoryState copyWith({
    List<List>? stories,
    int? currentStoryIndex,
    int? currenstorylistindex,
    bool? isPlaying,
    double? runnedseconds,
    List<int>? storygroupslastseenindex,
  }) {
    return StoryState(
        currenstorylistindex: currenstorylistindex ?? this.currenstorylistindex,
        stories: stories ?? this.stories,
        currentStoryIndex: currentStoryIndex ?? this.currentStoryIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        runnedseconds: runnedseconds ?? this.runnedseconds,
        storygroupslastseenindex:
            storygroupslastseenindex ?? this.storygroupslastseenindex);
  }
// Boolean variable to intentify whether it is the first or the last story.
// If both of the variables (flags) are false, it is playing a middle story. 
  bool get isLastStory => currentStoryIndex == stories.length - 1;
  bool get isFirststory => currentStoryIndex == 0;

  @override
  List<Object?> get props => [
        stories, // List of stories being displayed
        currentStoryIndex, // Index of the current story being displayed
        isPlaying, // Whether the story is currently playing or paused
        runnedseconds, // Number of seconds the current story has been playing
        currenstorylistindex, // Index of the current story group being displayed
        storygroupslastseenindex // List of indices for the last seen story in each story group
      ];
}
// Represents a single story in the list of stories being displayed
class Story {
  final String name;
  final String url;
  final MediaType mediaType;
  final double duration;
  bool isseen;
//constructor
  Story({
    required this.isseen,
    required this.name,
    required this.url,
    required this.mediaType,
    required this.duration,
  });
}
// types are defined 
//It can play video or images
enum MediaType {
  image,
  video,
}
// defination of story block
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  StoryBloc() : super(const StoryState()) {
    // When a LoadStoryEvent is triggered, update the state with the new list of stories
    on<LoadStoryEvent>((event, emit) => {
          emit(StoryState(
              stories: event.storylist,
              storygroupslastseenindex:
                  List.generate(event.storylist.length, (index) => 0))),
        });
        
    // When a PreviousStoryEvent is triggered, move to the previous story in the list
    on<PreviousStoryEvent>(
      (event, emit) => emit(state.copyWith(
        runnedseconds: 0.0,
        currentStoryIndex: state.currentStoryIndex - 1,
      )),
    );
    // When a NextStoryGroup event is triggered, move to the next group of stories
    on<NextStoryGroup>(
      (event, emit) => {
        emit(state.copyWith(
          runnedseconds: 0.0,
          currenstorylistindex: state.currenstorylistindex + 1,
          currentStoryIndex:
              state.storygroupslastseenindex[event.currentgroup + 1],
        )),
      },
    );
   // When a PreviousStoryGroup event is triggered, move to the previous group of stories
    on<PreviousStoryGroup>(
      (event, emit) => emit(state.copyWith(
          runnedseconds: 0.0,
          currentStoryIndex:
              state.storygroupslastseenindex[event.currentgroup - 1],
          currenstorylistindex: state.currenstorylistindex - 1)),
    );
    on<NextStoryEvent>((event, emit) => {
          if (state.stories[state.currentStoryIndex][0].mediaType ==
              MediaType.image)
            {
              emit(state.copyWith(
                  runnedseconds: 0.0,
                  currentStoryIndex: state.currentStoryIndex + 1)),
            }
          else
            {
              emit(state.copyWith(
                  runnedseconds: 0.0,
                  currentStoryIndex: state.currentStoryIndex + 1)),
            },
        });
        // When a PlayPauseEvent is triggered, update the isPlaying flag
    on<PlayPauseEvent>(
      (event, emit) => emit(state.copyWith(isPlaying: event.isPlaying)),
    );
    on<lastseeningroup>(
      (event, emit) => {
       

        emit(state.copyWith(storygroupslastseenindex: event.currentIndex)),
      },
    );
    on<ProgressTrackerInitiate>((event, emit) => emit(
          state.copyWith(
            runnedseconds: event.runnedseconds,
          ),
        ));
  }
}
