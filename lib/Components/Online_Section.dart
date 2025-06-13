import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

import '../utilities/color_theme.dart';

class online_section extends StatefulWidget {
  const online_section({super.key, required this.notePrefix});

  final String notePrefix;
  @override
  State<online_section> createState() => _online_sectionState();
}

class _online_sectionState extends State<online_section> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter a new note...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.amber),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.amber),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.background,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Iconify(
                    Ic.round_insert_drive_file,
                    color: AppTheme.accentYellow,
                    size: 30,
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Iconify(
                      Ic.round_file_download,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                  title: Text(
                    '${widget.notePrefix} $index',
                    style: const TextStyle(color: Colors.white),
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
    );
  }
}
