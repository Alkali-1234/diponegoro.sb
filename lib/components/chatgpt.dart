import 'dart:async';
import 'dart:developer';

import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuestionAnswer {
  final String question;
  final StringBuffer answer;

  QuestionAnswer({
    required this.question,
    required this.answer,
  });

  QuestionAnswer copyWith({String? newQuestion, StringBuffer? newAnswer, Role? newRole}) {
    return QuestionAnswer(
      question: newQuestion ?? question,
      answer: newAnswer ?? answer,
    );
  }
}

class ChatCompletionPage extends StatefulWidget {
  final ChatGpt chatGpt;

  const ChatCompletionPage({super.key, required this.chatGpt});

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage> {
  String? answer;
  bool loading = false;
  final testPrompt = 'Which Disney character famously leaves a glass slipper behind at a royal ball?';

  final List<QuestionAnswer> questionAnswers = [];

  late TextEditingController textEditingController;

  StreamSubscription<CompletionResponse>? streamSubscription;
  StreamSubscription<StreamCompletionResponse>? chatStreamSubscription;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    chatStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close)),
              Text("literally chatgpt", style: textTheme.displayMedium!.copyWith(color: theme.onBackground)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: questionAnswers.length,
              itemBuilder: (context, index) {
                final questionAnswer = questionAnswers[index];
                final answer = questionAnswer.answer.toString().trim();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Q: ${questionAnswer.question}', style: textTheme.displaySmall),
                    const SizedBox(height: 12),
                    if (answer.isEmpty && loading) const Center(child: CircularProgressIndicator()) else Text('A: $answer', style: textTheme.displaySmall!.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: textTheme.displaySmall,
                  controller: textEditingController,
                  cursorColor: theme.onBackground,
                  decoration: InputDecoration(
                      hintStyle: textTheme.displaySmall!.copyWith(color: theme.onBackground.withOpacity(0.5)),
                      hintText: 'Type in...',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      fillColor: theme.primary,
                      filled: true),
                  onFieldSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 12),
              ClipOval(
                child: Material(
                  color: Colors.blue, // Button color
                  child: InkWell(
                    onTap: _sendChatMessage,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _sendChatMessage() async {
    final question = textEditingController.text;
    setState(() {
      textEditingController.clear();
      loading = true;
      questionAnswers.add(
        QuestionAnswer(
          question: question,
          answer: StringBuffer(),
        ),
      );
    });
    final testRequest = ChatCompletionRequest(
      stream: true,
      maxTokens: 4000,
      messages: [
        for (final questionAnswer in questionAnswers) ...[
          Message(role: Role.user.name, content: questionAnswer.question),
          Message(role: Role.system.name, content: questionAnswer.answer.toString())
        ],
        Message(role: Role.user.name, content: question)
      ],
      model: ChatGptModel.gpt35Turbo.modelName,
    );
    await _chatStreamResponse(testRequest);

    setState(() => loading = false);
  }

  _chatStreamResponse(ChatCompletionRequest request) async {
    chatStreamSubscription?.cancel();
    try {
      final stream = await widget.chatGpt.createChatCompletionStream(request);
      chatStreamSubscription = stream?.listen(
        (event) => setState(
          () {
            if (event.streamMessageEnd) {
              chatStreamSubscription?.cancel();
            } else {
              return questionAnswers.last.answer.write(
                event.choices?.first.delta?.content,
              );
            }
          },
        ),
      );
    } catch (error) {
      setState(() {
        loading = false;
        questionAnswers.last.answer.write("Error");
      });
      log("Error occurred: $error");
    }
  }
}
