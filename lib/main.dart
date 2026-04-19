import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const CheckDuluApp());
}

class CheckDuluApp extends StatelessWidget {
  const CheckDuluApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckDulu',
      theme: ThemeData(
        primaryColor: const Color(0xFF3F51B5), // Deep Blue theme
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _urlController = TextEditingController();
  
  String? selectedFileName;
  String? selectedFileSize;
  bool isUrlValid = false;

  // --- FILE PICKER LOGIC ---
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        // Calculate size in MB
        double sizeInMb = result.files.single.size / (1024 * 1024);
        selectedFileSize = "${sizeInMb.toStringAsFixed(2)} MB";
      });
    }
  }

  // --- GOOGLE COLAB API CONNECTION ---
  Future<void> _analyzeData(bool isFile) async {
    // 1. Show Loading Spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      // ⚠️ REPLACE THIS WITH YOUR CURRENT NGROK URL FROM GOOGLE COLAB
      const String apiUrl = 'https://shanelle-nonsensationalistic-minna.ngrok-free.dev/scan';

      // 2. Build the Payload
      final Map<String, dynamic> requestBody = {
        "input_type": isFile ? "FILE" : "URL",
        "input_data": isFile ? selectedFileName : _urlController.text,
      };

      // 3. Send HTTP POST Request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true"
        },
        
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30)); // 30-second timeout

      // Hide Spinner
      if (mounted) Navigator.pop(context);

      // 4. Handle Response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String verdictString = responseData['verdict'] ?? 'Unknown Error';

        // Determine Traffic Light Status
        bool isSafeResult = verdictString.contains("✅ SAFE");

        // 5. Navigate to Result Screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                isSafe: isSafeResult,
                fileName: isFile ? (selectedFileName ?? 'Unknown') : _urlController.text,
                fileSize: isFile ? (selectedFileSize ?? '-') : '-',
                verdictDetails: verdictString,
                scanType: isFile ? 'File Analysis' : 'Lexical Analysis',
              ),
            ),
          );
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to AI server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3F51B5),
          title: const Text('CheckDulu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.insert_drive_file), text: "File Scan"),
              Tab(icon: Icon(Icons.link), text: "URL Scan"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- TAB 1: FILE SCAN ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 64, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            selectedFileName ?? "Tap to Upload",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          if (selectedFileSize != null)
                            Text(selectedFileSize!, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: selectedFileName == null ? null : () => _analyzeData(true),
                      child: const Text("Analyze File", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB 2: URL SCAN ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Check a Website",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter a URL to detect phishing or malicious content.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.link),
                      hintText: "Enter URL (e.g. http://malicious.com)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onChanged: (val) {
                      setState(() {
                        isUrlValid = val.isNotEmpty && (val.startsWith('http://') || val.startsWith('https://'));
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isUrlValid ? () => _analyzeData(false) : null,
                      child: const Text("Scan URL", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final bool isSafe;
  final String fileName;
  final String fileSize;
  final String verdictDetails;
  final String scanType;

  const ResultScreen({
    super.key,
    required this.isSafe,
    required this.fileName,
    required this.fileSize,
    required this.verdictDetails,
    required this.scanType,
  });

  @override
  Widget build(BuildContext context) {
    // Traffic Light Colors
    final Color bgColor = isSafe ? Colors.green : Colors.red;
    final IconData iconData = isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded;
    final String title = isSafe ? "No Threat Detected" : "High Risk Detected";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Result", style: TextStyle(color: Colors.white)),
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header (Green or Red)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Icon(iconData, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Technical Breakdown Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Technical Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 30),
                    _buildDetailRow("Input Name", fileName),
                    _buildDetailRow("Input Size", fileSize),
                    _buildDetailRow("Scan Type", "Heuristic + ML ($scanType)"),
                    const SizedBox(height: 16),
                    const Text("Server Response:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(verdictDetails, style: TextStyle(color: isSafe ? Colors.green[800] : Colors.red[800])),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}