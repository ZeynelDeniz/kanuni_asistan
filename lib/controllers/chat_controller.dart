import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kanuni_asistan/constants/api_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat_message.dart';

class ChatController extends GetxController {
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  List<ChatMessage> get messages => _messages.reversed.toList();

  late Database _database;
  final RxBool isLoading = true.obs;
  final RxBool isTyping = false.obs;

  final ScrollController scrollController = ScrollController();
  final RxBool showScrollDownButton = false.obs;

  late String _conversationId;
  //TODO Add question bubbles with changing text

  List<String> get sampleQuestions => [
        AppLocalizations.of(Get.context!)!.question1,
        AppLocalizations.of(Get.context!)!.question2,
        AppLocalizations.of(Get.context!)!.question3,
        AppLocalizations.of(Get.context!)!.question4,
        AppLocalizations.of(Get.context!)!.question5,
      ];

  void animateToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    const threshold = 1000;
    if (scrollController.position.pixels <= threshold) {
      showScrollDownButton.value = false;
    } else {
      showScrollDownButton.value = true;
    }
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'chat_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, isSentByUser INTEGER)',
        );
        await db.execute(
          'CREATE TABLE conversation(id INTEGER PRIMARY KEY AUTOINCREMENT, conversationId TEXT)',
        );
      },
      version: 1,
    );
    await _loadConversationId();
    _loadMessages();
  }

  Future<void> _loadConversationId() async {
    final List<Map<String, dynamic>> maps =
        await _database.query('conversation');
    if (maps.isNotEmpty) {
      _conversationId = maps.first['conversationId'];
    } else {
      _conversationId = _generateConversationId();
      await _database.insert(
        'conversation',
        {'conversationId': _conversationId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  String _generateConversationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _loadMessages() async {
    final List<Map<String, dynamic>> maps = await _database.query('messages');
    _messages.addAll(List.generate(maps.length, (i) {
      return ChatMessage(
        id: maps[i]['id'],
        message: maps[i]['message'],
        isSentByUser: maps[i]['isSentByUser'] == 1,
      );
    }));
    isLoading(false);
    update();
  }

  String formattedMessage(String message) {
    final regex = RegExp(r'\[.*?\]');
    message = message.replaceAll(regex, '');
    message = message.replaceAll('**', '');

    final locRegex = RegExp(r'loc_(\d+)');
    message = message.replaceAllMapped(locRegex, (match) {
      final locationNumber = match.group(1);
      return '<loc_$locationNumber>';
    });

    final urlRegex = RegExp(r'\((https?://[^\s]+)\)');
    message = message.replaceAllMapped(urlRegex, (match) {
      final url = match.group(1);
      return '<url_$url>';
    });

    final angleBracketUrlRegex = RegExp(r'<(https?://[^\s]+)>');
    message = message.replaceAllMapped(angleBracketUrlRegex, (match) {
      final url = match.group(1);
      return '<url_$url>';
    });

    return message.trim();
  }

  Future<void> addMessage(String message, bool isSentByUser) async {
    final count = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM messages'));
    if (count != null && count >= 30) {
      await _database.delete(
        'messages',
        where: 'id = (SELECT id FROM messages ORDER BY id ASC LIMIT 1)',
      );
    }

    final id = await _database.insert(
      'messages',
      ChatMessage(message: message, isSentByUser: isSentByUser).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _messages
        .add(ChatMessage(id: id, message: message, isSentByUser: isSentByUser));

    isTyping.value = true;
    update();

    try {
      final messagesForApi = _messages.map((msg) {
        return {
          'content': msg.message,
          'role': msg.isSentByUser ? 'user' : 'assistant',
        };
      }).toList();

      log('Conversation ID: $_conversationId');

      final response = await http.post(
        Uri.parse(chatbaseApiUrl),
        headers: {
          'Authorization': 'Bearer $chatbaseKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': messagesForApi,
          'chatbotId': chatBotId,
          'conversationId': _conversationId,
          'stream': false,
          'temperature': 0,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        log('Failed to fetch data: ${errorData['message']}');
      }

      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      String replyMessage = data['text'];

      log('Unformatted Reply message: $replyMessage');

      replyMessage = formattedMessage(replyMessage);

      final replyId = await _database.insert(
        'messages',
        ChatMessage(
          message: replyMessage,
          isSentByUser: false,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _messages.add(
        ChatMessage(
          id: replyId,
          message: replyMessage,
          isSentByUser: false,
        ),
      );
    } catch (e) {
      log('Failed to fetch data: $e');
    }

    isTyping.value = false;
    update();
  }
}
