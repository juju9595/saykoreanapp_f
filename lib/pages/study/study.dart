// lib/pages/study/study.dart (예시 경로)

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:saykoreanapp_f/api/api.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DTO
// ─────────────────────────────────────────────────────────────────────────────

class StudyDto {
  final int studyNo;
  final int genreNo;

  // 언어별 주제
  final String? themeKo;
  final String? themeJp;
  final String? themeCn;
  final String? themeEn;
  final String? themeEs;

  // 언어별 해설
  final String? commenKo;
  final String? commenJp;
  final String? commenCn;
  final String? commenEn;
  final String? commenEs;

  // 백엔드에서 CASE로 내려주는 통합 필드
  final String? themeSelected;
  final String? commenSelected;

  StudyDto({
    required this.studyNo,
    required this.genreNo,
    this.themeKo,
    this.themeJp,
    this.themeCn,
    this.themeEn,
    this.themeEs,
    this.commenKo,
    this.commenJp,
    this.commenCn,
    this.commenEn,
    this.commenEs,
    this.themeSelected,
    this.commenSelected,
  });

  factory StudyDto.fromJson(Map<String, dynamic> j) {
    return StudyDto(
      studyNo: j['studyNo'] is int
          ? j['studyNo'] as int
          : int.tryParse(j['studyNo']?.toString() ?? '') ?? 0,
      genreNo: j['genreNo'] is int
          ? j['genreNo'] as int
          : int.tryParse(j['genreNo']?.toString() ?? '') ?? 0,
      themeKo: j['themeKo']?.toString(),
      themeJp: j['themeJp']?.toString(),
      themeCn: j['themeCn']?.toString(),
      themeEn: j['themeEn']?.toString(),
      themeEs: j['themeEs']?.toString(),
      commenKo: j['commenKo']?.toString(),
      commenJp: j['commenJp']?.toString(),
      commenCn: j['commenCn']?.toString(),
      commenEn: j['commenEn']?.toString(),
      commenEs: j['commenEs']?.toString(),
      themeSelected: j['themeSelected']?.toString(),
      commenSelected: j['commenSelected']?.toString(),
    );
  }
}

class ExamDto {
  final int examNo; // 예문 번호
  final String? examSelected; // 선택된 언어의 예문
  final String? imagePath; // 이미지 경로
  final String? koAudioPath; // 한국어 오디오 경로
  final String? enAudioPath; // 영어 오디오 경로

  ExamDto({
    required this.examNo,
    this.examSelected,
    this.imagePath,
    this.koAudioPath,
    this.enAudioPath,
  });

