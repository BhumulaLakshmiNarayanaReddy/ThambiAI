import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


Process? _backendProcess;
const String baseUrl = 'http://127.0.0.1:5000';
void main() => runApp(const ThambiApp());

class ThambiApp extends StatelessWidget {
  const ThambiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thambi AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF212121),
      ),
      home: const BackendLoader(),
    );
  }
}

class BackendLoader extends StatefulWidget {
  const BackendLoader({super.key});

  @override
  State<BackendLoader> createState() => _BackendLoaderState();
}

class _BackendLoaderState extends State<BackendLoader> {
  bool _connected = false;
  bool _showRetry = false; 
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    
    _listener = AppLifecycleListener(
      onExitRequested: () async {
        _backendProcess?.kill(); 
        return AppExitResponse.exit;
      },
    );

    _initConnection();
  }

  @override
  void dispose() {
    _listener.dispose(); 
    _backendProcess?.kill();
    debugPrint("🛑 Backend stopped");
    super.dispose();
  }

  Future<void> _initConnection() async {
    await _startSilentBackend();
    await _waitForBackend();
  }

  Future<void> _startSilentBackend() async {
    try {
      const backendDir = r"C:\ThambiAI-main\backend";
      const serverPath = r"C:\ThambiAI-main\backend\server.py";

      if (!Directory(backendDir).existsSync()) {
        debugPrint("❌ Backend folder not found");
        return;
      }

      // Check if process is already running to avoid duplicates
      _backendProcess?.kill();

      _backendProcess = await Process.start(
        'pythonw',
        [serverPath],
        workingDirectory: backendDir,
        runInShell: false,
        mode: ProcessStartMode.detachedWithStdio,
      );

      debugPrint("🚀 Backend process triggered");
    } catch (e) {
      debugPrint("❌ Backend start failed: $e");
    }
  }

  Future<void> _waitForBackend() async {
    if (mounted) setState(() => _showRetry = false);
    
    int attempts = 0;
    const int maxAttempts = 8; // Try for 8 seconds

    while (!_connected && attempts < maxAttempts) {
      try {
        final res = await http
            .get(Uri.parse('$baseUrl/health'))
            .timeout(const Duration(seconds: 1));

        if (res.statusCode == 200) {
          if (mounted) {
            setState(() => _connected = true);
          }
          debugPrint("✅ Backend connected!");
          return;
        }
      } catch (e) {
        debugPrint("🔄 Attempt $attempts: Waiting for server...");
      }

      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }

    // If we exit the loop without connecting
    if (mounted && !_connected) {
      setState(() => _showRetry = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connected) return const MainDashboard();

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.tealAccent),
            const SizedBox(height: 20),
            Text(
              _showRetry ? "Connection Failed" : "Starting Thambi AI…",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // --- SWITCH BETWEEN LOADER AND RETRY BUTTON ---
            if (!_showRetry)
              const CircularProgressIndicator(
                color: Colors.tealAccent,
                strokeWidth: 2,
              )
            else
              ElevatedButton.icon(
                onPressed: _initConnection, // Restarts both process and loop
                icon: const Icon(Icons.refresh),
                label: const Text("Retry Connection"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

            const SizedBox(height: 20),
            Text(
              _showRetry
                  ? "Check if Python is installed and server.py exists\nat C:\\ThambiAI\\backend"
                  : "Connecting to local server at $baseUrl",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class SoundWave extends StatefulWidget {
  const SoundWave({super.key});
  @override
  State<SoundWave> createState() => _SoundWaveState();
}

class _SoundWaveState extends State<SoundWave> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _barCount = 5;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      )..repeat(reverse: true),
    );
    _animations = _controllers.map((c) => Tween<double>(begin: 5, end: 25).animate(c)).toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    _backendProcess?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_barCount, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: _animations[i].value,
              decoration: BoxDecoration(color: Colors.tealAccent, borderRadius: BorderRadius.circular(2)),
            );
          },
        );
      }),
    );
  }
}

class HoverBubble extends StatefulWidget {
  final Widget child;
  final VoidCallback onCopy;
  final bool isUser;

  const HoverBubble({super.key, required this.child, required this.onCopy, required this.isUser});

  @override
  State<HoverBubble> createState() => _HoverBubbleState();
}

