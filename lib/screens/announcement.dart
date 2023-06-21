import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:image_picker/image_picker.dart';

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  List<Announcement> mainBranchAnnouncements = [];
  List<Announcement> localBranchAnnouncements = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAnnouncementSection(
              'Main Branch Announcement',
              mainBranchAnnouncements,
              isMainBranch: true,
            ),
            _buildAnnouncementSection(
              'Local Branch Announcement',
              localBranchAnnouncements,
              isMainBranch: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection(
    String sectionTitle,
    List<Announcement> announcements, {
    required bool isMainBranch,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addAnnouncement(isMainBranch),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (announcements.isNotEmpty)
                  Row(
                    children: announcements.map((announcement) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Column(
                          children: [
                            if (announcement.text != null) ...[
                              ListTile(
                                leading: Icon(announcement.icon),
                                title: Text(announcement.text!),
                              ),
                            ],
                            if (announcement.imageFile != null)
                              Image.file(
                                announcement.imageFile!,
                                fit: BoxFit.contain,
                                width: 200,
                                height: 200,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  Text('No announcement'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addAnnouncement(bool isMainBranch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String text = '';

        return AlertDialog(
          title: Text('Add Announcement'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(FluentIcons.note_20_filled),
                  title: Text('Text Announcement'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addTextAnnouncement(isMainBranch);
                  },
                ),
                ListTile(
                  leading: Icon(FluentIcons.image_24_regular),
                  title: Text('Image Announcement'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addImageAnnouncement(isMainBranch);
                  },
                ),
                ListTile(
                  leading: Icon(FluentIcons.video_clip_24_regular),
                  title: Text('Video Announcement'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addVideoAnnouncement(isMainBranch);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTextAnnouncement(bool isMainBranch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String text = '';

        return AlertDialog(
          title: Text('Add Text Announcement'),
          content: TextField(
            onChanged: (value) {
              text = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  final newAnnouncement = Announcement(
                    icon: FluentIcons.note_20_filled,
                    text: text,
                  );

                  if (isMainBranch) {
                    mainBranchAnnouncements.add(newAnnouncement);
                  } else {
                    localBranchAnnouncements.add(newAnnouncement);
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

  void _addImageAnnouncement(bool isMainBranch) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        final newAnnouncement = Announcement(
          icon: FluentIcons.image_24_regular,
          imageFile: File(pickedFile.path),
        );

        if (isMainBranch) {
          mainBranchAnnouncements.add(newAnnouncement);
        } else {
          localBranchAnnouncements.add(newAnnouncement);
        }
      });
    }
  }

  void _addVideoAnnouncement(bool isMainBranch) {
    // no video for now AAAAHHHHHHHHHannouncemnt tyoe button
    print('Add video announcement');
  }
}

class Announcement {
  final IconData icon;
  final String? text;
  final File? imageFile;

  Announcement({
    required this.icon,
    this.text,
    this.imageFile,
  });
}
