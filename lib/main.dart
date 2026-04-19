import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const CheckDuluApp());
}

class CheckDuluApp extends StatelessWidget {
  const CheckDuluApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckDulu',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light slate background
        primaryColor: const Color(0xFF0F172A), // Deep navy/slate
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF06B6D4), // Cyan accent
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w700, 
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06B6D4),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// SCREEN 1: MULTI-MODAL SCANNING DASHBOARD
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedFileName;
  String? selectedFileSize;
  final TextEditingController _urlController = TextEditingController();
  bool isUrlValid = false;

  // Actual File Picker Implementation
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      
      setState(() {
        selectedFileName = file.name;
        // Convert file size from bytes to Megabytes (MB)
        double sizeInMb = file.size / (1024 * 1024);
        selectedFileSize = "${sizeInMb.toStringAsFixed(2)} MB";
      });
    }
  }

  // Real-time URL validation
  void _validateUrl(String value) {
    setState(() {
      isUrlValid = value.startsWith('http://') || value.startsWith('https://');
    });
  }

  // Navigate to Result Screen
  void _analyzeData(bool isFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          isSafe: !isFile, // Simulating: URL is Safe, File is Malicious
          fileName: selectedFileName ?? 'Unknown',
          fileSize: selectedFileSize ?? '0 MB',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CheckDulu'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF06B6D4),
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.shield_outlined), text: 'File Scan'),
              Tab(icon: Icon(Icons.link_rounded), text: 'URL Scan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- FILE SCAN TAB ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_outlined, size: 60, color: Color(0xFF0F172A)),
                  const SizedBox(height: 16),
                  const Text(
                    'Malware Detection',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload a file to scan for hidden threats, double extensions, and known malware signatures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40), // Adjusted padding to fit text
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            selectedFileName == null 
                              ? Icons.cloud_upload_outlined 
                              : Icons.check_circle_outline, 
                            size: 70, 
                            color: selectedFileName == null 
                              ? const Color(0xFF0F172A) 
                              : const Color(0xFF10B981) // Emerald green when selected
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedFileName == null ? 'Tap to browse device' : 'Ready for Analysis',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                          if (selectedFileName != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    selectedFileName!, 
                                    style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedFileSize!, 
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: selectedFileName != null ? () => _analyzeData(true) : null,
                    icon: const Icon(Icons.manage_search_rounded),
                    label: const Text('Analyze'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // --- URL SCAN TAB ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.travel_explore, size: 60, color: Color(0xFF0F172A)),
                  const SizedBox(height: 16),
                  const Text(
                    'Phishing Detection',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Analyze links for typosquatting and malicious intent before you click.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _urlController,
                    onChanged: _validateUrl,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.link, color: Color(0xFF94A3B8)),
                      hintText: 'https://...',
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isUrlValid ? const Color(0xFF10B981) : const Color(0xFF06B6D4),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: isUrlValid ? () => _analyzeData(false) : null,
                    icon: const Icon(Icons.manage_search_rounded),
                    label: const Text('Analyze'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 2: ANALYSIS RESULT VIEW (VERDICT)
// ==========================================
class ResultScreen extends StatelessWidget {
  final bool isSafe; 
  final String fileName;
  final String fileSize;

  const ResultScreen({
    Key? key, 
    required this.isSafe,
    required this.fileName,
    required this.fileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Professional color codes for states
    final bgColor = isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444); // Emerald vs Rose
    final icon = isSafe ? Icons.verified_user : Icons.gpp_bad;
    final title = isSafe ? 'No Threat Detected' : 'High Risk Detected';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Scan Report', style: TextStyle(fontSize: 18)),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 80),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  isSafe ? 'Confidence Score: 98%' : 'Confidence Score: 92% (Critical)',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const Text(
                  'Technical Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Target', isSafe ? 'https://google.com' : fileName, false),
                        _buildDetailRow('Size', isSafe ? '-' : fileSize, false),
                        _buildDetailRow('Engine', 'Heuristic + ML', false),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(height: 1),
                        ),
                        _buildDetailRow(
                            'Metadata Check', 
                            isSafe ? 'Clean' : 'Double Extension', 
                            !isSafe),
                        _buildDetailRow(
                            'Signature', 
                            isSafe ? 'Not Found' : 'Matched Database', 
                            !isSafe),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Insight Card
                Container(
                  decoration: BoxDecoration(
                    color: isSafe ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSafe ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.memory, 
                          color: isSafe ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            isSafe 
                              ? 'System Analysis:\nThe target passed all lexical and heuristic checks. No malicious obfuscation or typosquatting patterns were detected.'
                              : 'System Analysis:\nCritical anomaly detected. The file structure attempts to mask its true executable nature. It matches behavioral patterns of known polymorphic threats.',
                            style: TextStyle(
                              color: isSafe ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isAlert) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 15)),
          Flexible(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isAlert ? const Color(0xFFEF4444) : const Color(0xFF1E293B)
              ),
            ),
          ),
        ],
      ),
    );
  }
}