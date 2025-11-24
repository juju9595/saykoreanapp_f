import 'package:dio/dio.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import 'api.dart';

class ChattingApi {
  final Dio _dio = ApiClient.dio;

  Future<List<Map<String, dynamic>>> getMyRooms(int userNo) async {
    final res = await _dio.get("/chat/rooms", queryParameters: {
      "userNo" : userNo,
    });

    return (res.data as List) .map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getMessages(int roomNo) async {
    final res = await _dio.get("/chat/messages", queryParameters: {"roomNo" : roomNo});
    return (res.data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// 메시지 신고
  Future<void> reportMessage({
    required int messageNo,
    required int reporterNo,
    required String reason,
  }) async {
    await _dio.post(
      "/chat/report",
      data: {
        "messageNo": messageNo,
        "reporterNo": reporterNo,
        "reason": reason,
      },
    );
  }
}
