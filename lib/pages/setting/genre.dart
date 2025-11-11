import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';


// --- Dio 설정 (macOS 데스크톱이면 127.0.0.1 권장) ---
final dio = Dio(BaseOptions(
  baseUrl: const String.fromEnvironment('API_HOST', defaultValue: 'http://localhost:8080'),
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 10),
));

class GenreDto {
  final int genreNo;
  final String genreName;

  GenreDto({required this.genreNo, required this.genreName});

  factory GenreDto.fromJson(Map<String, dynamic> j) => GenreDto(
    genreNo: j['genreNo'] as int,
    genreName: (j['genreName'] ?? j['genreName_ko'] ?? '').toString(),
  );
}

class GenrePage extends StatefulWidget {
  const GenrePage({super.key});

  @override
  State<GenrePage> createState() => _GenreState();
}

class _GenreState extends State<GenrePage> {
  bool _loading = false;
  String? _error;
  List<GenreDto> _items = const [];

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await dio.get('/saykorean/study/getGenre');
      // res.data가 이미 List면 그대로, String이면 JSON 파싱
      final raw = res.data is List ? res.data as List : jsonDecode(res.data as String) as List;
      final list = raw.map((e) => GenreDto.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() => _items = list);
    } on DioException catch (e) {
      setState(() => _error = e.message ?? '요청 실패');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('장르 목록')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('에러: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchGenres, child: const Text('다시 시도')),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final g = _items[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${g.genreNo}')),
            title: Text(g.genreName),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchGenres,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}