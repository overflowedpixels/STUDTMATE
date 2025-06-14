import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:study_mate/Components/snackbar.dart';
import 'package:study_mate/pages/focusMode.dart';
import 'package:study_mate/utilities/color_theme.dart';

import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class SavedSectionLoader extends StatefulWidget {
  final String fpath;
  const SavedSectionLoader({super.key, required this.fpath});
  @override
  State<SavedSectionLoader> createState() => _SavedSectionLoaderState();
}

class _SavedSectionLoaderState extends State<SavedSectionLoader> {
  String savedSection = 'Loading...';

  List<String> fileNames = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    try {
      final downloadsDir = Directory(widget.fpath);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      print(downloadsDir);
      final files = downloadsDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .map((file) => file.path.split('/').last)
          .toList();

      setState(() {
        fileNames = files;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> openfile(String filepath) async {
    try {
      await OpenFile.open(filepath);
    } catch (e) {
      showAlert(
        context,
        'Could not open file.',
        color: Colors.red,
        icon: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return fileNames.isNotEmpty
        ? Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: fileNames.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Iconify(
                            Ic.round_insert_drive_file,
                            color: AppTheme.card,
                            size: 30,
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Iconify(
                              Ic.more_vert,
                              color: AppTheme.accentYellow,
                            ),
                            onSelected: (value) async {
                              final filepath =
                                  '${widget.fpath}/${fileNames[index]}';

                              if (value == 'share') {
                                final params = ShareParams(
                                  text: "Shared through Studymate",
                                  files: [XFile(filepath)],
                                );
                                await SharePlus.instance.share(params);
                              } else if (value == 'delete') {
                                File delFile = File(filepath);
                                try {
                                  await delFile.delete();
                                  if (context.mounted) {
                                    showAlert(
                                      context,
                                      "File deleted successfully",
                                      icon: Icons.delete_forever,
                                    );
                                    setState(() {
                                      fileNames.removeAt(index);
                                    });
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showAlert(
                                      context,
                                      "Try again",
                                      color: Colors.redAccent,
                                    );
                                  }
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FocusModePage(
                                      fpath:
                                          '${widget.fpath}/${fileNames[index]}',
                                    ),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => const [
                              PopupMenuItem(
                                value: 'share',
                                child: Text('Share'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                              PopupMenuItem(
                                value: 'focus',
                                child: Text('Open in focus mode'),
                              ),
                            ],
                          ),
                          title: GestureDetector(
                            child: Text(
                              fileNames[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              final filePath =
                                  '${widget.fpath}/${fileNames[index]}';
                              await openfile(filePath);
                            },
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: AppTheme.card,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Iconify(Ep.circle_close, color: Colors.white, size: 100),
                SizedBox(height: 10),
                Text(
                  'No saved files found',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          );
  }
}
