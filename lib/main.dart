import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  // Initialiser la plateforme WebView avant de lancer l'app
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Enregistrer les implémentations de plateforme
  if (WebViewPlatform.instance is! AndroidWebViewPlatform) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  
  // Activer le mode debug pour WebView Android
  if (kDebugMode) {
    AndroidWebViewController.enableDebugging(true);
  }
  
  runApp(const NawaraBloomApp());
}

class NawaraBloomApp extends StatelessWidget {
  const NawaraBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NawaraBloom',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      ),
      home: const WebViewScreen(),
      debugShowCheckedModeBanner: kDebugMode,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with TickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUrl = 'https://nawarabloom.com/shop';
  double _loadingProgress = 0.0;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeWebView();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeWebView() {
    _controller = WebViewController();

    if (_controller.platform is AndroidWebViewController) {
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
        print('🐛 WebView Debug Mode activé pour Android');
      }
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 NawaraBloomApp/1.0')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
            _progressController.animateTo(_loadingProgress);
            
            if (kDebugMode) {
              print('🔄 Progression: $progress%');
            }
          },
          onPageStarted: (String url) {
            if (kDebugMode) {
              print('🌐 Début du chargement: $url');
            }
            setState(() {
              _isLoading = true;
              _hasError = false;
              _currentUrl = url;
              _loadingProgress = 0.0;
            });
            _fadeController.forward();
          },
          onPageFinished: (String url) {
            if (kDebugMode) {
              print('✅ Chargement terminé: $url');
            }
            setState(() {
              _isLoading = false;
              _loadingProgress = 1.0;
            });
            _fadeController.reverse();
            
            // Haptic feedback pour indiquer que la page est chargée
            HapticFeedback.lightImpact();
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print('❌ Erreur WebView: ${error.description}');
              print('   Code d\'erreur: ${error.errorCode}');
              print('   Type d\'erreur: ${error.errorType}');
            }
            
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
            
            _showModernErrorSnackBar(error);
            HapticFeedback.heavyImpact();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (kDebugMode) {
              print('🔗 Navigation: ${request.url}');
            }
            
