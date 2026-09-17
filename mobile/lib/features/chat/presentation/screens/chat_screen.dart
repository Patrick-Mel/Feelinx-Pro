import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_avatar.dart';
import '../../../../core/network/dio_client.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  List<dynamic> _messages = [];
  dynamic _otherProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final dio = DioClient().dio;
      final resConv = await dio.get('chat/conversations/${widget.conversationId}/');
      if (resConv.statusCode == 200) {
        _otherProfile = resConv.data['other_profile'];
      }

      final resMsg = await dio.get('chat/conversations/${widget.conversationId}/messages/');
      if (resMsg.statusCode == 200 && mounted) {
        setState(() {
          _messages = resMsg.data['results'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    final tempMsg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': text,
      'sender_id': 'me',
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.insert(0, tempMsg);
    });

    try {
      final dio = DioClient().dio;
      await dio.post('chat/conversations/${widget.conversationId}/messages/', data: {
        'content': text,
        'message_type': 'text',
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            FxAvatar(
              imageUrl: _otherProfile != null && (_otherProfile['photos'] as List).isNotEmpty
                  ? _otherProfile['photos'][0]['url']
                  : null,
              radius: 18,
              isVerified: _otherProfile?['is_verified'] == true,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_otherProfile?['full_name'] ?? _otherProfile?['first_name'] ?? 'Discussion', style: FxTypography.titleMedium),
                const Text("En ligne", style: TextStyle(fontSize: 11, color: FxColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(leading: const Icon(Icons.person), title: const Text("Voir le profil"), onTap: () => context.push('/profile/public/${_otherProfile['id']}')),
                      ListTile(leading: const Icon(Icons.report, color: FxColors.error), title: const Text("Signaler le profil"), onTap: () => Navigator.pop(context)),
                      ListTile(leading: const Icon(Icons.block, color: FxColors.error), title: const Text("Bloquer l'utilisateur"), onTap: () => Navigator.pop(context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safety Warning Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: FxColors.secondaryIndigo.withOpacity(0.15),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: FxColors.primaryCoral, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "🛡️ Conseil Sécurité : Ne partage jamais d'argent ni d'informations bancaires.",
                      style: FxTypography.labelSmall.copyWith(color: FxColors.darkTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
            // Message list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMe = msg['sender_id'] == 'me' || msg['sender_id'] != _otherProfile?['id'];

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? FxColors.primaryCoral : FxColors.darkCard,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['content'] ?? '',
                                  style: FxTypography.bodyMedium.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("12:34", style: TextStyle(fontSize: 10, color: Colors.white70)),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.done_all, size: 14, color: Colors.white70),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: FxColors.darkSurface,
                border: Border(top: BorderSide(color: FxColors.darkBorder)),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.photo, color: FxColors.darkTextSecondary), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: FxTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: "Écris un message…",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: FxColors.primaryCoral),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
