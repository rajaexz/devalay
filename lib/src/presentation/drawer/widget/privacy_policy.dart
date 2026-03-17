
import 'package:devalay_app/src/application/authentication/setting/setting_cubit.dart';
import 'package:devalay_app/src/application/authentication/setting/setting_state.dart';
import 'package:devalay_app/src/core/router/router.dart';

import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';


// Usage example widget
class DevalayApiExample extends StatefulWidget {
  const DevalayApiExample({super.key});

  @override
  _DevalayApiExampleState createState() => _DevalayApiExampleState();
}

class _DevalayApiExampleState extends State<DevalayApiExample> {

  @override
  void initState() {
    context.read<SettingCubit>().fetchGodForm('Privacy_policy');
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(builder: (context, state){
      if (state is SettingLoaded) {
        if (state.loadingState){
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage.isNotEmpty) {
          return Center(child: Text(state.errorMessage));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.whiteColor,
            leadingWidth: 30,
            leading: IconButton(onPressed: (){
              AppRouter.pop();
            }, icon: const Icon(Icons.arrow_back, color: AppColor.blackColor,)),
            title: const Text('Privacy Policy', style: TextStyle(color: AppColor.blackColor),),
            elevation: 0,
          ),
          backgroundColor: AppColor.whiteColor,
          body: SingleChildScrollView(
            child:Padding(padding: const EdgeInsetsGeometry.all(16),
            child:  Column(
              children: [
                Html(data: state.helpSupportModel?[0].details?.html??'')
              ],
            ),
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}
























// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as dom;
//
// // Privacy Policy Model (keeping for fallback/parsed content)
// class PrivacyPolicy {
//   final String title;
//   final String content;
//   final DateTime lastUpdated;
//   final List<String> sections;
//
//   PrivacyPolicy({
//     required this.title,
//     required this.content,
//     required this.lastUpdated,
//     required this.sections,
//   });
//
//   factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
//     return PrivacyPolicy(
//       title: json['title'] ?? 'Privacy Policy',
//       content: json['content'] ?? '',
//       lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
//       sections: List<String>.from(json['sections'] ?? []),
//     );
//   }
// }
//
// // Privacy Policy Service
// class PrivacyPolicyService {
//   static const String baseUrl = 'https://devalay.org/privacypolicy/';
//
//   static Future<PrivacyPolicy> fetchPrivacyPolicy() async {
//     try {
//       final response = await http.get(
//         Uri.parse(baseUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
//           'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         return _parseHtmlContent(response.body);
//       } else {
//         throw Exception('Failed to load privacy policy: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching privacy policy: $e');
//     }
//   }
//
//   static PrivacyPolicy _parseHtmlContent(String htmlContent) {
//     final document = html_parser.parse(htmlContent);
//     String title = document.querySelector('title')?.text ?? 'Privacy Policy';
//     String content = '';
//     List<String> sections = [];
//
//     final contentSelectors = [
//       '.privacy-policy',
//       '.privacy-content',
//       '.policy-content',
//       'main',
//       '.main-content',
//       '#content',
//       '.container',
//     ];
//
//     dom.Element? contentElement;
//     for (String selector in contentSelectors) {
//       contentElement = document.querySelector(selector);
//       if (contentElement != null) break;
//     }
//
//     contentElement ??= document.querySelector('body');
//
//     if (contentElement != null) {
//       content = contentElement.text;
//       final headings = contentElement.querySelectorAll('h1, h2, h3, h4');
//       sections = headings.map((heading) => heading.text.trim()).toList();
//     }
//
//     return PrivacyPolicy(
//       title: title,
//       content: content,
//       lastUpdated: DateTime.now(),
//       sections: sections,
//     );
//   }
// }
//
// // Privacy Policy Screen with InAppWebView
// class PrivacyPolicyScreen extends StatefulWidget {
//   final String? privacyPolicyUrl;
//   final bool useWebView;
//
//   const PrivacyPolicyScreen({
//     Key? key,
//     this.privacyPolicyUrl,
//     this.useWebView = true,
//   }) : super(key: key);
//
//   @override
//   _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
// }
//
// class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
//   InAppWebViewController? _webViewController;
//   late Future<PrivacyPolicy> _privacyPolicyFuture;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String? _error;
//   String _currentUrl = 'https://devalay.org/privacypolicy/';
//   bool _canGoBack = false;
//   bool _canGoForward = false;
//   double _progress = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentUrl = widget.privacyPolicyUrl ?? 'https://devalay.org/privacypolicy/';
//
//     if (!widget.useWebView) {
//       _loadPrivacyPolicy();
//     }
//   }
//
//   void _loadPrivacyPolicy() {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//       _hasError = false;
//     });
//
//     _privacyPolicyFuture = PrivacyPolicyService.fetchPrivacyPolicy();
//   }
//
//   void _refreshPage() {
//     if (widget.useWebView) {
//       _webViewController?.reload();
//     } else {
//       _loadPrivacyPolicy();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Privacy Policy'),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//         actions: [
//           if (widget.useWebView) ...[
//             IconButton(
//               icon: Icon(Icons.arrow_back_ios),
//               onPressed: _canGoBack
//                   ? () => _webViewController?.goBack()
//                   : null,
//             ),
//             IconButton(
//               icon: Icon(Icons.arrow_forward_ios),
//               onPressed: _canGoForward
//                   ? () => _webViewController?.goForward()
//                   : null,
//             ),
//           ],
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _refreshPage,
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               switch (value) {
//                 case 'webview':
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PrivacyPolicyScreen(
//                         privacyPolicyUrl: _currentUrl,
//                         useWebView: true,
//                       ),
//                     ),
//                   );
//                   break;
//                 case 'parsed':
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PrivacyPolicyScreen(
//                         privacyPolicyUrl: _currentUrl,
//                         useWebView: false,
//                       ),
//                     ),
//                   );
//                   break;
//               }
//             },
//             itemBuilder: (BuildContext context) => [
//               PopupMenuItem<String>(
//                 value: 'webview',
//                 child: ListTile(
//                   leading: Icon(Icons.web),
//                   title: Text('WebView Mode'),
//                   subtitle: Text('View original formatting'),
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'parsed',
//                 child: ListTile(
//                   leading: Icon(Icons.text_fields),
//                   title: Text('Parsed Mode'),
//                   subtitle: Text('Native Flutter UI'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: widget.useWebView ? _buildWebView() : _buildParsedView(),
//     );
//   }
//
//   Widget _buildWebView() {
//     return Column(
//       children: [
//         if (_progress < 1.0)
//           LinearProgressIndicator(
//             value: _progress,
//             backgroundColor: Colors.grey[300],
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//           ),
//         Expanded(
//           child: Stack(
//             children: [
//               InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
//                 initialSettings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   supportZoom: true,
//                   builtInZoomControls: true,
//                   displayZoomControls: false,
//                   useShouldOverrideUrlLoading: true,
//                   mediaPlaybackRequiresUserGesture: false,
//                   allowsInlineMediaPlayback: true,
//                   clearCache: false,
//                   clearSessionCache: false,
//                   hardwareAcceleration: true,
//                   supportMultipleWindows: false,
//                   useOnDownloadStart: false,
//                   useOnLoadResource: false,
//                   useShouldInterceptAjaxRequest: false,
//                   useShouldInterceptFetchRequest: false,
//                   applicationNameForUserAgent: "Flutter App",
//                   javaScriptCanOpenWindowsAutomatically: false,
//                   verticalScrollBarEnabled: true,
//                   horizontalScrollBarEnabled: true,
//                 ),
//                 onWebViewCreated: (controller) {
//                   _webViewController = controller;
//                 },
//                 onLoadStart: (controller, url) {
//                   setState(() {
//                     _isLoading = true;
//                     _hasError = false;
//                   });
//                 },
//                 onLoadStop: (controller, url) async {
//                   setState(() {
//                     _isLoading = false;
//                   });
//                   _updateNavigationState();
//                 },
//                 onReceivedError: (controller, request, error) {
//                   setState(() {
//                     _isLoading = false;
//                     _hasError = true;
//                     _error = error.description;
//                   });
//                 },
//                 onProgressChanged: (controller, progress) {
//                   setState(() {
//                     _progress = progress / 100.0;
//                   });
//                 },
//               ),
//               if (_hasError)
//                 Container(
//                   color: Colors.white,
//                   padding: EdgeInsets.all(16),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, size: 64, color: Colors.red),
//                         SizedBox(height: 16),
//                         Text(
//                           'Failed to load privacy policy',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           _error ?? 'Unknown error occurred',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                         SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _refreshPage,
//                           child: Text('Retry'),
//                         ),
//                         SizedBox(height: 8),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => PrivacyPolicyScreen(
//                                   privacyPolicyUrl: 'https://devalay.org/privacypolicy/',
//                                   useWebView: true,  // Start with WebView mode
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Text('Try Parsed Mode'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildParsedView() {
//     return FutureBuilder<PrivacyPolicy>(
//       future: _privacyPolicyFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text('Loading Privacy Policy...'),
//               ],
//             ),
//           );
//         }
//
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.red),
//                 SizedBox(height: 16),
//                 Text(
//                   'Error loading privacy policy',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   snapshot.error.toString(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _loadPrivacyPolicy,
//                   child: Text('Retry'),
//                 ),
//                 SizedBox(height: 8),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PrivacyPolicyScreen(
//                           privacyPolicyUrl: _currentUrl,
//                           useWebView: true,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text('Try WebView Mode'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final policy = snapshot.data!;
//         return SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         policy.title,
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Last updated: ${_formatDate(policy.lastUpdated)}',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 16),
//
//               // Sections (if available)
//               if (policy.sections.isNotEmpty) ...[
//                 Text(
//                   'Table of Contents',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Card(
//                   child: Column(
//                     children: policy.sections.asMap().entries.map((entry) {
//                       return ListTile(
//                         leading: CircleAvatar(
//                           radius: 12,
//                           child: Text('${entry.key + 1}'),
//                         ),
//                         title: Text(entry.value),
//                         onTap: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Tapped: ${entry.value}')),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//               ],
//
//               // Content
//               Text(
//                 'Privacy Policy Content',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     policy.content.isEmpty
//                         ? 'Privacy policy content will be displayed here once loaded from the API.'
//                         : policy.content,
//                     style: TextStyle(
//                       height: 1.5,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 16),
//
//               // Action buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Download feature would be implemented here')),
//                         );
//                       },
//                       icon: Icon(Icons.download),
//                       label: Text('Download'),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Share feature would be implemented here')),
//                         );
//                       },
//                       icon: Icon(Icons.share),
//                       label: Text('Share'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _updateNavigationState() async {
//     if (_webViewController != null) {
//       final canGoBack = await _webViewController!.canGoBack();
//       final canGoForward = await _webViewController!.canGoForward();
//       setState(() {
//         _canGoBack = canGoBack;
//         _canGoForward = canGoForward;
//       });
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }


// // Example usage in main app
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Privacy Policy Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: PrivacyPolicyScreen(),
//     );
//   }
// }

