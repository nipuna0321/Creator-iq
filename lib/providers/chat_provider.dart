import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analytics_summary.dart';
import '../models/chat_message.dart';
import 'analytics_provider.dart';
import 'core_providers.dart';
import 'posts_provider.dart';
import 'questionnaire_provider.dart';

/// Conversation with the AI assistant.
class ChatState {
  const ChatState({this.messages = const [], this.typing = false});

  final List<ChatMessage> messages;

  /// True while waiting for the AI reply (shows the typing indicator).
  final bool typing;
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState(messages: [
        ChatMessage(
          id: 'welcome',
          text: 'Hi! I\'m your CreateIQ assistant 👋\nAsk me anything about your content performance.',
          isUser: false,
          time: DateTime.now(),
        ),
      ]);

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.typing) return;

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      time: DateTime.now(),
    );
    state = ChatState(messages: [...state.messages, userMsg], typing: true);

    String reply;
    try {
      final posts = await ref.read(postsProvider.future);
      final summary = ref.read(overviewProvider).value;
      reply = summary == null
          ? 'I\'m still loading your analytics — try again in a moment.'
          : await ref.read(apiServiceProvider).askAI(
                trimmed,
                summary: summary,
                answers: ref.read(questionnaireProvider),
                lastPost: posts.isEmpty ? null : posts.first,
              );
    } catch (_) {
      reply = 'Sorry, something went wrong. Please try again.';
    }

    if (!ref.mounted) return;
    state = ChatState(
      messages: [
        ...state.messages,
        ChatMessage(
          id: '${DateTime.now().microsecondsSinceEpoch}_ai',
          text: reply,
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    );
  }

  void clear() => state = build();
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

/// AI-generated performance report for the Insights screen.
final insightsProvider = FutureProvider<InsightReport>((ref) async {
  await ref.watch(postsProvider.future);
  final summary = ref.watch(overviewProvider).requireValue;
  return ref.read(apiServiceProvider).generateInsights(summary, answers: ref.watch(questionnaireProvider));
});
