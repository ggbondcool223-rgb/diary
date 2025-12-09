import 'dart:async';
import 'package:diary/pages/diary_second/diary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'note_edit_logic.dart';

class NoteEditPage extends StatefulWidget {
  const NoteEditPage({super.key});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  NoteEditLogic controller = Get.find();
  Timer? _autoSaveTimer;
  int _characterCount = 0;
  final int _maxLength = 300;
  
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  static const int _maxHistorySize = 20;
  var _isRestoringState = false;
  
  @override
  void initState() {
    super.initState();
    _startAutoSave();
    _loadDraft();
    _updateCharacterCount();
  }
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveDraft();
    super.dispose();
  }
  
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _saveDraft();
    });
  }
  
  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = {
        'content': controller.content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('note_draft', jsonEncode(draftData));
    } catch (e) {
      print('Error saving draft: $e');
    }
  }
  
  Future<void> _loadDraft() async {
    try {
      if (controller.diaryEntity != null) return;
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('note_draft');
      if (draftJson != null) {
        final draftData = jsonDecode(draftJson);
        final draftTime = DateTime.parse(draftData['timestamp']);
        final now = DateTime.now();
        if (now.difference(draftTime).inHours < 24) {
          controller.content = draftData['content'] ?? '';
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
  }
  
  void _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('note_draft');
    } catch (e) {
      print('Error clearing draft: $e');
    }
  }
  
  void _insertDateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final currentText = controller.content;
    controller.content = currentText.isEmpty 
        ? formatted 
        : '$currentText\n$formatted';
    setState(() {});
  }
  
  void _updateCharacterCount() {
    _characterCount = controller.content.length;
    setState(() {});
  }
  
  void _saveState() {
    _undoStack.add(controller.content);
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }
  
  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(controller.content);
    if (_redoStack.length > _maxHistorySize) {
      _redoStack.removeAt(0);
    }
    controller.content = _undoStack.removeLast();
    setState(() {
      _updateCharacterCount();
    });
  }
  
  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(controller.content);
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
    controller.content = _redoStack.removeLast();
    setState(() {
      _updateCharacterCount();
    });
  }
  
  bool _canUndo() => _undoStack.isNotEmpty;
  bool _canRedo() => _redoStack.isNotEmpty;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit note'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.undo, size: 20, color: _canUndo() ? Colors.black : Colors.grey),
                onPressed: _canUndo() ? _undo : null,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: Icon(Icons.redo, size: 20, color: _canRedo() ? Colors.black : Colors.grey),
                onPressed: _canRedo() ? _redo : null,
                tooltip: 'Redo',
              ),
              IconButton(
                icon: const Icon(Icons.access_time, size: 20),
                onPressed: _insertDateTime,
                tooltip: 'Insert date/time',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _characterCount > _maxLength 
                      ? Colors.red.withOpacity(0.1)
                      : _characterCount > _maxLength * 0.9
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_characterCount/$_maxLength',
                  style: TextStyle(
                    fontSize: 12,
                    color: _characterCount > _maxLength 
                        ? Colors.red 
                        : _characterCount > _maxLength * 0.9
                            ? Colors.orange
                            : Colors.grey,
                    fontWeight: _characterCount > _maxLength * 0.9 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                controller.diaryEntity == null ? 'Commit' : 'Delete',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ).marginOnly(right: 20).gestures(onTap: () {
                if (controller.diaryEntity == null) {
                  if (_characterCount > _maxLength) {
                    Fluttertoast.showToast(msg: 'Character limit exceeded');
                    return;
                  }
                  _clearDraft();
                  controller.addData();
                } else {
                  controller.deleteDiary();
                }
              }),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
            child: GetBuilder<NoteEditLogic>(builder: (_) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: <Widget>[
              <Widget>[
                Image.asset('assets/icon3.png'),
                SizedBox(
                  width: 270,
                  height: 210,
                  child: IgnorePointer(
                    ignoring: controller.diaryEntity != null,
                    child: DiaryTextField(
                        value: controller.content,
                        readOnly: controller.diaryEntity != null,
                        maxLength: 300,
                        maxLines: 10,
                        onChange: (v) {
                          if (_isRestoringState) return;
                          
                          if (v.length <= _maxLength) {
                            controller.content = v;
                            _saveState();
                          } else {
                            Fluttertoast.showToast(msg: 'Character limit reached');
                          }
                          _updateCharacterCount();
                          _saveDraft();
                        }),
                  ),
                ).marginOnly(top: 40)
              ].toStack(alignment: Alignment.center)
            ].toColumn(),
          );
        }).marginAll(15)),
      ).decorated(
          image: const DecorationImage(
              image: AssetImage('assets/bg1.png'), fit: BoxFit.fill)),
    );
  }
}