            if (request.url.startsWith('https://nawarabloom.com') ||
                request.url.startsWith('http://nawarabloom.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (kDebugMode) {
            print('📱 Message JS: ${message.message}');
          }
        },
      )
      ..loadRequest(Uri.parse('https://nawarabloom.com/shop'));
    
    if (kDebugMode) {
      print('🚀 webView initialisé');
    }
  }

  void _showModernErrorSnackBar(WebResourceError error) {
    String errorMessage = 'Erreur de connexion';
    String actionMessage = 'Vérifiez votre connexion internet';
    IconData errorIcon = Icons.wifi_off_rounded;
    
    switch (error.errorType) {
      case WebResourceErrorType.hostLookup:
        errorMessage = 'Serveur introuvable';
        errorIcon = Icons.dns_rounded;
        break;
      case WebResourceErrorType.timeout:
        errorMessage = 'Délai d\'attente dépassé';
        errorIcon = Icons.timer_off_rounded;
        break;
      case WebResourceErrorType.connect:
        errorMessage = 'Connexion impossible';
        errorIcon = Icons.signal_wifi_connected_no_internet_4_rounded;
        break;
      default:
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(errorIcon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    actionMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: _refreshPage,
        ),
      ),
    );
  }

  Future<void> _refreshPage() async {
    if (kDebugMode) {
      print('🔄 Actualisation demandée');
    }
    HapticFeedback.mediumImpact();
    await _controller.reload();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      if (kDebugMode) {
        print('⬅️ Navigation arrière');
      }
      await _controller.goBack();
      return false;
    }
    return true;
  }

  void _showConnectionTest() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ConnectionTestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildModernAppBar(),
        body: Stack(
          children: [
            // Gradient de fond
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF388E3C),
                  ],
                ),
              ),
            ),
            
            // WebView
            Positioned.fill(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: WebViewWidget(controller: _controller),
                ),
              ),
            ),
            
            // Barre de progression moderne
            if (_isLoading)
              Positioned(
                top: kToolbarHeight + MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                      minHeight: 3,
                    );
                  },
                ),
              ),
            
            // Overlay de chargement avec animation
            if (_isLoading)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Positioned.fill(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback si le logo n'est pas trouvé
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.local_florist_rounded,
                                  size: 48,
                                  color: Color(0xFF4CAF50),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'NawaraBloom',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chargement de votre boutique...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 200,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressController.value,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Text(
                              '${(_progressController.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4CAF50),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('NawaraBloom'),
          ),
        ],
      ),
      actions: [
        // Bouton Actualiser
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshPage,
            tooltip: 'Actualiser',
          ),
        ),
        
        // Menu moderne
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            onSelected: (value) async {
              HapticFeedback.selectionClick();
              switch (value) {
                case 'home':
                  await _controller.loadRequest(
                    Uri.parse('https://nawarabloom.com/shop'),
                  );
                  break;
                case 'back':
                  if (await _controller.canGoBack()) {
                    await _controller.goBack();
                  }
                  break;
                case 'forward':
                  if (await _controller.canGoForward()) {
                    await _controller.goForward();
                  }
                  break;
                case 'test_connection':
                  _showConnectionTest();
                  break;
                case 'debug_info':
                  if (kDebugMode) {
                    _showDebugInfo();
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              _buildMenuItemWithIcon(Icons.home_rounded, 'Accueil', 'home'),
              _buildMenuItemWithIcon(Icons.arrow_back_rounded, 'Précédent', 'back'),
              _buildMenuItemWithIcon(Icons.arrow_forward_rounded, 'Suivant', 'forward'),
              const PopupMenuDivider(),
              _buildMenuItemWithIcon(Icons.wifi_find_rounded, 'Test Connexion', 'test_connection', 
                color: Colors.blue),
              if (kDebugMode) ...[
                const PopupMenuDivider(),
                _buildMenuItemWithIcon(Icons.bug_report_rounded, 'Debug Info', 'debug_info', 
                  color: Colors.orange),
              ],
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItemWithIcon(
    IconData icon, 
    String text, 
    String value, 
    {Color? color}
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DebugInfoSheet(
        controller: _controller,
        currentUrl: _currentUrl,
        isLoading: _isLoading,
      ),
    );
  }
}

// Widget pour le test de connexion simplifié
class ConnectionTestSheet extends StatefulWidget {
  const ConnectionTestSheet({super.key});

  @override
  State<ConnectionTestSheet> createState() => _ConnectionTestSheetState();
}

class _ConnectionTestSheetState extends State<ConnectionTestSheet> {
  bool _isTesting = false;
  final List<Map<String, dynamic>> _testResults = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_find_rounded,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Test de Connexion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (!_isTesting && _testResults.isEmpty)
                    Column(
                      children: [
                        Text(
                          'Testez votre connexion réseau pour diagnostiquer les problèmes.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _runConnectionTest,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Lancer le test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  if (_isTesting)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Test en cours...'),
                      ],
                    ),
                  
                  if (_testResults.isNotEmpty)
                    Column(
                      children: [
                        ..._testResults.map((result) => _buildTestResult(result)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _runConnectionTest,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Relancer'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTestResult(Map<String, dynamic> result) {
    final bool success = result['success'] as bool;
    final String url = result['url'] as String;
    final String message = result['message'] as String;
    final int? responseTime = result['responseTime'] as int?;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.error_rounded,
            color: success ? Colors.green.shade600 : Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  url,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (responseTime != null && success)
                  Text(
                    'Temps de réponse: ${responseTime}ms',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Test de connexion simplifié avec HttpClient de base
  Future<void> _runConnectionTest() async {
    setState(() {
      _isTesting = true;
      _testResults.clear();
    });

    final testUrls = [
      'https://www.google.com',
      'https://nawarabloom.com',
      'https://nawarabloom.com/shop',
    ];

    for (final url in testUrls) {
      try {
        final stopwatch = Stopwatch()..start();
        
        // Utilisation de HttpClient de base (dart:io)
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);
        
        final uri = Uri.parse(url);
        final request = await client.getUrl(uri);
        request.headers.set('User-Agent', 'NawaraBloomApp/1.0');
        final response = await request.close();
        
        stopwatch.stop();
        client.close();
        
        final bool success = response.statusCode >= 200 && response.statusCode < 400;
        
        setState(() {
          _testResults.add({
            'url': url,
            'success': success,
            'message': success 
                ? 'Connexion réussie (${response.statusCode})' 
                : 'Erreur HTTP ${response.statusCode}',
            'responseTime': stopwatch.elapsedMilliseconds,
          });
        });
        
        if (kDebugMode) {
          print('🌐 Test $url: ${success ? "OK" : "FAIL"} (${stopwatch.elapsedMilliseconds}ms)');
        }
        
      } catch (e) {
        setState(() {
          _testResults.add({
            'url': url,
            'success': false,
            'message': _getErrorMessage(e),
            'responseTime': null,
          });
        });
        
        if (kDebugMode) {
          print('❌ Test $url: ERREUR - $e');
        }
      }
      
      // Petite pause entre les tests pour l'UX
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isTesting = false;
    });
  }

  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      if (error.osError?.errorCode == 7) {
        return 'Pas de connexion internet';
      } else if (error.osError?.errorCode == 110) {
        return 'Délai d\'attente dépassé';
      } else {
        return 'Erreur réseau: ${error.message}';
      }
    } else if (error is HttpException) {
      return 'Erreur HTTP: ${error.message}';
    } else if (error.toString().contains('timeout')) {
      return 'Délai d\'attente dépassé';
    } else {
      return 'Erreur: ${error.toString().split(':').first}';
    }
  }
}

// Widget pour les informations de debug simplifié
class DebugInfoSheet extends StatelessWidget {
  final WebViewController controller;
  final String currentUrl;
  final bool isLoading;

  const DebugInfoSheet({
    super.key,
    required this.controller,
    required this.currentUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.bug_report_rounded,
                  color: Colors.orange.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informations Debug',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('URL Actuelle', currentUrl),
                  _buildInfoRow('État', isLoading ? 'Chargement...' : 'Chargé'),
                  _buildInfoRow('JavaScript', 'Activé (Unrestricted)'),
                  _buildInfoRow('User Agent', 'NawaraBloomApp/1.0'),
                  _buildInfoRow('Plateforme', Platform.operatingSystem),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.runJavaScript('''
                              console.log('Test JavaScript depuis Flutter');
                              document.body.style.border = '3px solid red';
                              setTimeout(() => {
                                document.body.style.border = '';
                                alert('Debug: JavaScript fonctionne !');
                              }, 1000);
                            ''');
                          },
                          icon: const Icon(Icons.code_rounded),
                          label: const Text('Test JS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}