  factory ExamDto.fromJson(Map<String, dynamic> j) => ExamDto(
    examNo: (j['examNo'] ?? j['id']) as int,
    examSelected: j['examSelected']?.toString(),
    imagePath: j['imagePath']?.toString(),
    koAudioPath: j['koAudioPath']?.toString(),
    enAudioPath: j['enAudioPath']?.toString(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// StudyPage : 주제 목록 + 상세 + 예문 학습
// ─────────────────────────────────────────────────────────────────────────────

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  bool _loading = false;
  String? _error;

  List<StudyDto> _subjects = const [];
  StudyDto? _subject;
  ExamDto? _exam;

  int? _genreNo;
  int _langNo = 1;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int && _subject == null) {
      // 필요하면 사용
    }
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _genreNo = prefs.getInt('selectedGenreNo');
      _langNo = prefs.getInt('selectedLangNo') ?? 1;

      if (_genreNo == null || _genreNo! <= 0) {
        setState(() => _error = '먼저 장르를 선택해 주세요.');
        return;
      }

      await _fetchSubjects();
    } catch (e) {
      setState(() => _error = '초기화 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ── API: 주제 목록 조회 (ApiClient.dio 사용)
  Future<void> _fetchSubjects() async {
    try {
      final res = await ApiClient.dio.get(
        '/saykorean/study/getSubject',
        queryParameters: {'genreNo': _genreNo, 'langNo': _langNo},
        options: Options(headers: {'Accept-Language': _langNo.toString()}),
      );

      final list = (res.data is List ? res.data as List : <dynamic>[])
          .map((e) => StudyDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      setState(() => _subjects = list);
    } on DioException catch (e) {
      setState(() => _error = e.message ?? '주제 목록을 가져오지 못했습니다.');
    } catch (_) {
      setState(() => _error = '주제 목록을 가져오지 못했습니다.');
    }
  }

  // ── API: 특정 주제 상세 조회
  Future<void> _fetchDailyStudy(int studyNo) async {
    try {
      final res = await ApiClient.dio.get(
        '/saykorean/study/getDailyStudy',
        queryParameters: {'studyNo': studyNo, 'langNo': _langNo},
        options: Options(headers: {'Accept-Language': _langNo.toString()}),
      );
      setState(
            () => _subject =
            StudyDto.fromJson(Map<String, dynamic>.from(res.data)),
      );
    } on DioException catch (e) {
      setState(() => _error = e.message ?? '주제 상세를 불러오지 못했습니다.');
    } catch (_) {
      setState(() => _error = '주제 상세를 불러오지 못했습니다.');
    }
  }

  // ── API: 첫 번째 예문 조회
  Future<void> _fetchFirstExam(int studyNo) async {
    try {
      final res = await ApiClient.dio.get(
        '/saykorean/study/exam/first',
        queryParameters: {'studyNo': studyNo, 'langNo': _langNo},
      );
      setState(
            () => _exam = ExamDto.fromJson(Map<String, dynamic>.from(res.data)),
      );
    } on DioException catch (e) {
      setState(() => _error = e.message ?? '예문을 불러오지 못했습니다.');
    } catch (_) {
      setState(() => _error = '예문을 불러오지 못했습니다.');
    }
  }

  // ── API: 다음 예문 조회
  Future<void> _fetchNextExam() async {
    if (_exam == null || _subject == null) return;
    try {
      final res = await ApiClient.dio.get(
        '/saykorean/study/exam/next',
        queryParameters: {
          'studyNo': _subject!.studyNo,
          'currentExamNo': _exam!.examNo,
          'langNo': _langNo,
        },
      );
      setState(
            () => _exam = ExamDto.fromJson(Map<String, dynamic>.from(res.data)),
      );
    } catch (_) {
      // 조용히 실패
    }
  }

  // ── API: 이전 예문 조회
  Future<void> _fetchPrevExam() async {
    if (_exam == null || _subject == null) return;
    try {
      final res = await ApiClient.dio.get(
        '/saykorean/study/exam/prev',
        queryParameters: {
          'studyNo': _subject!.studyNo,
          'currentExamNo': _exam!.examNo,
          'langNo': _langNo,
        },
      );
      setState(
            () => _exam = ExamDto.fromJson(Map<String, dynamic>.from(res.data)),
      );
    } catch (_) {
      // 조용히 실패
    }
  }

  // ── 오디오 재생 (ApiClient.getAudioUrl 사용)
  Future<void> _play(String? path) async {
    if (path == null || path.isEmpty) return;

    final resolved = ApiClient.getAudioUrl(path);

    try {
      await _player.stop();
      await _player.play(UrlSource(resolved));
    } catch (e) {
      // 무시
    }
  }

  // ── 학습 완료 처리 + 오늘치 교육완수 포인트 지급
  Future<void> _complete() async {
    final id = _subject?.studyNo;
    if (id == null || id <= 0) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1) 로컬에 완료한 studyNo 저장
      final prev = prefs.getStringList('studies') ?? [];
      final idStr = id.toString();
      if (!prev.contains(idStr)) {
        prev.add(idStr);
      }
      await prefs.setStringList('studies', prev);

      // 2) 포인트 지급 API 호출 (JWT에서 userNo 추출)
      final res = await ApiClient.dio.post(
        '/saykorean/study/complete-point',
      );
      debugPrint(
          '[Study] complete-point status=${res.statusCode}, data=${res.data}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('학습이 완료되었어요! 포인트가 지급되었습니다.'),
        ),
      );

      Navigator.pushNamed(context, '/successList');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('학습 완료 처리 중 오류가 발생했어요: $e'),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;
    final titleColor =
    isDark ? scheme.onSurface : const Color(0xFF6B4E42); // 브라운 포인트

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        centerTitle: true,
        title: Text(
          '학습',
          style: theme.textTheme.titleLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _bootstrap)
          : (_subject == null
          ? _buildList(theme, scheme, isDark)
          : _buildDetail(theme, scheme, isDark)),
    );
  }