class _HoverBubbleState extends State<HoverBubble> {
  bool _isHovered = false;
  Timer? _hideTimer;

  void _onEnter() {
    _hideTimer?.cancel();
    setState(() => _isHovered = true);
  }

  void _onExit() {
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isHovered = false);
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          Positioned(
            bottom: -5,
            left: widget.isUser ? null : -35,
            right: widget.isUser ? -35 : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isHovered ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !_isHovered,
                child: IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: widget.isUser ? Colors.tealAccent : Colors.white60,
                  onPressed: () {
                    widget.onCopy();
                  },
                  tooltip: 'Copy Message',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainDashboardState extends State<MainDashboard> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  List<String> _sessions = [];
  String? _currentSession;

  bool _isTyping = false;
  bool _isSidebarOpen = true;
  bool _isMuted = true;
  // Voice
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;


  @override
    void initState() {
      super.initState(); 
      _loadSessions();       
      _initVoice();         
    }

    @override
    void dispose() { 
      _controller.dispose();
      _scrollController.dispose();
      _tts.stop();
      _speech.stop();
      super.dispose();
    }

  // ---------------- VOICE ----------------
  void _initVoice() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (val) {
          debugPrint('Mic Error: ${val.errorMsg}');
          setState(() => _isListening = false);
        },
        onStatus: (status) {
          debugPrint("Speech status: $status");
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );

      if (!_speechEnabled) {
        debugPrint("❌ Speech permission NOT granted");
        return;
      }

      final hasPermission = await _speech.hasPermission;
      debugPrint("🎤 Mic permission: $hasPermission");

      await _tts.setLanguage("en-IN");
      await _tts.setPitch(1.0);

      setState(() {});
    } catch (e) {
      debugPrint("❌ Mic init failed: $e");
    }
  }

  void _toggleListening() async {
    await _tts.stop();

    if (!_speechEnabled) {
      _initVoice();
      return;
    }

    if (!_isListening) {
      _controller.clear();
      setState(() => _isListening = true);

      _speech.listen(
        localeId: "en_US",
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          }
        },
        listenMode: ListenMode.dictation,
        partialResults: true,
      );
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }
  
  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(position);
        }
      }
    });
  }

  void _showManual() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        title: const Text("📖 User Manual", style: TextStyle(color: Colors.tealAccent)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _manualItem("📧 Sending Email", "Say 'Send an email'. Thambi will ask for the recipient, subject, and message."),
              _manualItem("💬 WhatsApp Message", "Say 'Message [Name]'. Thambi will then ask for the text."),
              _manualItem("📞 WhatsApp Call", "Say 'Call [Name]' or 'Video call [Name]'."),
              _manualItem("🛒 Shopping", "Say 'Buy [Item]' or 'Add to cart [Item]' to search on Amazon."),
              _manualItem("📂 Finding Files", "Say 'Find file [Name]' to search your system."),
              _manualItem("🌐 Opening Sites", "Say 'Go to [Website Name]' or 'YouTube [Video Name]'."),
              _manualItem("🖥️ Opening Apps", "Say 'Open [App Name]' like Chrome or VS Code."),
              _manualItem("❓ Doubts/Codes", "Say 'I have a doubt' or 'Explain this code'."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _manualItem(String title, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
          const SizedBox(height: 2),
          Text(instruction, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }

  void _showCapabilities() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: const BorderSide(color: Colors.white10)
        ),
        title: const Column(
          children: [
            Icon(Icons.auto_awesome, color: Colors.tealAccent, size: 40),
            SizedBox(height: 10),
            Text("What can Thambi AI do?", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _capabilityTile(Icons.help_outline, "General Knowledge", "Ask any doubts, solve complex math, or get explanations."),
              _capabilityTile(Icons.code, "Coding & Logic", "Write, debug, and explain code in multiple languages."),
              _capabilityTile(Icons.email_outlined, "Email Management", "Compose and send emails directly through commands."),
              _capabilityTile(Icons.folder_open, "File Search", "Find files in your Desktop, Downloads, and Documents."),
              _capabilityTile(Icons.launch, "App & Web Launcher", "Open any system application or website instantly."),
              _capabilityTile(Icons.shopping_cart_outlined, "Smart Shopping", "Help finding products and managing shopping tasks."),
              _capabilityTile(Icons.message, "WhatsApp & Social", "Send WhatsApp messages and manage chat threads."),
              _capabilityTile(Icons.video_call, "Calls & Video", "Initiate voice and video calls hands-free."),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: _showManual, // Opens the Manual
            child: const Text("Manual", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it", style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  Widget _capabilityTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.tealAccent, size: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Future<void> _speak(String text) async {
    if (_isMuted) return; 
    await _tts.stop();
    String cleanText = text.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    cleanText = cleanText.replaceAll(RegExp(r'[#*_~]'), '');
    if (cleanText.trim().isEmpty) return;
    await _tts.setVoice({"name": "en-us-x-iom-network", "locale": "en-US"});
    await _tts.setSpeechRate(0.9); 
    await _tts.setPitch(1.0);
    await _tts.speak(cleanText);
  }

  // ---------------- API ----------------
  Future<void> _startNewChat() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/new_chat'))
          .timeout(const Duration(seconds: 10));

      setState(() {
        _messages.clear();
        _currentSession = null;
      });

      _loadSessions();
    } catch (_) {}
  }

  Future<void> _loadSessions() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/history'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        setState(() {
          _sessions = List<String>.from(jsonDecode(res.body));
        });
      }
    } catch (_) {}
  }
  Future<void> _loadSessionContent(String filename) async {
    _currentSession = filename;
    try {
    final res = await http
        .get(Uri.parse('$baseUrl/history/$filename'))
        .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _messages.clear();
          for (var msg in data) {
          _messages.add({
            'sender': msg['sender'] == 'user' ? 'You' : 'Thambi AI',
            'message': msg['text'],
          });
          }
        });
        _scrollToBottom(animated: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    } catch (e) {
      print("Error loading session: $e");
    }
  }
  
