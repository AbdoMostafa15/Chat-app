import 'package:flutter/material.dart';
import 'package:chatapp/models/message.dart';
import 'package:chatapp/widgets/constants.dart';

class Chatbubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const Chatbubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: _buildMessageContent(context),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );

      case MessageType.image:
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (_) => Dialog(
                    child: InteractiveViewer(
                      child: Image.network(
                        message.content,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message.content,
              fit: BoxFit.cover,
              width: 200,
              height: 200,
            ),
          ),
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.fileName ?? 'Document',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );

      case MessageType.contact:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.contact_phone, color: Colors.white),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.contactName ?? 'Contact',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (message.contactPhone != null)
                  Text(
                    message.contactPhone!,
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ],
        );

      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.mic, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Voice message",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }
}
