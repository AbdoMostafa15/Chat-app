import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum MessageType { text, image, file, contact, voice }

class Message {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  // optional fields depending on type
  final String? fileName;
  final int? fileSize;
  final String? contactName;
  final String? contactPhone;
  final Duration? audioDuration;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.fileName,
    this.fileSize,
    this.contactName,
    this.contactPhone,
    this.audioDuration,
  });

  factory Message.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      type: _typeFromString(data['type']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      contactName: data['contactName'],
      contactPhone: data['contactPhone'],
      audioDuration:
          data['audioDuration'] != null
              ? Duration(seconds: data['audioDuration'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'type': describeEnum(type),
      'timestamp': timestamp,
      'fileName': fileName,
      'fileSize': fileSize,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'audioDuration': audioDuration?.inSeconds,
    };
  }

  static MessageType _typeFromString(String? t) {
    switch (t) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'contact':
        return MessageType.contact;
      case 'voice':
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }
}
