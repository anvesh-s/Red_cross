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
              () => _addAnnouncementForSection(true),
              () => _addImageAnnouncement(true),
              () => _addVideoAnnouncement(true),
            ),
            _buildAnnouncementSection(
              'Local Branch Announcement',
              localBranchAnnouncements,
              () => _addAnnouncementForSection(false),
              () => _addImageAnnouncement(false),
              () => _addVideoAnnouncement(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection(
    String sectionTitle,
    List<Announcement> announcements,
    VoidCallback onAddText,
    VoidCallback onAddImage,
    VoidCallback onAddVideo,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                onPressed: onAddText,
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: onAddImage,
                icon: Icon(Icons.add_photo_alternate),
              ),
              IconButton(
                onPressed: onAddVideo,
                icon: Icon(Icons.video_call),
              ),
            ],
          ),
          SizedBox(height: 8),
          announcements.isNotEmpty
              ? Column(
                  children: announcements.map((announcement) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          if (announcement.imageFile != null)
                            Image.file(
                              announcement.imageFile!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 200,
                            ),
                          ListTile(
                            leading: Icon(announcement.icon),
                            title: Text(''),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : Text('No announcement'),
        ],
      ),
    );
  }

  void _addAnnouncementForSection(bool isMainBranch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String text = '';

        return AlertDialog(
          title: Text('Add Announcement'),
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
    // how to video no clue will learn
    print('Add video announcement');
  }
}

class Announcement {
  final IconData icon;
  final File? imageFile;

  Announcement({
    required this.icon,
    this.imageFile,
  });
}
