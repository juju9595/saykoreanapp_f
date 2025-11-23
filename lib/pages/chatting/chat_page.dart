import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:saykoreanapp_f/api/api.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../api/chatting_api.dart';  // 🔥 신고 API 사용

class ChatPage extends StatefulWidget {
  final int roomNo;
  final String friendName;
  final int myUserNo;
  final VoidCallback? onMessageSent;

  const ChatPage({
    super.key,
    required this.roomNo,
    required this.friendName,
    required this.myUserNo,
    this.onMessageSent,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel _channel;
  final ScrollController _scroll = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  final api = ChattingApi();   // 🔥 신고 API 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    final wsUrl =
        "${ApiClient.detectWsUrl()}?roomNo=${widget.roomNo}&userNo=${widget.myUserNo}";
    print("WebSocket connect: $wsUrl");

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen(
          (data) {
        final decoded = jsonDecode(data);
        final type = decoded["type"] ?? "";

        // HISTORY
        if (type == "HISTORY") {
          final list = decoded["messages"] ?? [];

          setState(() {
            _messages
              ..clear()
              ..addAll(
                list.map((m) => {
                  "messageNo": m["messageNo"],
                  "sendNo": m["sendNo"],
                  "message": m["chatMessage"],
                  "time": m["chatTime"] ?? "",
                }),
              );
          });

          _scrollToBottom();
          return;
        }

        // 실시간 메시지
        if (type == "chat") {
          setState(() {
            _messages.add({
              "messageNo": decoded["messageNo"],
              "sendNo": decoded["sendNo"],
              "message": decoded["message"] ?? "",
              "time": decoded["time"] ?? "",
            });
          });

          widget.onMessageSent?.call();
          _scrollToBottom();
        }
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 150), () {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final payload = {"message": text};
    _channel.sink.add(jsonEncode(payload));

    _controller.clear();
  }

  // 🔥🔥 메시지 신고 UI + 서버 전송 (추가된 함수)
  Future<void> _reportMessage(Map<String, dynamic> message) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("메시지 신고"),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(hintText: "신고 사유를 입력해주세요."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, reasonController.text.trim()),
            child: Text("신고"),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      await api.reportMessage(
        messageNo: message['messageNo'],
        reporterNo: widget.myUserNo,
        reason: reason,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("신고가 접수되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("신고 중 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = m['sendNo'] == widget.myUserNo;

                return GestureDetector(
                  onLongPress: () => _reportMessage(m),   // 🔥 길게 눌러 신고
                  child: Align(
                    alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.pink[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m['message'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),

          // 입력창
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "메시지 입력",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
