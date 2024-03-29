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
    // The number of seconds that have elapsed since the story started playing
  final double runnedseconds;

  ProgressTrackerInitiate(this.runnedseconds);
}
// This event is triggered when the user clicks on the next story group button
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
// This event is triggered when the user clicks on the previous story group button
class PreviousStoryGroup extends StoryEvent {
  final int currentgroup;

  PreviousStoryGroup(this.currentgroup);
}
// This event is triggered when the user has seen the last story group
// ignore: camel_case_types
class lastseeningroup extends StoryEvent {
  final List<int> currentIndex;

  lastseeningroup(this.currentIndex);
}
