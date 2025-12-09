import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'diary_edit_logic.dart';

class _EditorState {
  final String text;
  final List<StyledTextSegment> segments;
  
  _EditorState(this.text, this.segments);
}

class DiaryEditPage extends StatefulWidget {
  const DiaryEditPage({super.key});

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  DiaryEditLogic controller = Get.find();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<StyledTextSegment> _textSegments = [];

  TextStyleType _currentStyle = TextStyleType.title;

  bool _showCursor = false;
  Timer? _cursorTimer;
  Timer? _autoSaveTimer;

  final GlobalKey _textFieldKey = GlobalKey();
  
  int _wordCount = 0;
  int _characterCount = 0;
  String _tags = '';
  
  final List<_EditorState> _undoStack = [];
  final List<_EditorState> _redoStack = [];
  static const int _maxHistorySize = 20;
  bool _isRestoringState = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _startCursorTimer();
    _startAutoSave();
    _loadDraft();
    _updateWordCount();
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    _autoSaveTimer?.cancel();
    _saveDraft();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCursorTimer() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_focusNode.hasFocus) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showCursor = true;
      });
    } else {
      setState(() {
        _showCursor = false;
      });
    }
  }

  void _onTextChanged() {
    if (_isRestoringState) return;
    
    final text = _textController.text;

    if (text.isEmpty) {
      setState(() {
        _textSegments.clear();
        _updateWordCount();
      });
      _saveState();
      return;
    }

    _handleTextInput(text);
    _updateWordCount();
  }
  
  void _updateWordCount() {
    final text = _getFullText();
    _characterCount = text.length;
    _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    setState(() {});
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
        'text': _textController.text,
        'segments': _textSegments.map((e) => e.toMap()).toList(),
        'tags': _tags,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('diary_draft', jsonEncode(draftData));
    } catch (e) {
      print('Error saving draft: $e');
    }
  }
  
  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('diary_draft');
      if (draftJson != null) {
        final draftData = jsonDecode(draftJson);
        final draftTime = DateTime.parse(draftData['timestamp']);
        final now = DateTime.now();
        if (now.difference(draftTime).inHours < 24) {
          _textController.text = draftData['text'] ?? '';
          if (draftData['segments'] != null) {
            _textSegments = (draftData['segments'] as List)
                .map((e) => StyledTextSegment.fromMap(e))
                .toList();
          }
          _tags = draftData['tags'] ?? '';
          _handleTextInput(_textController.text);
        }
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
  }
  
  void _insertDateTime() async {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = text.substring(0, selection.start) + 
                   formatted + 
                   text.substring(selection.end);
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: selection.start + formatted.length,
    );
    _handleTextInput(_textController.text);
  }
  
  void _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('diary_draft');
    } catch (e) {
      print('Error clearing draft: $e');
    }
  }
  
  void _saveState() {
    final currentText = _getFullText();
    final state = _EditorState(currentText, List.from(_textSegments));
    _undoStack.add(state);
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }
  
  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_EditorState(_getFullText(), List.from(_textSegments)));
    if (_redoStack.length > _maxHistorySize) {
      _redoStack.removeAt(0);
    }
    final previousState = _undoStack.removeLast();
    _restoreState(previousState);
  }
  
  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_EditorState(_getFullText(), List.from(_textSegments)));
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
    final nextState = _redoStack.removeLast();
    _restoreState(nextState);
  }
  
  void _restoreState(_EditorState state) {
    _isRestoringState = true;
    
    setState(() {
      _textController.text = state.text;
      _textSegments = List.from(state.segments);
      _recalculateSegmentPositions();
      _updateWordCount();
    });
    
    _isRestoringState = false;
  }
  
  bool _canUndo() => _undoStack.isNotEmpty;
  bool _canRedo() => _redoStack.isNotEmpty;
  
  void _showSelectionMenu() {
    final selection = _textController.selection;
    if (!selection.isValid || selection.isCollapsed) return;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.format_bold),
              title: const Text('Format as Title'),
              onTap: () {
                _formatSelectedText(TextStyleType.title);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy'),
              onTap: () {
                final text = _textController.text;
                final selected = text.substring(selection.start, selection.end);
                Clipboard.setData(ClipboardData(text: selected));
                Fluttertoast.showToast(msg: 'Copied');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_cut),
              title: const Text('Cut'),
              onTap: () {
                final text = _textController.text;
                final selected = text.substring(selection.start, selection.end);
                Clipboard.setData(ClipboardData(text: selected));
                _saveState();
                setState(() {
                  _textController.text = text.substring(0, selection.start) + 
                                        text.substring(selection.end);
                  _textController.selection = TextSelection.collapsed(offset: selection.start);
                  _handleTextInput(_textController.text);
                });
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                final text = _textController.text;
                _saveState();
                setState(() {
                  _textController.text = text.substring(0, selection.start) + 
                                        text.substring(selection.end);
                  _textController.selection = TextSelection.collapsed(offset: selection.start);
                  _handleTextInput(_textController.text);
                });
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _formatSelectedText(TextStyleType style) {
    final selection = _textController.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _switchStyle(style);
      return;
    }
    
    _saveState();
    final start = selection.start;
    final end = selection.end;
    final text = _textController.text;
    
    setState(() {
      _rebuildTextSegments(text);
      for (var segment in _textSegments) {
        if (segment.start >= start && segment.end <= end) {
          segment.style = style;
        } else if (segment.start < end && segment.end > start) {
          if (segment.start < start && segment.end > end) {
            final before = StyledTextSegment(
              text: segment.text.substring(0, start - segment.start),
              style: segment.style,
              start: segment.start,
              end: start,
            );
            final selected = StyledTextSegment(
              text: segment.text.substring(start - segment.start, end - segment.start),
              style: style,
              start: start,
              end: end,
            );
            final after = StyledTextSegment(
              text: segment.text.substring(end - segment.start),
              style: segment.style,
              start: end,
              end: segment.end,
            );
            final index = _textSegments.indexOf(segment);
            _textSegments.removeAt(index);
            _textSegments.insertAll(index, [before, selected, after]);
          }
        }
      }
      _recalculateSegmentPositions();
    });
  }

  void _handleTextInput(String text) {
    if (_textSegments.isEmpty) {
      setState(() {
        _textSegments.add(StyledTextSegment(
          text: text,
          style: _currentStyle,
          start: 0,
          end: text.length,
        ));
      });
      return;
    }

    final oldText = _getFullText();
    if (oldText == text) return;

    if (text.startsWith(oldText)) {
      final newText = text.substring(oldText.length);
      if (newText.isNotEmpty) {
        setState(() {
          final lastSegment = _textSegments.last;
          if (lastSegment.style == _currentStyle) {
            lastSegment.text += newText;
            lastSegment.end += newText.length;
          } else {
            final start = lastSegment.end;
            _textSegments.add(StyledTextSegment(
              text: newText,
              style: _currentStyle,
              start: start,
              end: start + newText.length,
            ));
          }
        });
        _saveState();
      }
    } else if (oldText.startsWith(text)) {
      final deleteCount = oldText.length - text.length;
      if (deleteCount > 0) {
        setState(() {
          int remainingDelete = deleteCount;
          while (remainingDelete > 0 && _textSegments.isNotEmpty) {
            final lastSegment = _textSegments.last;
            if (lastSegment.text.length <= remainingDelete) {
              remainingDelete -= lastSegment.text.length;
              _textSegments.removeLast();
            } else {
              lastSegment.text = lastSegment.text
                  .substring(0, lastSegment.text.length - remainingDelete);
              lastSegment.end -= remainingDelete;
              remainingDelete = 0;
            }
          }

          _recalculateSegmentPositions();
        });
        _saveState();
      }
    } else {
      _rebuildTextSegments(text);
      _saveState();
    }
  }

  void _rebuildTextSegments(String text) {
    final List<StyledTextSegment> newSegments = [];

    int currentPos = 0;
    TextStyleType? currentSegmentStyle;
    String currentSegmentText = '';

    for (int i = 0; i < text.length; i++) {
      TextStyleType? charStyle;

      for (final segment in _textSegments) {
        if (i >= segment.start && i < segment.end) {
          charStyle = segment.style;
          break;
        }
      }

      charStyle ??= _currentStyle;

      if (charStyle != currentSegmentStyle) {
        if (currentSegmentText.isNotEmpty) {
          newSegments.add(StyledTextSegment(
            text: currentSegmentText,
            style: currentSegmentStyle!,
            start: currentPos,
            end: currentPos + currentSegmentText.length,
          ));
          currentPos += currentSegmentText.length;
        }
        currentSegmentStyle = charStyle;
        currentSegmentText = text[i];
      } else {
        currentSegmentText += text[i];
      }
    }

    if (currentSegmentText.isNotEmpty && currentSegmentStyle != null) {
      newSegments.add(StyledTextSegment(
        text: currentSegmentText,
        style: currentSegmentStyle!,
        start: currentPos,
        end: currentPos + currentSegmentText.length,
      ));
    }

    setState(() {
      _textSegments = newSegments;
    });
  }

  void _recalculateSegmentPositions() {
    int currentPos = 0;
    for (final segment in _textSegments) {
      segment.start = currentPos;
      segment.end = currentPos + segment.text.length;
      currentPos = segment.end;
    }
  }

  String _getFullText() {
    if (_textSegments.isEmpty) return '';
    final buffer = StringBuffer();
    for (final segment in _textSegments) {
      buffer.write(segment.text);
    }
    return buffer.toString();
  }

  void _switchStyle(TextStyleType style) {
    setState(() {
      _currentStyle = style;
    });

    _focusNode.requestFocus();

    final text = _textController.text;
    _textController.selection = TextSelection.collapsed(
      offset: text.length,
    );
  }

  TextStyle _getTextStyle(TextStyleType type) {
    return TextStyle(
      fontSize: type.fontSize,
      fontWeight: type.fontWeight,
      color: type.color,
      height: 1.5,
    );
  }

  Widget _buildRichTextWithCursor() {
    final text = _textController.text;
    final selection = _textController.selection;
    final showCursor = _showCursor && _focusNode.hasFocus;

    if (text.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCursor)
            Text(
              '|',
              style: _getTextStyle(_currentStyle).copyWith(
                color: Colors.black,
              ),
            ),
          const Text(
            'Please input...',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    final List<InlineSpan> children = [];

    for (final segment in _textSegments) {
      children.add(TextSpan(
        text: segment.text,
        style: _getTextStyle(segment.style),
      ));
    }

    if (showCursor && selection.isCollapsed) {
      final cursorPos = selection.baseOffset;

      int currentPos = 0;
      List<InlineSpan> newChildren = [];
      bool cursorAdded = false;

      for (final child in children) {
        if (child is TextSpan) {
          final textLength = child.text?.length ?? 0;

          if (!cursorAdded &&
              cursorPos >= currentPos &&
              cursorPos <= currentPos + textLength) {
            final beforeCursor =
                child.text?.substring(0, cursorPos - currentPos) ?? '';
            final afterCursor =
                child.text?.substring(cursorPos - currentPos) ?? '';

            if (beforeCursor.isNotEmpty) {
              newChildren.add(TextSpan(
                text: beforeCursor,
                style: child.style,
              ));
            }

            newChildren.add(TextSpan(
              text: '|',
              style: child.style?.copyWith(
                    color: Colors.black,
                  ) ??
                  TextStyle(
                    color: Colors.black,
                    fontSize: _currentStyle.fontSize,
                  ),
            ));

            if (afterCursor.isNotEmpty) {
              newChildren.add(TextSpan(
                text: afterCursor,
                style: child.style,
              ));
            }

            cursorAdded = true;
          } else {
            newChildren.add(child);
          }

          currentPos += textLength;
        } else {
          newChildren.add(child);
        }
      }

      if (!cursorAdded && cursorPos >= currentPos) {
        newChildren.add(TextSpan(
          text: '|',
          style: _getTextStyle(_currentStyle).copyWith(color: Colors.black),
        ));
      }

      return RichText(text: TextSpan(children: newChildren));
    }

    return RichText(text: TextSpan(children: children));
  }

  List<String> _getTitles() {
    return _textSegments
        .where((segment) => segment.style == TextStyleType.title)
        .map((segment) => segment.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit diary'),
        actions: [
          const Text(
            'Commit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ).marginOnly(right: 20).gestures(onTap: () {
            FocusScope.of(Get.context!).requestFocus(FocusNode());
            final titles = _getTitles();
            if (titles.isEmpty) {
              Fluttertoast.showToast(msg: 'Please input title');
              return;
            }
            final title = titles.first;
            final content = _getFullText();
            _clearDraft();
            controller.addData(title, content, _textSegments, _tags);
          })
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _focusNode.requestFocus();
                            final text = _textController.text;
                            _textController.selection = TextSelection.collapsed(
                              offset: text.length,
                            );
                          },
                          onLongPress: () {
                            _showSelectionMenu();
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: _buildRichTextWithCursor(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                right: 0,
                                bottom: 0,
                                child: Opacity(
                                  opacity: 0.0,
                                  child: TextField(
                                    key: _textFieldKey,
                                    controller: _textController,
                                    focusNode: _focusNode,
                                    maxLines: null,
                                    expands: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric( horizontal: 15),
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Style',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                            Text(
                              '$_wordCount words, $_characterCount chars',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: TextStyleType.values.map((styleType) {
                          final isSelected = _currentStyle == styleType;
                          return Text(
                            styleType.displayName,
                            style: TextStyle(
                                fontWeight: styleType.fontWeight,
                                fontSize: styleType.fontSize,
                                color: styleType.color),
                          )
                              .padding(all: 4)
                              .padding(horizontal: 8)
                              .decorated(
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xffacacac),
                                  )
                                : null,
                          )
                              .gestures(onTap: () {
                            final selection = _textController.selection;
                            if (selection.isValid && !selection.isCollapsed) {
                              _formatSelectedText(styleType);
                            } else {
                              _switchStyle(styleType);
                            }
                          });
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (value) {
                        _tags = value;
                        _saveDraft();
                      },
                      controller: TextEditingController(text: _tags),
                    ),
                  ],
                ),
              ).decorated(color: Colors.white),
            ],
          ),
        ),
      ).decorated(
          image: const DecorationImage(
              image: AssetImage('assets/bg1.png'), fit: BoxFit.fill)),
    );
  }
}
