import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/typing_indicator.dart';

/// Chat with the AI assistant about performance.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();

  static const _suggestions = [
    'Why did my last post perform poorly?',
    'When should I post?',
    'How can I get more comments?',
    'How do I grow my followers?',
    'Which hashtags should I use?',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final value = text ?? _input.text;
    if (value.trim().isEmpty) return;
    ref.read(chatProvider.notifier).send(value);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    // The list is reversed so the newest message sits at the bottom and
    // stays in view automatically.
    final messages = chat.messages.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CreateIQ Assistant', style: context.text.titleMedium),
                Text(
                  chat.typing ? 'typing…' : 'Online',
                  style: context.text.bodySmall?.copyWith(color: chat.typing ? AppColors.violet : AppColors.success),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => ref.read(chatProvider.notifier).clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(AppConstants.gap),
                itemCount: messages.length + (chat.typing ? 1 : 0),
                itemBuilder: (context, i) {
                  if (chat.typing && i == 0) return const _TypingBubble();
                  final m = messages[chat.typing ? i - 1 : i];
                  return _Bubble(message: m, key: ValueKey(m.id));
                },
              ),
            ),
          ),
          // Suggested questions.
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.gap),
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ActionChip(
                avatar: const Icon(LucideIcons.sparkles, size: 14, color: AppColors.violet),
                label: Text(_suggestions[i], style: const TextStyle(fontSize: 13)),
                onPressed: chat.typing ? null : () => _send(_suggestions[i]),
              ),
            ),
          ),
          // Input bar.
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.gap, 8, AppConstants.gap, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask about your performance…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppColors.violet),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      child: InkWell(
                        onTap: chat.typing ? null : _send,
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(LucideIcons.send, color: Colors.white, size: 20),
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
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.8;
    const r = Radius.circular(20);
    final textColor = isUser ? context.colors.onSurface : Colors.white;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser ? null : AppColors.primaryGradient,
          color: isUser ? context.colors.surface : null,
          boxShadow: context.softShadow,
          borderRadius: BorderRadius.only(
            topLeft: r,
            topRight: r,
            bottomLeft: isUser ? r : const Radius.circular(6),
            bottomRight: isUser ? const Radius.circular(6) : r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText.rich(
              _formatted(message.text, TextStyle(color: textColor, height: 1.45, fontSize: 14.5)),
            ),
            const SizedBox(height: 4),
            Text(
              Fmt.time(message.time),
              style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }

  /// Minimal markdown: **bold** and *italic* segments.
  TextSpan _formatted(String text, TextStyle base) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    var last = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w800)));
      } else {
        spans.add(TextSpan(text: m.group(2), style: const TextStyle(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return TextSpan(style: base, children: spans);
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: const TypingIndicator(),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