Future<void> _deleteSession(String filename) async {
    try {
      final String encodedName = Uri.encodeComponent(filename);
      final res = await http.delete(Uri.parse('$baseUrl/delete_history/$encodedName'));
      if (res.statusCode == 200) {
        await _loadSessions();

        if (_currentSession == filename) {
          setState(() {
            _messages.clear();
            _currentSession = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Chat deleted"), 
              duration: Duration(seconds: 1),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } else {
        print("Server error: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      print("Error deleting session: $e");
    }
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
    _controller.clear();
    setState(() {
      _messages.add({'sender': 'You', 'message': input});
      _isTyping = true;
      _isListening = false;
    });
    _scrollToBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
    if (_isSidebarOpen) {
      setState(() => _isSidebarOpen = false);
    }
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auto'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': input}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final reply = jsonDecode(res.body)['reply'];
        setState(() {
          _messages.add({'sender': 'Thambi AI', 'message': reply});
          _isTyping = false;
        });
        _scrollToBottom();
        _speak(reply);
        _loadSessions();
      }
    } catch (_) {
      setState(() {
        _messages.add({'sender': 'Thambi AI', 'message': '⚠️ Connection Error'});
        _isTyping = false;
      });
    }
  }


  // ---------------- REFINED UI ----------------
// --- ADD THIS TO YOUR STATE CLASS ---
  final FocusNode _inputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [ 
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            width: _isSidebarOpen ? 260 : 64,
            decoration: const BoxDecoration(
              color: Color(0xFF171717),
              border: Border(
                right: BorderSide(color: Colors.white10, width: 0.5),
              ),
            ),
            child: _buildSidebarContent(),
          ),         
          Expanded(
            child: GestureDetector(
              // IMPORTANT: behavior prevents the detector from blocking children
              behavior: HitTestBehavior.translucent, 
              onTap: () {
                if (_isSidebarOpen) {
                  setState(() => _isSidebarOpen = false);
                  // Ensure we don't accidentally hide the keyboard
                  _inputFocusNode.requestFocus(); 
                }
              },
              child: _buildChatArea(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // HEADER
        Row(
          mainAxisAlignment: _isSidebarOpen
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (_isSidebarOpen)
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Thambi AI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
              ),

            IconButton(
              icon: Icon(
                _isSidebarOpen ? Icons.menu_open : Icons.menu,
                color: Colors.tealAccent,
              ),
              onPressed: () {
                setState(() => _isSidebarOpen = !_isSidebarOpen);
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // NEW CHAT (Re-referenced _startNewChat)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _isSidebarOpen
              ? OutlinedButton.icon(
                  onPressed: _startNewChat, // Connected
                  icon: const Icon(Icons.add),
                  label: const Text("New Chat"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 42),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.teal),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.add_box_outlined, color: Colors.white70),
                  onPressed: _startNewChat, // Connected
                ),
        ),

        const SizedBox(height: 10),

        // 3. CHAT HISTORY LIST 
        Expanded(
          child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, i) {
              // If sidebar is closed, don't build anything clickable here
              if (!_isSidebarOpen) return const SizedBox.shrink();

              final file = _sessions[i];
              final name = file.split('_202').first;

              return ListTile(
                dense: true,
                // Text and Delete button only exist when open
                title: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.white38),
                  onPressed: () => _deleteSession(file),
                ),
                onTap: () {
                  _loadSessionContent(file);
                  setState(() => _isSidebarOpen = false);
                },
              );
            },
          ),
        ),

        // CLICKABLE PROFILE (Replaces _buildSidebarProfile)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showCapabilities, // Connected to your window
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: _isSidebarOpen 
                    ? MainAxisAlignment.start 
                    : MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 14, 
                    backgroundColor: Colors.teal, 
                    child: Icon(Icons.person, size: 18, color: Colors.white)
                  ),
                  if (_isSidebarOpen) ...[
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Student User", 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Pro Plan", 
                            style: TextStyle(fontSize: 10, color: Colors.tealAccent)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        // Top Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              // Speaker Toggle Button
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _isMuted ? Colors.white54 : Colors.tealAccent,
                  size: 22,
                ),
                onPressed: () {
                  setState(() => _isMuted = !_isMuted);
                  if (_isMuted) _tts.stop();
                },
                tooltip: _isMuted ? "Unmute AI" : "Mute AI",
              ),
              const SizedBox(width: 4),
              const Text("Thambi AI", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.verified, size: 14, color: Colors.tealAccent),
            ],
          ),
        ),
        // ... (Messages List and Input Area remain same)
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemBuilder: (c, i) {
                    final m = _messages[i];
                    return _buildChatBubble(m['sender']!, m['message']!);
                  },
                ),
        ),
        if (_isTyping) 
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Thambi is thinking...", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildEmptyState() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, size: 48, color: Colors.teal),
        SizedBox(height: 16),
        Text(
          "How can I help you today?",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Ask questions, send emails, shop, or search files",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    ),
  );
}


