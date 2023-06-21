import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Activity> activities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var activity in activities) _buildActivitySection(activity),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addActivity(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildActivitySection(Activity activity) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () => _addContent(activity),
                icon: Icon(Icons.add),
              ),
            ],
          ),
          SizedBox(height: 8),
          activity.contents.isNotEmpty
              ? Column(
                  children: [
                    _buildContentItem(activity, activity.currentContentIndex),
                    if (activity.contents.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => _toggleContent(activity, -1),
                            icon: Icon(Icons.arrow_back),
                          ),
                          IconButton(
                            onPressed: () => _toggleContent(activity, 1),
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                  ],
                )
              : Text('No content'),
        ],
      ),
    );
  }

  Widget _buildContentItem(Activity activity, int index) {
    final content = activity.contents[index];

    if (content is TextContent) {
      return ListTile(
        leading: Icon(content.icon),
        title: Text(content.text),
      );
    } else if (content is ImageContent) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Image(
          image: FileImage(content.imageFile),
          fit: BoxFit.contain,
          width: double.infinity,
          height: 200,
        ),
      );
    } else if (content is VideoContent) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: AspectRatio(
          aspectRatio: content.videoController.value.aspectRatio,
          child: VideoPlayer(content.videoController),
        ),
      );
    } else {
      return Container();
    }
  }

  void _toggleContent(Activity activity, int direction) {
    final currentContentIndex = activity.currentContentIndex ?? 0;

    int nextIndex = currentContentIndex + direction;
    if (nextIndex < 0) {
      nextIndex = activity.contents.length - 1;
    } else if (nextIndex >= activity.contents.length) {
      nextIndex = 0;
    }

    setState(() {
      activity.currentContentIndex = nextIndex;
    });
  }

  void _addActivity() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';

        return AlertDialog(
          title: Text('Add Activity'),
          content: TextField(
            onChanged: (value) {
              title = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  activities.add(
                    Activity(
                      title: title,
                      contents: [], // Initialize contents as an empty list
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addContent(Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Content'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(FluentIcons.note_20_filled),
                  title: Text('Text Content'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addTextContent(activity);
                  },
                ),
                ListTile(
                  leading: Icon(FluentIcons.image_24_regular),
                  title: Text('Image Content'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addImageContent(activity);
                  },
                ),
                ListTile(
                  leading: Icon(FluentIcons.video_clip_24_regular),
                  title: Text('Video Content'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addVideoContent(activity);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTextContent(Activity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String text = '';

        return AlertDialog(
          title: Text('Add Text Content'),
          content: TextField(
            onChanged: (value) {
              text = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  activity.contents.add(
                    TextContent(icon: FluentIcons.note_20_filled, text: text),
                  );
                  activity.currentContentIndex = activity.contents.length - 1;
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addImageContent(Activity activity) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        final imageFile = File(pickedFile.path);
        final imageContent = ImageContent(imageFile: imageFile);
        activity.contents.add(imageContent);
        activity.currentContentIndex = activity.contents.length - 1;
      });
    }
  }

  void _addVideoContent(Activity activity) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final videoController = VideoPlayerController.file(File(pickedFile.path));

      await videoController.initialize();

      setState(() {
        activity.contents.add(
          VideoContent(videoController: videoController),
        );
      });
    }
  }

  @override
  void dispose() {
    for (var activity in activities) {
      for (var content in activity.contents) {
        if (content is VideoContent) {
          content.videoController.dispose();
        }
      }
    }
    super.dispose();
  }
}

class Activity {
  final String title;
  final List<Content> contents;
  int currentContentIndex;

  Activity({
    required this.title,
    this.contents = const [],
    this.currentContentIndex = 0,
  });
}

abstract class Content {}

class TextContent extends Content {
  final IconData icon;
  final String text;

  TextContent({required this.icon, required this.text});
}

class ImageContent extends Content {
  final File imageFile;

  ImageContent({required this.imageFile});
}

class VideoContent extends Content {
  final VideoPlayerController videoController;

  VideoContent({required this.videoController});
}
