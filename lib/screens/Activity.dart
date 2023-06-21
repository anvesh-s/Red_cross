/*import 'dart:io';

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
    final List<Content> imageContents =
        activity.contents.whereType<ImageContent>().toList();
    final List<Content> nonImageContents =
        activity.contents.where((content) => content is! ImageContent).toList();

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
          Stack(
            children: [
              if (imageContents.isNotEmpty) _buildImageContentItem(activity),
            ],
          ),
          if (imageContents.length > 1)
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var content in nonImageContents) _buildContentItem(content),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageContentItem(Activity activity) {
    final currentIndex = activity.currentContentIndex ?? 0;
    final currentContent = activity.contents[currentIndex] as ImageContent;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Image(
        image: FileImage(currentContent.imageFile),
        fit: BoxFit.contain,
        width: double.infinity,
        height: 200,
      ),
    );
  }

  Widget _buildContentItem(Content content) {
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
                  if (activity.contents.length == 1) {
                    activity.currentContentIndex = 0;
                  }
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
        if (activity.contents.length == 1) {
          activity.currentContentIndex = 0;
        }
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
        if (activity.contents.length == 1) {
          activity.currentContentIndex = 0;
        }
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
*/
/*import 'dart:io';

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
            for (var activity in activities) _buildActivityCard(activity),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addActivity(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final List<Content> imageContents =
        activity.contents.whereType<ImageContent>().toList();
    final List<Content> nonImageContents =
        activity.contents.where((content) => content is! ImageContent).toList();

    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              activity.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              onPressed: () => _addContent(activity),
              icon: Icon(Icons.add),
            ),
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              if (imageContents.isNotEmpty) _buildImageContentItem(activity),
            ],
          ),
          if (imageContents.length > 1)
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
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var content in nonImageContents) _buildContentItem(content),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageContentItem(Activity activity) {
    final currentIndex = activity.currentContentIndex ?? 0;
    final currentContent = activity.contents[currentIndex] as ImageContent;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: AspectRatio(
        aspectRatio: 16 / 9, // Set the desired aspect ratio
        child: Image(
          image: FileImage(currentContent.imageFile),
          fit: BoxFit.cover, // Set the fit property to BoxFit.cover
        ),
      ),
    );
  }

  Widget _buildContentItem(Content content) {
    if (content is TextContent) {
      return ListTile(
        title: Text(content.text),
      );
    } else if (content is ImageContent) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(
            image: FileImage(content.imageFile),
            fit: BoxFit.cover,
          ),
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
                      contents: [],
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
                  if (activity.contents.length == 1) {
                    activity.currentContentIndex = 0;
                  }
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
        if (activity.contents.length == 1) {
          activity.currentContentIndex = 0;
        }
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
        if (activity.contents.length == 1) {
          activity.currentContentIndex = 0;
        }
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
}*/

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
    final List<Content> imageContents =
        activity.contents.whereType<ImageContent>().toList();
    final List<Content> nonImageContents =
        activity.contents.where((content) => content is! ImageContent).toList();

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
          Stack(
            children: [
              if (imageContents.isNotEmpty) _buildImageContentItem(activity),
            ],
          ),
          if (imageContents.length > 1)
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < nonImageContents.length; i++)
                _buildContentItem(nonImageContents[i], i),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageContentItem(Activity activity) {
    final currentIndex = activity.currentContentIndex ?? 0;
    final currentContent = activity.contents[currentIndex] as ImageContent;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image(
          image: FileImage(currentContent.imageFile),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContentItem(Content content, int index) {
    if (content is TextContent) {
      return ListTile(
        title: Text(content.text),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _editTextContent(content),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteContent(index),
            ),
          ],
        ),
      );
    } else if (content is ImageContent) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(
                image: FileImage(content.imageFile),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteContent(index),
              ),
            ),
          ],
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
                    TextContent(text: text),
                  );
                  if (activity.contents.length == 1) {
                    activity.currentContentIndex = 0;
                  }
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

  void _editTextContent(TextContent content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedText = content.text;

        return AlertDialog(
          title: Text('Edit Text Content'),
          content: TextField(
            onChanged: (value) {
              updatedText = value;
            },
            controller: TextEditingController(text: content.text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  content.text = updatedText;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
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
        activity.contents.add(
          ImageContent(imageFile: File(pickedFile.path)),
        );
        if (activity.contents.length == 1) {
          activity.currentContentIndex = 0;
        }
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
          VideoContent(
            videoFile: File(pickedFile.path),
            videoController: videoController,
          ),
        );
        if (activity.contents.length == 1) {
          activity.currentContentIndex = 0;
        }
      });
    }
  }

  void _deleteContent(int index) {
    setState(() {
      for (var activity in activities) {
        if (activity.currentContentIndex != null &&
            activity.currentContentIndex! >= index) {
          activity.currentContentIndex = activity.currentContentIndex! - 1;
        }
      }
      activities.forEach((activity) {
        activity.contents.removeAt(index);
      });
    });
  }
}

class Activity {
  String title;
  List<Content> contents;
  int? currentContentIndex;

  Activity({
    required this.title,
    required this.contents,
    this.currentContentIndex,
  });
}

abstract class Content {}

class TextContent extends Content {
  String text;

  TextContent({required this.text});
}

class ImageContent extends Content {
  File imageFile;

  ImageContent({required this.imageFile});
}

class VideoContent extends Content {
  File videoFile;
  VideoPlayerController videoController;

  VideoContent({required this.videoFile, required this.videoController});
}

void main() {
  runApp(MaterialApp(
    title: 'Activity App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: ActivityPage(),
  ));
}