Widget _buildChatBubble(String sender, String text) {
  bool isUser = sender == 'You';
  
  return Padding(
    // Increased horizontal padding to 50 so the hover button doesn't hit screen edges
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
    child: Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(sender, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        HoverBubble(
          isUser: isUser,
          onCopy: () async {
            if (text.trim().isNotEmpty) {
              try {
                await Clipboard.setData(ClipboardData(text: text));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Full message copied!"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                debugPrint("Clipboard error: $e");
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? Colors.teal : const Color(0xFF303135),
              borderRadius: BorderRadius.circular(12),
            ),
            // --- SelectionArea enables text highlighting ---
            child: MarkdownBody(
              data: text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 15),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                listBullet: const TextStyle(color: Colors.tealAccent),
                code: const TextStyle(
                  backgroundColor: Colors.black54,
                  color: Colors.orangeAccent,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInputArea() {
  bool hasText = _controller.text.trim().isNotEmpty;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF303135),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: hasText ? Colors.tealAccent.withOpacity(0.5) : Colors.white10,
          width: hasText ? 1.5 : 1,
        ),
        // This creates the "Glow" effect
        boxShadow: hasText ? [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ] : [],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.stop_circle : Icons.mic_none, 
                 color: _isListening ? Colors.redAccent : Colors.teal),
            onPressed: _toggleListening,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _inputFocusNode,
                  onChanged: (text) {
                    if (_isSidebarOpen && text.isNotEmpty) {
                      setState(() => _isSidebarOpen = false);
                    }
                  },
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: "Ask Thambi...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                if (_isListening)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SoundWave(),
                  ),
              ],
            ),
          ),
          // Glowing Send Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded, 
                color: hasText ? Colors.tealAccent : Colors.grey, // Changes color
              ),
              onPressed: hasText && !_isTyping ? _sendMessage : null,// Disables if empty
           ),
          ),
        ],
      ),
    ),
  );
}
}
