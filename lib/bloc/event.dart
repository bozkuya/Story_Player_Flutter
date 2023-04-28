// This is an abstract class representing a base class for different types
abstract class StoryEvent {}
// This class demonstrates an event where a list of stories is being loaded.
class LoadStoryEvent extends StoryEvent {
  final List<List> storylist;
// Constructor that takes a required list of stories.
  LoadStoryEvent({required this.storylist});

  List get props => [storylist];
}
// This class represents an event where the user clicks on the play/pause button.
class PlayPauseEvent extends StoryEvent {
  // isPlaying boolean variable is used for flagging the condition whether it is playin or not.
  final bool isPlaying;

  PlayPauseEvent(this.isPlaying);
}

class ProgressTrackerInitiate extends StoryEvent {
  final double runnedseconds;

  ProgressTrackerInitiate(this.runnedseconds);
}

class NextStoryEvent extends StoryEvent {
  final int currentIndex;

  NextStoryEvent(this.currentIndex);
}
// This class represents an event where the user clicks on the next story group button.
class NextStoryGroup extends StoryEvent {
  final int currentgroup;

  NextStoryGroup(this.currentgroup);
}
// represents previous story 
class PreviousStoryEvent extends StoryEvent {
  final int currentIndex;

  PreviousStoryEvent(this.currentIndex);
}

class PreviousStoryGroup extends StoryEvent {
  final int currentgroup;

  PreviousStoryGroup(this.currentgroup);
}

// ignore: camel_case_types
class lastseeningroup extends StoryEvent {
  final List<int> currentIndex;

  lastseeningroup(this.currentIndex);
}
