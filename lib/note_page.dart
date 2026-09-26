import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'components/shared.dart';
import 'models.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key, required this.note, required this.notesManager});
  final Note note;
  final NotesCollectionManager notesManager;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final contentController = TextEditingController();
  final contentFocus = FocusNode();
  final scrollController = ScrollController();
  @override
  void initState() {
    contentController.text = widget.note.content;
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => contentFocus.requestFocus(),
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
          widget.note.title,
          maxLines: 2,
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              widget.notesManager.update(widget.note, newContent: contentController.text);
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
                      return ConfirmDocDeletionDialog(
                        deletedName: widget.note.title,
                      );
                    },
                  );
                  if (isConfirmed == true) {
                    widget.notesManager.delete(widget.note);
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
