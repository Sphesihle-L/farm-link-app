import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/chat_message.dart';
import '../../models/app_user.dart';

class ChatScreen extends StatefulWidget {
  final AppUser currentUser;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final chatId = widget.currentUser.id.compareTo(widget.otherUserId) < 0
        ? '${widget.currentUser.id}_${widget.otherUserId}'
        : '${widget.otherUserId}_${widget.currentUser.id}';

    final message = ChatMessage(
      id: '',
      chatId: chatId,
      senderId: widget.currentUser.id,
      receiverId: widget.otherUserId,
      message: text,
      timestamp: DateTime.now(),
    );

    await Provider.of<DataService>(context, listen: false).sendMessage(message);

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.text),
        titleTextStyle: const TextStyle(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: Provider.of<DataService>(
                context,
                listen: false,
              ).getChatStream(widget.currentUser.id, widget.otherUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start the conversation!',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUser.id;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : const Radius.circular(16),
                          ),
                          border: isMe
                              ? null
                              : Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          msg.message,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.text,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
