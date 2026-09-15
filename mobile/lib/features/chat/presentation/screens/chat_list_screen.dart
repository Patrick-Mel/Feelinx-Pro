import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/fx_avatar.dart';
import '../../../../core/widgets/fx_shimmer_box.dart';
import '../../../../core/widgets/fx_empty_state.dart';
import '../../../../core/network/dio_client.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final res = await dio.get('chat/conversations/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _conversations = res.data ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: FxShimmerBox(width: double.infinity, height: 72, borderRadius: 16),
                ),
              )
            : _conversations.isEmpty
                ? const FxEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: "Aucun message",
                    description: "Lorsque tu auras des matchs, tes conversations s'afficheront ici.",
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const Divider(color: FxColors.darkBorder, height: 1),
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final other = conv['other_profile'];
                      final lastMsg = conv['last_message'];
                      final unreadCount = conv['unread_count'] ?? 0;
                      final photos = other['photos'] as List? ?? [];
                      final photoUrl = photos.isNotEmpty ? photos.first['url'] : '';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: FxAvatar(
                          imageUrl: photoUrl,
                          radius: 26,
                          isVerified: other['is_verified'] == true,
                          isOnline: true,
                        ),
                        title: Text(other['first_name'] ?? 'Membre', style: FxTypography.titleMedium),
                        subtitle: Text(
                          lastMsg != null ? lastMsg['content'] : 'Nouveau match ! Dis-lui bonjour 👋',
                          style: FxTypography.bodyMedium.copyWith(
                            color: unreadCount > 0 ? FxColors.darkTextPrimary : FxColors.darkTextSecondary,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("12:30", style: TextStyle(fontSize: 11, color: FxColors.darkTextSecondary)),
                            if (unreadCount > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(color: FxColors.primaryCoral, shape: BoxShape.circle),
                                child: Text("$unreadCount", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        onTap: () => context.push('/chat/${conv['id']}'),
                      );
                    },
                  ),
      ),
    );
  }
}
