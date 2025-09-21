import 'dart:io';
import 'package:chatapp/models/message.dart';
import 'package:chatapp/widgets/chatbubble.dart';
import 'package:chatapp/widgets/constants.dart';
import 'package:chatapp/widgets/customchattextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});
  static String id = "chatpage";

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final _messagesRef = FirebaseFirestore.instance.collection('messages');
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final _picker = ImagePicker();
  final _recorder = AudioRecorder();

  bool _isRecording = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _autoScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _messagesRef.add(
      Message(
        id: '',
        senderId: _uid,
        content: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
      ).toJson(),
    );
    _autoScrollToBottom();
  }

  Future<String> _uploadToStorage({
    required File file,
    required String path, // e.g. images/xxx.jpg
    String? contentType,
  }) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final meta = SettableMetadata(contentType: contentType);
    await ref.putFile(file, meta);
    return await ref.getDownloadURL();
  }

  Future<void> _sendImageFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    final file = File(x.path);
    final ext = x.name.split('.').last;
    final url = await _uploadToStorage(
      file: file,
      path: 'chat/images/${DateTime.now().millisecondsSinceEpoch}.$ext',
      contentType: 'image/$ext',
    );
    await _messagesRef.add(
      Message(
        id: '',
        senderId: _uid,
        content: url,
        type: MessageType.image,
        timestamp: DateTime.now(),
      ).toJson(),
    );
    _autoScrollToBottom();
  }

  Future<void> _openCameraAndSend() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (x == null) return;
    final file = File(x.path);
    final ext = x.name.split('.').last;
    final url = await _uploadToStorage(
      file: file,
      path: 'chat/images/${DateTime.now().millisecondsSinceEpoch}.$ext',
      contentType: 'image/$ext',
    );
    await _messagesRef.add(
      Message(
        id: '',
        senderId: _uid,
        content: url,
        type: MessageType.image,
        timestamp: DateTime.now(),
      ).toJson(),
    );
    _autoScrollToBottom();
  }

  Future<void> _pickDocumentAndSend() async {
    final res = await FilePicker.platform.pickFiles(withReadStream: false);
    if (res == null || res.files.isEmpty) return;

    final f = res.files.first;
    final file = File(f.path!);
    final ext = (f.extension ?? 'bin').toLowerCase();
    final url = await _uploadToStorage(
      file: file,
      path: 'chat/files/${DateTime.now().millisecondsSinceEpoch}-${f.name}',
      contentType: _guessMime(ext),
    );

    await _messagesRef.add(
      Message(
        id: '',
        senderId: _uid,
        content: url,
        type: MessageType.file,
        fileName: f.name,
        fileSize: f.size,
        timestamp: DateTime.now(),
      ).toJson(),
    );
    _autoScrollToBottom();
  }

  Future<void> _enterContactAndSend() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Send Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Send'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    await _messagesRef.add(
      Message(
        id: '',
        senderId: _uid,
        content: '${nameController.text} | ${phoneController.text}',
        type: MessageType.contact,
        contactName: nameController.text.trim(),
        contactPhone: phoneController.text.trim(),
        timestamp: DateTime.now(),
      ).toJson(),
    );
    _autoScrollToBottom();
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path == null) return;
      final file = File(path);
      final url = await _uploadToStorage(
        file: file,
        path: 'chat/voice/${DateTime.now().millisecondsSinceEpoch}.m4a',
        contentType: 'audio/mp4',
      );
      // naive duration: you can parse metadata if needed later
      await _messagesRef.add(
        Message(
          id: '',
          senderId: _uid,
          content: url,
          type: MessageType.voice,
          audioDuration: const Duration(seconds: 0),
          timestamp: DateTime.now(),
        ).toJson(),
      );
      _autoScrollToBottom();
    } else {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '',
      );
      setState(() => _isRecording = true);
    }
  }

  String _guessMime(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _showAttachmentSheet() async {
    await showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Photo from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _sendImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: const Text('Document'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDocumentAndSend();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_page),
                  title: const Text('Contact'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _enterContactAndSend();
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesRef.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: _appBar(),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: _appBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final messages =
            snapshot.data!.docs.map((d) => Message.fromSnapshot(d)).toList();

        return Scaffold(
          appBar: _appBar(),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scroll,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _uid;
                    return Chatbubble(message: msg, isMe: isMe);
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomChatTextField(
                    controller: _controller,
                    onSendText: _sendText,
                    onPickAttachment: _showAttachmentSheet,
                    onOpenCamera: _openCameraAndSend,
                    onToggleVoice: _toggleVoiceRecording,
                    isRecording: _isRecording,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: kPrimaryColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Image(image: AssetImage("assets/images/scholar.png"), height: 60),
          Text(
            "Chat",
            style: TextStyle(fontFamily: "Pacifico", color: Colors.white),
          ),
        ],
      ),
      actions: const [
        // If you later add in-app audio playback, you can put a player here.
      ],
    );
  }
}