  // ── 주제 목록 화면
  Widget _buildList(ThemeData theme, ColorScheme scheme, bool isDark) {
    final titleColor =
    isDark ? scheme.onSurface : const Color(0xFF6B4E42); // 상단 타이틀
    final subtitleColor =
    isDark ? scheme.onSurface.withOpacity(0.7) : const Color(0xFF9C7C68);

    if (_subjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: scheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                "등록된 학습 주제가 아직 없어요.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _subjects.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "내 학습 목록",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "학습할 주제를 하나 골라볼까요?",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        final s = _subjects[index - 1];
        final label = s.themeSelected ?? s.themeKo ?? '제목 없음';

        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                _loading = true;
                _error = null;
              });
              await _fetchDailyStudy(s.studyNo);
              await _fetchFirstExam(s.studyNo);
              if (mounted) {
                setState(() => _loading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: scheme.outlineVariant.withOpacity(0.6),
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 주제 상세 + 예문 학습 화면
  Widget _buildDetail(ThemeData theme, ColorScheme scheme, bool isDark) {
    final t = _subject!;
    final title = t.themeSelected ?? t.themeKo ?? '제목 없음';

    final mainTitleColor =
    isDark ? scheme.onSurface : const Color(0xFF6B4E42);
    final subtitleColor =
    isDark ? scheme.onSurface.withOpacity(0.7) : const Color(0xFF9C7C68);
    final sectionColor =
    isDark ? scheme.onSurface : const Color(0xFF7C5A48);
    final cardColor = isDark ? scheme.surface : Colors.white;

    final completeBg = isDark
        ? scheme.primaryContainer.withOpacity(0.9)
        : const Color(0xFFFFEEE9);
    final completeFg =
    isDark ? scheme.onPrimaryContainer : const Color(0xFF6B4E42);

    final outlineColor = scheme.outline.withOpacity(0.5);
    final outlineFg =
    isDark ? scheme.onSurface : const Color(0xFF6B4E42);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "오늘의 학습",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: mainTitleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "설명을 읽고 예문을 들으며 자연스럽게 익혀봐요.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "주제 설명",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: sectionColor,
            ),
          ),
          const SizedBox(height: 8),

          // 설명 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: mainTitleColor,
                  ),
                ),
                if (t.commenSelected != null &&
                    t.commenSelected!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      t.commenSelected!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? scheme.onSurface.withOpacity(0.8)
                            : const Color(0x995C4A42),
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            "예문 학습",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: sectionColor,
            ),
          ),
          const SizedBox(height: 8),

          if (_exam != null)
            _ExamCard(
              exam: _exam!,
              onPlayKo: () => _play(_exam!.koAudioPath),
              onPlayEn: () => _play(_exam!.enAudioPath),
              onPrev: _fetchPrevExam,
              onNext: _fetchNextExam,
            ),

          const SizedBox(height: 20),

          Text(
            "학습 완료",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: sectionColor,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: completeBg,
                foregroundColor: completeFg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('학습 완료'),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () => setState(() {
                _subject = null;
                _exam = null;
              }),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: outlineColor),
                foregroundColor: outlineFg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('목록으로'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 컴포넌트들 - Exam 카드, 에러 뷰
// ─────────────────────────────────────────────────────────────────────────────

class _ExamCard extends StatelessWidget {
  final ExamDto exam;
  final VoidCallback onPlayKo;
  final VoidCallback onPlayEn;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _ExamCard({
    required this.exam,
    required this.onPlayKo,
    required this.onPlayEn,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final text = exam.examSelected ?? '';
    final cardColor = isDark ? scheme.surface : Colors.white;
    final textColor =
    isDark ? scheme.onSurface : const Color(0xFF3F3F46);

    final outlineColor = scheme.outline.withOpacity(0.5);
    final btnFg =
    isDark ? scheme.onSurface : const Color(0xFF6B4E42);
    final navBg = isDark
        ? scheme.primaryContainer.withOpacity(0.9)
        : const Color(0xFFFFEEE9);
    final navFg =
    isDark ? scheme.onPrimaryContainer : const Color(0xFF6B4E42);

    final imageUrl = ApiClient.getImageUrl(exam.imagePath);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 350,
                height: 350,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('이미지를 불러올 수 없어요'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPlayKo,
                  icon: const Text('🔊'),
                  label: const Text('한국어'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: outlineColor),
                    foregroundColor: btnFg,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPlayEn,
                  icon: const Text('🔊'),
                  label: const Text('영어'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: outlineColor),
                    foregroundColor: btnFg,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrev,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navBg,
                    foregroundColor: navFg,
                    elevation: 0,
                  ),
                  child: const Text('이전'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navBg,
                    foregroundColor: navFg,
                    elevation: 0,
                  ),
                  child: const Text('다음'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? scheme.surface : theme.cardColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: scheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEEE9),
                  foregroundColor: const Color(0xFF6B4E42),
                  elevation: 0,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
