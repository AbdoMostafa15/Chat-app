import 'package:flutter/material.dart';

class CustomChatTextField extends StatelessWidget {
  const CustomChatTextField({
    super.key,
    required this.controller,
    required this.onSendText,
    required this.onPickAttachment,
    required this.onOpenCamera,
    required this.onToggleVoice, // press/hold to record, tap to stop
    required this.isRecording,
  });

  final TextEditingController controller;
  final VoidCallback onSendText;
  final VoidCallback onPickAttachment;
  final VoidCallback onOpenCamera;
  final VoidCallback onToggleVoice;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSendText(),
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Message",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          // Keep UI compact: pack actions into suffix area
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Attachments',
                icon: const Icon(Icons.attach_file),
                onPressed: onPickAttachment,
              ),
              IconButton(
                tooltip: 'Camera',
                icon: const Icon(Icons.photo_camera),
                onPressed: onOpenCamera,
              ),
              IconButton(
                tooltip: isRecording ? 'Stop' : 'Voice',
                icon: Icon(isRecording ? Icons.stop : Icons.mic),
                onPressed: onToggleVoice,
              ),
              IconButton(
                tooltip: 'Send',
                icon: const Icon(Icons.send),
                onPressed: onSendText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
