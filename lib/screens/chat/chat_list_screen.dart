import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/misc_models.dart';
import 'chat_room_screen.dart';

/// รายการห้องแชททั้งหมด (ประวัติการสนทนา) ของผู้ใช้ปัจจุบัน
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('แชท')),
      body: StreamBuilder<List<ChatModel>>(
        stream: firestoreService.streamChatsForUser(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return const Center(child: Text('ยังไม่มีบทสนทนา'));
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final unread = chat.unreadCount[uid] ?? 0;
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.background,
                  backgroundImage: chat.productImage.isNotEmpty
                      ? CachedNetworkImageProvider(chat.productImage)
                      : null,
                  child: chat.productImage.isEmpty
                      ? const Icon(Icons.shopping_bag_outlined)
                      : null,
                ),
                title: Text(chat.productTitle,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    chat.lastMessage.isEmpty ? 'เริ่มการสนทนา' : chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat('HH:mm').format(chat.lastMessageAt),
                        style: AppTextStyles.caption),
                    if (unread > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$unread',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.white)),
                      ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    chatId: chat.id,
                    otherUserName: chat.productTitle,
                    productTitle: chat.productTitle,
                  ),
                )),
              );
            },
          );
        },
      ),
    );
  }
}
