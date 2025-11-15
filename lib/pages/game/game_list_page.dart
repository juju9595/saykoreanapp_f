// lib/pages/game_list_page.dart


import 'package:flutter/material.dart';
import 'package:saykoreanapp_f/api/game_api.dart';
import 'package:saykoreanapp_f/pages/game/game_play_page.dart';



class GameListPage extends StatefulWidget {
  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  List<dynamic> _games = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadGames();
  }


  // 게임 목록 불러오기
  Future<void> _loadGames() async {
    try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final games = await GameApi.getGameList();

    setState(() {
      _games = games;
      _isLoading = false;
    });

    } catch (e) {
      setState(() {
        _errorMessage = '게임 목록을 불러오는데 실패했습니다.';
        _isLoading = false;
      });
      print('게임 목록 로드 실패: $e}');
    }
  }

  // 게임 선택 시 플레이 페이지로 이동
  void _onGameTap(dynamic game) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GamePlayPage(
              gameNo: game['gameNo'],
              gameTitle: game['gameTitle'],
            ),
        ),
    );
  }

  // 게임 아이콘 결정
  IconData _getGameIcon(int gameNo) {
    switch (gameNo) {
      case 1:
        return Icons.sports_esports; // 토돌이 한글 받기
      case 2:
        return Icons.catching_pokemon; // 한글 수박게임
      default:
        return Icons.gamepad;
    }
  }
  
  // 게임 색상 결정
  Color _getGameColor(int gameNo) {
    switch (gameNo) {
      case 1:
        return Color(0xFF667EEA); // 보라색
      case 2:
        return Color(0xFF38ADA9); // 청록색
      default:
        return Color(0xFFFFAAA5); // 코랄핑크
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '게임 선택',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Color(0xFFFFF9F0),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF333333)),
      ),
      backgroundColor: Color(0xFFFFF9F0),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFAAA5),
        ),
      )
          : _errorMessage != null
        ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16 , color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadGames,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFAAA5),
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                '다시 시도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      )
          : _games.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.games_outlined,
              size: 64,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 16),
            Text(
              '등록된 게임이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadGames,
        color: Color(0xFFFFAAA5),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _games.length,
          itemBuilder: (context, index) {
            final game = _games[index];
            final gameNo = game['gameNo'] ?? 0;
            final gameTitle = game['gameTitle'] ?? '제목 없음';
            final gameColor = _getGameColor(gameNo);
            final gameIcon = _getGameIcon(gameNo);

            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 3,
                child: InkWell(
                  onTap: () => _onGameTap(game),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          gameColor.withOpacity(0.1),
                          gameColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 게임 아이콘
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: gameColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            gameIcon,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        // 게임 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gameTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Game #$gameNo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 화살표 아이콘
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: gameColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}