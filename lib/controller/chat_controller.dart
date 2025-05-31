import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../apis/apis.dart';
import '../helper/my_dialog.dart';
import '../controller/note_controller.dart';
import '../model/chat/chat.dart';

class ChatController extends GetxController {
  final TextEditingController textC = TextEditingController();
  final ScrollController scrollC = ScrollController();
  final NoteController noteController = Get.find<NoteController>();
  final FlutterTts flutterTts = FlutterTts();

  var list = <Chat>[].obs;
  var chatSessions = <Map<String, dynamic>>[].obs;
  var preferredFeedbackFormat = ''.obs;
  var preferredLanguage = 'english'.obs;
  var isListening = false.obs;
  var estimatedTokens = 0.obs;

  late Box<Map> chatSessionBox;
  String? _currentSessionId;
  String? _currentSessionTitle;
  bool _isFirstMessage = true;
  final stt.SpeechToText speech = stt.SpeechToText();
  final maxTokens = 30000;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _openChatSessionBox();
    await initChat();
    _initSpeech();
  }

  @override
  void onClose() {
    saveChatSession(list.toList());
    textC.dispose();
    scrollC.dispose();
    flutterTts.stop();
    speech.stop();
    super.onClose();
  }

  Future<void> _initSpeech() async {
    bool available = await speech.initialize(
      onError: (val) => log('Speech recognition error: $val'),
      onStatus: (val) {
        if (val == stt.SpeechToText.listeningStatus) {
          isListening.value = true;
        } else {
          isListening.value = false;
        }
      },
    );
    if (!available) {
      MyDialog.info('Speech recognition not available on this device.');
    }
  }

  Future<void> startListening() async {
    if (!speech.isAvailable) {
      await _initSpeech();
    }
    if (speech.isAvailable && !speech.isListening) {
      isListening.value = true;
      await speech.listen(
        onResult: (val) {
          textC.text = val.recognizedWords;
          if (val.finalResult) {
            askQuestion();
          }
        },
        localeId: 'en_US',
      );
    }
  }

  Future<void> stopListening() async {
    if (speech.isListening) {
      await speech.stop();
      isListening.value = false;
    }
  }

  Future<void> initChat() async {
    await _openChatSessionBox();
    await loadChatSessions();
    if (chatSessions.isEmpty) {
      _startNewSession('New Chat');
      //list.add(Chat(msg: 'Hello! How can I help you today?', msgType: ChatType.bot));
      await saveChatSession(list.toList());
    } else {
      await _loadCurrentSession();
    }
  }

  Future<void> _openChatSessionBox() async {
    try {
      if (!Hive.isBoxOpen('chat_sessions')) {
        chatSessionBox = await Hive.openBox<Map>('chat_sessions');
      } else {
        chatSessionBox = Hive.box<Map>('chat_sessions');
      }
    } catch (e) {
      log('Error opening chat session box: $e');
      Get.snackbar('Error', 'Failed to initialize chat history');
    }
  }

  Future<void> loadChatSessions() async {
    try {
      if (!chatSessionBox.isOpen) {
        await _openChatSessionBox();
      }
      final sessions = chatSessionBox.values.toList();
      chatSessions.assignAll(sessions.cast<Map<String, dynamic>>());
    } catch (e) {
      log('Error loading chat sessions: $e');
      chatSessions.clear();
    }
  }

  Future<void> saveChatSession(List<Chat> session) async {
    try {
      if (_currentSessionId == null) {
        _startNewSession('New Chat');
      }

      final messagesJson = session.map((chat) => chat.toJson()).toList();
      final chatSession = {
        'id': _currentSessionId,
        'title': _currentSessionTitle ?? 'New Chat',
        'messages': messagesJson,
        'format': preferredFeedbackFormat.value,
        'language': preferredLanguage.value,
      };

      await chatSessionBox.put(_currentSessionId!, chatSession);
      
      final index = chatSessions.indexWhere((s) => s['id'] == _currentSessionId);
      if (index != -1) {
        chatSessions[index] = chatSession;
      } else {
        chatSessions.insert(0, chatSession);
      }
    } catch (e) {
      log('Error saving chat session: $e');
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
  try {
    await chatSessionBox.delete(sessionId);
    chatSessions.removeWhere((session) => session['id'] == sessionId);
    
    if (chatSessions.isEmpty) {
      _startNewSession('New Chat');
      list.clear();
      await saveChatSession(list.toList());
    } else {
      // Load the first non-empty session if available
      final nonEmptySession = chatSessions.firstWhere(
        (s) => (s['messages'] as List).isNotEmpty,
        orElse: () => chatSessions.first,
      );
      await loadChatSession(nonEmptySession['id']);
    }
  } catch (e) {
    log('Error deleting chat session: $e');
  }
}

  Future<void> loadChatSession(String sessionId) async {
  try {
    // Don't reload the same session
    if (_currentSessionId == sessionId) return;

    _currentSessionId = sessionId;
    final session = chatSessionBox.get(sessionId) as Map<String, dynamic>?;
    
    if (session != null && session['messages'] != null && (session['messages'] as List).isNotEmpty) {
      final messagesJson = session['messages'] as List<dynamic>;
      final chatMessages = messagesJson.map((json) => Chat.fromJson(json as Map<String, dynamic>)).toList();
      
      list.assignAll(chatMessages);
      _currentSessionTitle = session['title'];
      preferredFeedbackFormat.value = session['format'] ?? '';
      preferredLanguage.value = session['language'] ?? 'english';
      _isFirstMessage = false;
    } else {
      // Only create new session if this is truly a new session
      if (session == null) {
        _startNewSession('New Chat');
      }
      list.clear();
      await saveChatSession(list.toList());
    }
  } catch (e) {
    log('Error loading chat session: $e');
    Get.snackbar('Error', 'Failed to load chat session');
  }
}

  bool _isValidSession(Map<String, dynamic> session) {
  return session['id'] != null && 
         session['messages'] != null && 
         (session['messages'] as List).isNotEmpty;
}

  Future<void> _loadCurrentSession() async {
  if (chatSessions.isNotEmpty) {
    // Try to find a valid session first
    final validSession = chatSessions.firstWhere(
      _isValidSession,
      orElse: () => chatSessions.first,
    );
    
    _currentSessionId = validSession['id'];
    _currentSessionTitle = validSession['title'];
    await loadChatSession(_currentSessionId!);
  } else {
    _startNewSession('New Chat');
  }
}

  void _startNewSession(String title) {
  // Don't create new session if we already have an empty one
  if (_currentSessionId != null && 
      (list.isEmpty || list.every((chat) => chat.msg.isEmpty))) {
    return;
  }

  _currentSessionId = const Uuid().v4();
  _currentSessionTitle = title;
  _isFirstMessage = true;
  preferredFeedbackFormat.value = '';
  preferredLanguage.value = 'english';
  
  // Remove any existing empty sessions
  chatSessions.removeWhere((session) => 
      (session['messages'] as List?)?.isEmpty ?? true);
  
  chatSessions.insert(0, {
    'id': _currentSessionId,
    'title': title,
    'messages': <Map<String, dynamic>>[],
    'format': '',
    'language': 'english',
  });
  
  list.clear();
}

  void newChat() {
    _startNewSession('New Chat');
    list.clear();
    textC.clear();
    //list.add(Chat(msg: 'Hello! How can I help you today?', msgType: ChatType.bot,));
  }

  Future<void> askQuestion({String? source}) async {
    if (estimatedTokens.value > maxTokens * 0.9) {
      MyDialog.info('Approaching API limit. Please start a new chat session.');
      return;
    }

    final question = textC.text.trim();
    if (question.isEmpty && !isListening.value) {
      MyDialog.info('Ask Something or Tap the Mic!');
      return;
    }

    _detectFeedbackPreference(question);

    if (question.isNotEmpty) {
      final userChat = Chat(
        msg: question,
        msgType: ChatType.user,
        feedbackType: preferredFeedbackFormat.value,
      );
      list.add(userChat);

      if (_isFirstMessage) {
        _currentSessionTitle = question;
        _isFirstMessage = false;
      }

      list.add(Chat(msg: '...', msgType: ChatType.bot));
      _scrollDown();
      textC.clear();
    }

    try {
      String response;
      final prompt = _buildContextPrompt(question);
      estimatedTokens.value += prompt.length ~/ 4;
      
      if (source == "wikipedia") {
        response = await fetchWikipediaSummary(question);
      } else if (source == "youtube") {
        response = await fetchYouTubeResults(question);
      } else {
        response = await _getAIResponse(question, prompt);
      }

      estimatedTokens.value += response.length ~/ 4;

      if (list.isNotEmpty && list.last.msg == '...') list.removeLast();
      
      if (!_verifyResponseFormat(response, preferredFeedbackFormat.value)) {
        response = _simpleReformat(response, preferredFeedbackFormat.value);
      }

      list.add(Chat(
        msg: response,
        msgType: ChatType.bot,
        feedbackType: preferredFeedbackFormat.value,
      ));
      
      await saveChatSession(list.toList());
      _scrollDown();
    } catch (e) {
      if (list.isNotEmpty && list.last.msg == '...') list.removeLast();
      list.add(Chat(
        msg: 'Sorry, I encountered an error. Please try again.',
        msgType: ChatType.bot,
      ));
    }
  }

  void _detectFeedbackPreference(String question) {
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('points') || lowerQuestion.contains('bullets')) {
      preferredFeedbackFormat.value = 'bullet_points';
    } 
    else if (lowerQuestion.contains('paragraph') || lowerQuestion.contains('detailed')) {
      preferredFeedbackFormat.value = 'paragraph';
    }
    else if (lowerQuestion.contains('table') || lowerQuestion.contains('tabular')) {
      preferredFeedbackFormat.value = 'table';
    }
    
    if (lowerQuestion.contains('hindi') || lowerQuestion.contains('हिंदी')) {
      preferredLanguage.value = 'hindi';
    }
    else if (lowerQuestion.contains('english')) {
      preferredLanguage.value = 'english';
    }
  }

  Future<String> _getAIResponse(String question, String prompt) async {
    if (list.length <= 1) {
      return await APIs.getGeminiAnswer("""
      You are Neo, a helpful AI assistant. 
      Greet the user warmly and ask how you can help them.
      
      User preferences:
      - Format: ${preferredFeedbackFormat.value}
      - Language: ${preferredLanguage.value}
      
      User message: $question
      
      Assistant response:""");
    } else {
      return await APIs.getGeminiAnswer(prompt);
    }
  }

  bool _verifyResponseFormat(String response, String format) {
    switch (format) {
      case 'bullet_points':
        return response.contains('\n- ') || response.contains('\n• ');
      case 'numbered_list':
        return response.contains('\n1. ');
      case 'table':
        return response.contains('|') && response.contains('-');
      default:
        return true;
    }
  }

  String _simpleReformat(String response, String format) {
    switch (format) {
      case 'bullet_points':
        return response.split('\n').map((line) => line.isEmpty ? '' : '- $line').join('\n');
      case 'numbered_list':
        return response.split('\n').asMap()
          .map((i, line) => MapEntry(i, line.isEmpty ? '' : '${i + 1}. $line'))
          .values.join('\n');
      default:
        return response;
    }
  }

  String _buildContextPrompt(String newMessage) {
    if (list.isEmpty) {
      return """
      You are Neo, a helpful AI assistant. 
      Respond to the user's first message in a friendly and helpful manner.
      
      User's first message: $newMessage
      
      Assistant response:""";
    }

    final messages = list.toList();
    final startIndex = messages.length > 3 ? messages.length - 3 : 0;
    final recentMessages = messages.sublist(startIndex).map((chat) {
      return '${chat.msgType == ChatType.user ? "User" : "Assistant"}: ${chat.msg}';
    }).join('\n');

    return """
    Conversation context:
    $recentMessages
    
    Current user message: $newMessage
    
    Assistant response:""";
  }

  Future<String> fetchYouTubeResults(String query) async {
    try {
      var yt = YoutubeExplode();
      var searchList = await yt.search.search(query);

      if (searchList.isNotEmpty) {
        String result = "YouTube Results:\n";
        for (var video in searchList.take(3)) {
          //result += "🎥 [${video.title}](https://www.youtube.com/watch?v=${video.id.value})\n";
          result += "🎥 [![${video.title}](https://img.youtube.com/vi/${video.id.value}/0.jpg)](https://www.youtube.com/watch?v=${video.id.value})\n\n";

        }
        yt.close();
        return result;
      } else {
        yt.close();
        return 'No YouTube results found.';
      }
    } catch (e) {
      log('YouTube Explode Error: $e');
      return 'Failed to fetch YouTube results.';
    }
  }

  void saveChatResponseAsNote(String title, String content) {
    noteController.addNote(title, content, 'Chat Notes', false, []);
    Get.snackbar('Success', 'Chat response saved to Notes');
  }

  Future<String> fetchWikipediaSummary(String query) async {
    try {
      final url = 'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(query)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return "${data['title'] ?? 'No Title'}\n${data['extract'] ?? 'No summary available.'}\n"
               "[Read More](${data['content_urls']?['desktop']?['page'] ?? '#'})";
      }
      return "Wikipedia API error: ${response.statusCode}";
    } catch (e) {
      log('Wikipedia API Error: $e');
      return 'Failed to fetch Wikipedia results.';
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollC.hasClients) {
        scrollC.animateTo(
          scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }
}