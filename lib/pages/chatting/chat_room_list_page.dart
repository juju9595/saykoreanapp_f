import 'package:flutter/material.dart';
import '../../api/chatting_api.dart';
import 'chat_page.dart';

class ChatRoomListPage extends StatefulWidget {
  final int myUserNo;
  const ChatRoomListPage({super.key, required this.myUserNo});

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  final api = ChattingApi();
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  // 탭을 다시 열 때 자동 갱신
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadRooms();
  }

  Future<void> loadRooms() async {
    try {
      final list = await api.getMyRooms(widget.myUserNo);
      if (mounted) {
        setState(() => rooms = list);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadRooms,
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (_, i) {
          final r = rooms[i];

          return ListTile(
            title: Text(r['friendName']),
            subtitle: Text(r['lastMessage'] ?? '대화 없음'),
            trailing: Text(r['lastTime'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    roomNo: r['roomNo'],            // ★ 서버에서 보내는 대표 roomNo
                    friendName: r['friendName'],
                    myUserNo: widget.myUserNo,
                    onMessageSent: loadRooms,       // ★ 메시지 보내면 리스트 갱신
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
