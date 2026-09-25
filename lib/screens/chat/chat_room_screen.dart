import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../models/misc_models.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String productTitle;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.productTitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _messageController = TextEditingController();
  final _picker = ImagePicker();
  final _scrollController = ScrollController();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _sendText() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await _firestoreService.sendMessage(
        chatId: widget.chatId, senderId: _uid, text: text);
  }

  Future<void> _sendImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final url =
        await _storageService.uploadChatImage(File(picked.path), widget.chatId);
    await _firestoreService.sendMessage(
        chatId: widget.chatId, senderId: _uid, text: '', imageUrl: url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName, style: AppTextStyles.bodyBold),
            Text(widget.productTitle, style: AppTextStyles.caption),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _firestoreService.streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = m.senderId == _uid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(m.imageUrl!,
                                    width: 180, fit: BoxFit.cover),
                              )
                            else
                              Text(m.text,
                                  style: AppTextStyles.body.copyWith(
                                      color:
                                          isMe ? AppColors.white : AppColors.text)),
                            const SizedBox(height: 2),
                            Text(DateFormat('HH:mm').format(m.createdAt),
                                style: AppTextStyles.caption.copyWith(
                                    color: isMe
                                        ? AppColors.white.withOpacity(0.8)
                                        : AppColors.secondary,
                                    fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.image_outlined),
                      onPressed: _sendImage),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _sendText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
