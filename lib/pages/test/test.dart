import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saykoreanapp_f/api.dart'; // ★ 전역 ApiClient 사용

class TestPage extends StatefulWidget {
  final int testNo;
  const TestPage({super.key, required this.testNo});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool loading = false;
  String msg = "";
  List<dynamic> items = [];
  int idx = 0;
  bool submitting = false;
  Map<String, dynamic>? feedback;
  int? testRound;
  int langNo = 1; // 기본값
  String subjective = "";

  @override
  void initState() {
    super.initState();
    _loadLangAndTest();
  }

  // 언어 로드 후 문항 로드
  Future<void> _loadLangAndTest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      langNo = prefs.getInt('selectedLangNo') ?? 1;
      print("TestPage init, testNo=${widget.testNo}, langNo=$langNo");
    } catch (e) {
      print("_loadLangAndTest prefs error: $e");
      langNo = 1;
    }
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      loading = true;
      msg = "";
    });

    try {
      // 1) 회차 조회
      final roundRes = await ApiClient.dio.get(
        '/saykorean/test/getnextround',
        queryParameters: {
          "testNo": widget.testNo,
        },
      );
      print("▶ getnextround status = ${roundRes.statusCode}");
      print("▶ getnextround data   = ${roundRes.data}");

      if (roundRes.data is int) {
        testRound = roundRes.data as int;
      } else if (roundRes.data is Map &&
          (roundRes.data['testRound'] != null)) {
        testRound = roundRes.data['testRound'] as int;
      } else {
        testRound = 1;
      }

      // 2) 문항 데이터 로드
      final res = await ApiClient.dio.get(
        '/saykorean/test/findtestitem',
        queryParameters: {
          "testNo": widget.testNo,
          "langNo": langNo,
        },
      );
      print("▶ findtestitem status = ${res.statusCode}");
      print("▶ findtestitem data   = ${res.data}");

      List<dynamic> list;
      if (res.data is List) {
        list = res.data as List;
      } else if (res.data is Map) {
        final map = res.data as Map;
        if (map['list'] is List) {
          list = map['list'] as List;
        } else if (map['items'] is List) {
          list = map['items'] as List;
        } else {
          list = [];
        }
      } else {
        list = [];
      }

      setState(() {
        items = list;
        idx = 0;
        msg = items.isEmpty ? "문항이 없습니다." : "";
      });
    } catch (e, st) {
      print("_loadQuestions error: $e");
      print(st);
      setState(() {
        msg = "문항을 불러올 수 없습니다.";
        items = [];
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> submitAnswer({int? selectedExamNo}) async {
    if (testRound == null || items.isEmpty) return;
    final cur = items[idx];
    final isSubjective = idx % 3 == 2;

    final body = {
      "testRound": testRound,
      "selectedExamNo": selectedExamNo ?? 0,
      "userAnswer": selectedExamNo != null ? "" : subjective,
      "langNo": langNo,
    };

    final url =
        "/saykorean/test/${widget.testNo}/items/${cur['testItemNo']}/answer";

    if (isSubjective && selectedExamNo == null) {
      print("로딩 페이지로 이동 (주관식)");
      return;
    }

    try {
      setState(() => submitting = true);
      final res = await ApiClient.dio.post(url, data: body);
      print("▶ submitAnswer status = ${res.statusCode}");
      print("▶ submitAnswer data   = ${res.data}");

      final data = res.data;

      // 여러 가지 응답 형태를 다 커버
      dynamic rawCorrect = 0;
      if (data is Map) {
        rawCorrect =
            data["isCorrect"] ?? data["correct"] ?? data["result"] ?? 0;
      }

      bool isCorrect;
      if (rawCorrect is bool) {
        isCorrect = rawCorrect;
      } else if (rawCorrect is num) {
        isCorrect = rawCorrect == 1;
      } else if (rawCorrect is String) {
        isCorrect = (rawCorrect == "1" || rawCorrect.toLowerCase() == "true");
      } else {
        isCorrect = false;
      }

      final score = (data is Map && data["score"] is num)
          ? (data["score"] as num).toInt()
          : 0;

      setState(() {
        feedback = {
          "correct": isCorrect,
          "score": score,
        };
      });
    } catch (e, st) {
      print("submitAnswer error: $e");
      print(st);
      setState(() {
        msg = "답안 제출 실패";
        feedback = {
          "correct": false,
          "score": 0,
        };
      });
    } finally {
      setState(() => submitting = false);
    }
  }

  void goNext() {
    if (idx < items.length - 1) {
      setState(() {
        idx++;
        subjective = "";
        feedback = null;
      });
    } else {
      Navigator.pushNamed(context, "/testresult/${widget.testNo}");
    }
  }

  // ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFF9F0);
    const brown = Color(0xFF6B4E42);
    final screenWidth = MediaQuery.of(context).size.width;

    final cur = (items.isNotEmpty) ? items[idx] : null;
    final questionType = idx % 3; // 0=그림,1=음성,2=주관식
    final isImageQuestion = questionType == 0;
    final isAudioQuestion = questionType == 1;
    final isSubjective = questionType == 2;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: brown),
        title: const Text(
          '시험 보기',
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
        child: Text(
          msg.isEmpty ? "문항이 없습니다." : msg,
          style: const TextStyle(color: Colors.grey),
        ),
      )
          : SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 타이틀 영역
              const Text(
                "오늘의 시험",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: brown,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "문제를 풀고 자신의 실력을 확인해 보아요.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9C7C68),
                ),
              ),
              const SizedBox(height: 18),

              // 진행도
              Text(
                "${idx + 1} / ${items.length}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C5A48),
                ),
              ),
              const SizedBox(height: 8),

              // 문제 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    // 문제 텍스트
                    Text(
                      cur?['questionSelected'] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3F3F46),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // 이미지 문항
                    if (isImageQuestion &&
                        cur?['imagePath'] != null)
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(12),
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          child: AspectRatio(
                            aspectRatio: 3 / 3,
                            child: Image.network(
                              ApiClient.buildUrl(
                                cur!['imagePath'] as String,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Center(
                                child:
                                Text('이미지를 불러올 수 없어요'),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // 오디오 문항
                    if (isAudioQuestion &&
                        cur?['audios'] != null)
                      Column(
                        children: [
                          for (final audio
                          in (cur!['audios'] as List))
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 6.0),
                              child: OutlinedButton(
                                onPressed: () {
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                  const Color(0xFF6B4E42),
                                  side: const BorderSide(
                                    color:
                                    Color(0xFFE5D5CC),
                                  ),
                                ),
                                child: Text(
                                    "🔊 ${audio['audioPath']}"),
                              ),
                            )
                        ],
                      ),

                    // 주관식 예문
                    if (isSubjective &&
                        cur?['examSelected'] != null)
                      Container(
                        margin:
                        const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Text(
                          cur!['examSelected'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 선택지 / 입력 영역
              if (!isSubjective)
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "정답을 골라보세요",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C5A48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if ((cur?['options'] as List?)?.isNotEmpty ??
                        false)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (cur!['options'] as List)
                            .map<Widget>((opt) {
                          final label =
                              opt['examSelected'] ??
                                  opt['examKo'] ??
                                  "보기 로드 실패";
                          return _ChoiceButton(
                            label: label.toString(),
                            onTap: feedback == null
                                ? () => submitAnswer(
                                selectedExamNo:
                                opt['examNo'])
                                : null,
                          );
                        }).toList(),
                      )
                    else
                      const Text("보기 불러오기 실패"),
                  ],
                )
              else
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "한국어로 답을 입력해 보세요",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C5A48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      enabled: feedback == null,
                      minLines: 3,
                      maxLines: 4,
                      onChanged: (v) => subjective = v,
                      decoration: const InputDecoration(
                        hintText: "한국어로 답변을 작성하세요",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: (subjective.trim().isEmpty ||
                            submitting)
                            ? null
                            : () => submitAnswer(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFFFEEE9),
                          foregroundColor: brown,
                          elevation: 0,
                        ),
                        child: Text(
                            submitting ? "로딩 중..." : "제출"),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // 결과/피드백 + 다음 버튼
              if (feedback != null)
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: feedback!['correct']
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Text(
                        feedback!['correct']
                            ? "정답입니다!"
                            : "틀렸어요 😢",
                        style: TextStyle(
                          color: feedback!['correct']
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFFFEEE9),
                          foregroundColor: brown,
                          elevation: 0,
                        ),
                        child: Text(
                          idx < items.length - 1
                              ? "다음 문제"
                              : "결과 보기",
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 선택지 pill 버튼 (StudyPage _PillButton 느낌)
class _ChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _ChoiceButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF2F7A69);
    const textColor = Color(0xFF2F7A69);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
