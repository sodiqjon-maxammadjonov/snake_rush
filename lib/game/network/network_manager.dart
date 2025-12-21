import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:web_socket_channel/web_socket_channel.dart'; // Kelajakda

/// Network boshqaruvchi - Multiplayer uchun
class NetworkManager extends ChangeNotifier {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  // Connection state
  ConnectionState _state = ConnectionState.disconnected;
  String? _playerId;
  String? _roomId;

  // WebSocket (kelajakda)
  // WebSocketChannel? _channel;
  Timer? _pingTimer;

  // Players
  final Map<String, RemotePlayer> _remotePlayers = {};

  // Callbacks
  Function(RemotePlayer)? onPlayerJoined;
  Function(String playerId)? onPlayerLeft;
  Function(RemotePlayer)? onPlayerUpdated;

  // ==================== GETTERS ====================
  ConnectionState get state => _state;
  bool get isConnected => _state == ConnectionState.connected;
  String? get playerId => _playerId;
  String? get roomId => _roomId;
  List<RemotePlayer> get remotePlayers => _remotePlayers.values.toList();

  // ==================== CONNECTION ====================

  Future<bool> connect(String serverUrl) async {
    if (_state == ConnectionState.connected) return true;

    try {
      _state = ConnectionState.connecting;
      notifyListeners();

      // WebSocket connection
      // _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      // Listen to messages
      // _channel!.stream.listen(
      //   _handleMessage,
      //   onError: _handleError,
      //   onDone: _handleDisconnect,
      // );

      // Ping timer
      _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _sendPing();
      });

      _state = ConnectionState.connected;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Connection error: $e');
      _state = ConnectionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  void disconnect() {
    _pingTimer?.cancel();
    // _channel?.sink.close();

    _state = ConnectionState.disconnected;
    _playerId = null;
    _roomId = null;
    _remotePlayers.clear();

    notifyListeners();
  }

  // ==================== ROOM MANAGEMENT ====================

  Future<String?> createRoom() async {
    if (!isConnected) return null;

    final message = {
      'type': 'create_room',
      'playerId': _playerId,
    };

    _sendMessage(message);

    // Response'ni kutish
    // TODO: Future/Completer bilan to'g'ri implementation
    return null;
  }

  Future<bool> joinRoom(String roomId) async {
    if (!isConnected) return false;

    final message = {
      'type': 'join_room',
      'roomId': roomId,
      'playerId': _playerId,
    };

    _sendMessage(message);

    return true;
  }

  void leaveRoom() {
    if (!isConnected || _roomId == null) return;

    final message = {
      'type': 'leave_room',
      'roomId': _roomId,
      'playerId': _playerId,
    };

    _sendMessage(message);

    _roomId = null;
    _remotePlayers.clear();
    notifyListeners();
  }

  // ==================== GAME UPDATES ====================

  /// O'z pozitsiyangizni yuborish
  void sendPosition(Map<String, dynamic> positionData) {
    if (!isConnected || _roomId == null) return;

    final message = {
      'type': 'player_update',
      'roomId': _roomId,
      'playerId': _playerId,
      'data': positionData,
    };

    _sendMessage(message);
  }

  /// Ovqat yeyilganini xabar qilish
  void sendFoodEaten(String foodId) {
    if (!isConnected || _roomId == null) return;

    final message = {
      'type': 'food_eaten',
      'roomId': _roomId,
      'playerId': _playerId,
      'foodId': foodId,
    };

    _sendMessage(message);
  }

  /// O'lim
  void sendDeath() {
    if (!isConnected || _roomId == null) return;

    final message = {
      'type': 'player_death',
      'roomId': _roomId,
      'playerId': _playerId,
    };

    _sendMessage(message);
  }

  // ==================== MESSAGE HANDLING ====================

  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String);
      final type = message['type'] as String;

      switch (type) {
        case 'connected':
          _handleConnected(message);
          break;

        case 'room_created':
          _handleRoomCreated(message);
          break;

        case 'room_joined':
          _handleRoomJoined(message);
          break;

        case 'player_joined':
          _handlePlayerJoined(message);
          break;

        case 'player_left':
          _handlePlayerLeft(message);
          break;

        case 'player_update':
          _handlePlayerUpdate(message);
          break;

        case 'food_spawned':
          _handleFoodSpawned(message);
          break;

        default:
          debugPrint('Unknown message type: $type');
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  void _handleConnected(Map<String, dynamic> message) {
    _playerId = message['playerId'] as String;
    notifyListeners();
  }

  void _handleRoomCreated(Map<String, dynamic> message) {
    _roomId = message['roomId'] as String;
    notifyListeners();
  }

  void _handleRoomJoined(Map<String, dynamic> message) {
    _roomId = message['roomId'] as String;

    // Existing players
    final players = message['players'] as List;
    for (final playerData in players) {
      final player = RemotePlayer.fromJson(playerData);
      _remotePlayers[player.id] = player;
    }

    notifyListeners();
  }

  void _handlePlayerJoined(Map<String, dynamic> message) {
    final player = RemotePlayer.fromJson(message['player']);
    _remotePlayers[player.id] = player;

    onPlayerJoined?.call(player);
    notifyListeners();
  }

  void _handlePlayerLeft(Map<String, dynamic> message) {
    final playerId = message['playerId'] as String;
    _remotePlayers.remove(playerId);

    onPlayerLeft?.call(playerId);
    notifyListeners();
  }

  void _handlePlayerUpdate(Map<String, dynamic> message) {
    final playerId = message['playerId'] as String;
    final data = message['data'] as Map<String, dynamic>;

    final player = _remotePlayers[playerId];
    if (player != null) {
      player.updateFromData(data);
      onPlayerUpdated?.call(player);
    }
  }

  void _handleFoodSpawned(Map<String, dynamic> message) {
    // TODO: FoodManager'ga xabar berish
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    disconnect();
  }

  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    disconnect();
  }

  // ==================== HELPERS ====================

  void _sendMessage(Map<String, dynamic> message) {
    if (!isConnected) return;

    try {
      final encoded = jsonEncode(message);
      // _channel?.sink.add(encoded);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void _sendPing() {
    _sendMessage({'type': 'ping'});
  }
}

// ==================== ENUMS ====================

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

// ==================== REMOTE PLAYER ====================

class RemotePlayer {
  final String id;
  String name;
  double x;
  double y;
  double directionX;
  double directionY;
  int score;
  int length;

  RemotePlayer({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.directionX,
    required this.directionY,
    required this.score,
    required this.length,
  });

  factory RemotePlayer.fromJson(Map<String, dynamic> json) {
    return RemotePlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      directionX: (json['directionX'] as num).toDouble(),
      directionY: (json['directionY'] as num).toDouble(),
      score: json['score'] as int,
      length: json['length'] as int,
    );
  }

  void updateFromData(Map<String, dynamic> data) {
    x = (data['x'] as num).toDouble();
    y = (data['y'] as num).toDouble();
    directionX = (data['directionX'] as num).toDouble();
    directionY = (data['directionY'] as num).toDouble();
    score = data['score'] as int;
    length = data['length'] as int;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'x': x,
      'y': y,
      'directionX': directionX,
      'directionY': directionY,
      'score': score,
      'length': length,
    };
  }
}

/*
pubspec.yaml ga qo'shish:

dependencies:
  web_socket_channel: ^2.4.0
*/