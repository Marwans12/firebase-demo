import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key, required this.note});
  final DocumentSnapshot<Map<String, dynamic>> note;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final contentController = TextEditingController();
  final contentFocus = FocusNode();
  final scrollController = ScrollController();
  late final noteReference = widget.note.reference;
  @override
  void initState() {
    contentController.text = widget.note.get("content");
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => contentFocus.requestFocus(),
    );
    super.initState();
  }

  @override
  void dispose() {
    contentController.dispose();
    contentFocus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note.get("name"),
          maxLines: 2,
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await noteReference.update({"content": contentController.text});
              if (context.mounted) {
                navigator.pop();
              }
            },
            icon: Icon(Icons.save),
          ),
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () async {
                  var isConfirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return ConfirmNoteDeletionDialog(note: widget.note);
                    },
                  );
                  if (isConfirmed == true) {
                    noteReference.delete();
                    navigator.pop();
                  }
                },
                child: Text("Delete"),
              ),
            ],
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  controller.open();
                },
                icon: Icon(Icons.more_vert_rounded),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: SizedBox.expand(
            child: Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: TextField(
                controller: contentController,
                focusNode: contentFocus,
                scrollController: scrollController,
                maxLines: null,
                decoration: null,
                // textAlignVertical: .top,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class ConfirmNoteDeletionDialog extends StatelessWidget {
  const ConfirmNoteDeletionDialog({
    super.key,
    required this.note,
  });

  final DocumentSnapshot note;

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text(
        "Are you sure you want to delete '${note.get("name")}'?",
      ),
      actions: [
        Theme(
          data: ThemeData(
            colorScheme: ColorScheme.of(
              context,
            ).copyWith(primary: Colors.black87),
          ),
          child: TextButton(
            onPressed: () => navigator.pop(),
            child: Text("Cancel"),
          ),
        ),
        Theme(
          data: ThemeData(
            colorScheme: ColorScheme.of(
              context,
            ).copyWith(primary: Colors.red),
          ),
          child: TextButton(
            onPressed: () => navigator.pop(true),
            child: Text("Delete"),
          ),
        ),
      ],
    );
  }
}