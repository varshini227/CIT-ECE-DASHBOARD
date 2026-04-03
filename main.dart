import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'firebase_options.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/error_logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// Note: Web CSV downloads will show a data URI that can be saved manually
// Android/Mobile users will have files saved to documents folder

// ------------------------------------------------------------
// RESPONSIVE TEXT STYLES - Inter & Poppins
// ------------------------------------------------------------
class ResponsiveText {
  static TextStyle headingXL(BuildContext context) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
  
  static TextStyle headingLG(BuildContext context) => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  
  static TextStyle headingMD(BuildContext context) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  
  static TextStyle headingSM(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle bodyLG(BuildContext context) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  static TextStyle bodyMD(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  static TextStyle bodySM(BuildContext context) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static TextStyle labelLG(BuildContext context) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

// ------------------------------------------------------------
// ADMIN THEME - Blue Color Palette
// ------------------------------------------------------------
class AdminTheme {
  // Blue-based color palette
  static const primaryColor = Color(0xFF1E40AF);      // Deep Blue
  static const primaryLight = Color(0xFF3B82F6);      // Bright Blue
  static const primaryAccent = Color(0xFF0EA5E9);     // Sky Blue
  static const secondaryColor = Color(0xFF06B6D4);    // Cyan
  static const successColor = Color(0xFF10B981);      // Emerald
  static const warningColor = Color(0xFFF59E0B);      // Amber
  static const neutralLight = Color(0xFFF9FAFB);      // Off-white
  static const neutralDark = Color(0xFF1F2937);       // Dark gray
  static const borderColor = Color(0xFFE5E7EB);       // Light gray
  static const dangerColor = Color(0xFFEF4444);       // Red
  static const backgroundColor = Color(0xFFF8FAFC);   // Soft neutral bg
  
  // Glassmorphism effect for modern cards
  static BoxDecoration glassEffect() => BoxDecoration(
    color: Colors.white.withOpacity(0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Blue gradient shadow for depth
  static List<BoxShadow> get blueShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 6),
    )
  ];
  
  // Subtle shadow
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 3),
    )
  ];
  
  // Card shadow for modern look
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1E40AF).withOpacity(0.12),
      blurRadius: 14,
      offset: const Offset(0, 4),
    )
  ];
  
  // Glowing shadow for FAB (floating action button)
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryAccent.withOpacity(0.6),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryLight.withOpacity(0.3),
      blurRadius: 36,
      offset: const Offset(0, 12),
    ),
  ];
}

void main() async {
  // 1. Ensure the engine is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  // 3. Start the App
  runApp(const MyApp());
}

// --- MAIN APP ENTRY ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Engagement Pulse ',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AdminTheme.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminTheme.primaryColor,
          primary: AdminTheme.primaryColor,
          secondary: AdminTheme.secondaryColor,
          surface: Colors.white,
        ),
        
        appBarTheme: AppBarTheme(
          backgroundColor: AdminTheme.primaryColor, 
          foregroundColor: AdminTheme.neutralLight,
          centerTitle: true,
          elevation: 2,
          toolbarTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: AdminTheme.primaryColor.withOpacity(0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),

        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AdminTheme.primaryColor,
            selectedForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AdminTheme.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}

//--- EVALUATION POINT LIMITS BY SEMESTER ---



final Map<String, int> sem2Limits = {
  'workshop_pts': 4, 'nptel_pts': 6, 'volProject_pts': 6, 'classRep_pts': 4, 
  'linkedin_pts': 4, 'discipline_pts': 6, 'symposium_pts': 6, 'higherStudies_pts': 2, 'noArrears_pts': 2
}; 

final Map<String, int> sem3Limits = {
  'mini_project_hackathon_pts': 10,
  'leadership_club_vol_pts': 10,
  'network_exposure_pts': 10,
  'hackathon_prize': 8,
  'no_arrears_pts': 2
}; 

final Map<String, int> sem4Limits = {
  'coe_research_project_pts': 10,
  'coe_coord_leadership_pts': 10,
  'industry_alumni_network_pts': 10,
  'tech_blog_pts': 5,
  'no_arrears_y2_pts': 5
}; 

final Map<String, int> sem5Limits = {
  'internship_training_pts': 5, 
  'coe_industry_project_pts': 5, 
  'bootcamp_mentoring_pts': 5, 
  'mock_interview_org_pts': 5, 
  'expert_conf_pts': 5, 
  'alumni_testimonials_pts': 5,
  'no_arrears_y3_pts': 5, 
  'conf_publication_pts': 5
};

final Map<String, int> sem6Limits = {
  'placement_certification_pts': 5,
  'system_integration_pts': 5,
  'training_coord_pts': 5,
  'leadership_exec_pts': 5,
  'expert_guest_lecture_pts': 5,
  'alumni_referral_pts': 5,
  'placement_deliverables_pts': 5,
  'no_arrears_y4_pts': 5
};
final Map<String, int> sem7Limits = {}; // 7th sem = cumulative only

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _resetPassword() async {
    String email = _email.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Email ID first")));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset link sent! Check your inbox.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    String cleanEmail = _email.text.trim().toLowerCase().replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: cleanEmail, password: _pass.text.trim());
      
      // ADMIN FIX: Search top-level 'users' collection for the email
      var q = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: cleanEmail).get();
      
      if (!mounted) return;
      if (q.docs.isNotEmpty) {
        var u = q.docs.first;
        String role = (u['role'] ?? 'student').toString().toLowerCase().trim();
        Widget page = (role == 'admin') ? const AdminDashboard() : (role == 'staff' ? const StaffDashboard() : StudentDashboard(uid: u.id));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
      }
    } catch (e) {
      await ErrorLogger.logError(
        errorName: 'LoginError',
        message: e.toString(),
        location: 'LoginPage._login()',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
 
  Widget build(BuildContext context) {
    return Scaffold(
      // We use Stack to place the image behind your content
      body: Stack(
        children: [
          // --- LAYER 1: THE BACKGROUND IMAGE ---
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Ensure this path matches your pubspec.yaml exactly
                image: AssetImage('assets/images/processor.JPEG'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
        

 

          // --- LAYER 2: THE GRADIENT OVERLAY ---
          // Added .withValues(alpha: 0.7) so the photo is visible through the colors
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF001D3D).withValues(alpha: 0.8), 
                  const Color(0xFF003566).withValues(alpha: 0.7),
                  const Color(0xFF0077B6).withValues(alpha: 0.6), 
                ],
              ),
            ),
          ),

          // --- LAYER 3: YOUR EXISTING FORMAT ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(children: [
                const Icon(Icons.school, size: 80, color: Colors.white),
                const Text("Welcome to Engagement Pulse",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 40),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email ID",
                    labelStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email, color: Color.fromARGB(225, 255, 255, 255)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pass,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(249, 255, 255, 255)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),
                _loading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Column(children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("LOGIN",
                                style: TextStyle(color: Color(0xFF001D3D), fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        TextButton(
                          onPressed: _resetPassword,
                          child: const Text("Forgot Password?",
                              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 14)),
                        ),
                      ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

}
//Student Dashboad
class StudentDashboard extends StatefulWidget {
  final String uid;
  const StudentDashboard({super.key, required this.uid});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String viewYear = "1st Year";
  
  // --- STUDENT PROFILE CARD ---
Widget _buildStudentProfileCard(Map<String, dynamic> studentData, int totalScore) {
  String name = studentData['name'] ?? 'Student';
  String email = studentData['email'] ?? 'No email';
  String batch = studentData['batch'] ?? '2025';
  
  // Determine emoji based on achievement level
  String achievementEmoji = '\u{1F3AF}';
  if (totalScore >= 100) achievementEmoji = '\u{1F3C6}';
  if (totalScore >= 80) achievementEmoji = '\u{1F947}';
  if (totalScore >= 60) achievementEmoji = '\u{1F680}';
  if (totalScore >= 40) achievementEmoji = '\u{2B50}';
  
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.85),
          const Color(0xFF1E40AF).withValues(alpha: 0.90),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E40AF).withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name with emoji
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              achievementEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Email and Batch in smaller font for mobile
        Text(
          email,
          style: const TextStyle(
            color: Color(0xFFC7D2FE),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          'Batch: $batch',
          style: const TextStyle(
            color: Color(0xFFC7D2FE),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}


  // --- PLACE THIS CODE INSIDE _StudentDashboardState ---
Widget _buildInspirationCard() {
  final List<String> quotes = [
    "You don't have to be great to start, but you have to start to be great.",
    "Success is not final, failure is not fatal: it is the courage to continue.",
    "The only way to do great work is to love what you do.",
    "Believe you can and you're halfway there.",
    "Don't watch the clock; do what it does. Keep going.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "It always seems impossible until it is done.",
    "Your limitation--it's only your imagination.",
    "Great things never come from comfort zones.",
    "Dream big and dare to fail.",
    "Excellence is not a destination; it is a continuous journey.",
    "Every expert was once a beginner.",
    "Success is 1% inspiration and 99% perspiration.",
    "The key to success is to focus on goals, not obstacles.",
    "Your education is a dress rehearsal for a life that is yours to lead.",
  ];
  final randomQuote = quotes[DateTime.now().microsecond % quotes.length];
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AdminTheme.primaryColor.withValues(alpha: 0.9),
          AdminTheme.primaryColor.withValues(alpha: 0.95),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AdminTheme.primaryLight.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: AdminTheme.blueShadow,
    ),
    child: Column(
      children: [
        const Icon(Icons.auto_awesome, color: AdminTheme.warningColor, size: 20),
        const SizedBox(height: 8),
        Text(
          "\"$randomQuote\"",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

  // 1. Define this function inside your _StudentDashboardState class
  Future<void> _logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Navigate back to Login and remove all previous screens from the stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    debugPrint("Logout Error: $e");
  }
}

  // Password Change Method
  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showOldPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: !showOldPassword,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showOldPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showOldPassword = !showOldPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: "New Password (min 6 chars)",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showNewPassword = !showNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                    ),
                  ),
                ),
      ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final old = oldPasswordController.text.trim();
                final newPwd = newPasswordController.text.trim();
                final confirm = confirmPasswordController.text.trim();

                if (old.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                if (newPwd.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New password must be at least 6 characters")),
                  );
                  return;
                }

                if (newPwd != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null || user.email == null) throw Exception("User not logged in");

                  // Reauthenticate
                  await user.reauthenticateWithCredential(
                    EmailAuthProvider.credential(email: user.email!, password: old),
                  );

                  // Update password
                  await user.updatePassword(newPwd);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password changed successfully")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString().contains('wrong-password') ? 'Incorrect current password' : 'Failed to change password'}")),
                  );
                }
              },
              child: const Text("Change"),
            ),
          ],
        ),
      ),
    );
  }

  int _sum(Map<String, dynamic> d, Map<String, int> l) {
    int t = 0;
    l.forEach((k, _) {
      var val = d[k] ?? 0;
      t += (val is int) ? val : (val as num).toInt();
    });
    return t;
  }

  @override
  
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapAll) {
        if (!snapAll.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        

        // --- 1. DECLARE ALL VARIABLES FIRST ---
        double topperS1to2 = 0;
        double topperS1to3 = 0;
        double topperS1to4 = 0;
        double topperS1to5 = 0;
        double topperGrand = 0;
        Map<String, dynamic>? myData;

        // --- 2. CALCULATE TOPPERS ---
        for (var doc in snapAll.data!.docs) {
          var sd = doc.data() as Map<String, dynamic>;
          if (doc.id == widget.uid) myData = sd;

          int curS2 = _sum(sd, sem2Limits);
          int curS3 = _sum(sd, sem3Limits);
          int curS4 = _sum(sd, sem4Limits);
          int curS5 = _sum(sd, sem5Limits);
          int curS6 = _sum(sd, sem6Limits);

          if (curS2 > topperS1to2) topperS1to2 = curS2.toDouble();
          if ((curS2 + curS3) > topperS1to3) topperS1to3 = (curS2 + curS3).toDouble();
          if ((curS2 + curS3 + curS4) > topperS1to4) topperS1to4 = (curS2 + curS3 + curS4).toDouble();
          if ((curS2 + curS3 + curS4 + curS5) > topperS1to5) topperS1to5 = (curS2 + curS3 + curS4 + curS5).toDouble();
          double total = (curS2 + curS3 + curS4 + curS5 + curS6).toDouble();
          if (total > topperGrand) topperGrand = total;
        }

        if (myData == null) return const Scaffold(body: Center(child: Text("User not found")));

        // --- 3. DECLARE LOGIC VARIABLES ---
        String headerTitle = "";
        double currentRef = 0;
        int studentScore = 0;
        int semesterOnlyPoints = 0;
        Map<String, double> roleThresholds = {};
        Map<String, int> activeBreakdownLimits = {};

        int s2 = _sum(myData, sem2Limits);
        int s3 = _sum(myData, sem3Limits);
        int s4 = _sum(myData, sem4Limits);
        int s5 = _sum(myData, sem5Limits);
        int s6 = _sum(myData, sem6Limits);

        // --- 4. ASSIGN LOGIC BASED ON TAB ---
        if (viewYear == "1st Year") {
          headerTitle = "II-III SEM EP ROLES";
          currentRef = topperS1to2;
          studentScore = s2;
          semesterOnlyPoints = s2;
          activeBreakdownLimits = sem2Limits;
          roleThresholds = {
            'Class Representative': 0.4,
            'CoE Student Volunteer': 0.4,
            'Event Lead (II Year)': 0.4,
            'Doc & Report Lead': 0.4,
            'Digital Media Lead': 0.4,
            'Alumni Relations Coord': 0.4,
            'Coding Club Secretary': 0.6,
            'Placement Coordinator(Training)': 0.6,
            'Department Library Coordinator': 0.4,
          };
        } else if (viewYear == "2nd Year") {
          headerTitle = "III-IV SEM EP ROLES";
          currentRef = topperS1to3;
          studentScore = s2 + s3;
          semesterOnlyPoints = s3;
          activeBreakdownLimits = sem3Limits;
          roleThresholds = {
            'Class Representative': 0.4,
            'IV Coordinator': 0.6,
            'CoE Student Volunteer': 0.6,
            'Placement Coordinator': 0.6,
            'Digital Media Lead': 0.6,
            'Library Coordinator': 0.4,
            'Event Lead': 0.6,
            'Alumni Relations Coordinator': 0.4,
            'Documentation Lead': 0.4,
            'Coding Club Secretary': 0.6,
          };
        } else if (viewYear == "3rd Year") {
          headerTitle = "IV-V SEM EP ROLES";
          currentRef = topperS1to4;
          studentScore = s2 + s3 + s4;
          semesterOnlyPoints = s4;
          activeBreakdownLimits = sem4Limits;
          roleThresholds = {
            'Class Representative': 0.4,
            'CoE Student Incharger': 0.6,
            'Coding Club Secretary': 0.6,
            'IEI / IIC / IETE Secretary': 0.8,
            'iEI/IIC/IETE Treasurer': 0.6,
            'Office Bearers': 0.4,
            'IV Coordinator':0.6,
            'Library Coordinator': 0.6,
            'Placement Coordinator': 0.6,
            'Alumini Relations Coordinator':0.4,
            'documentation & report lead':0.4,
            'Digital Media Lead':0.4
          };
        } else if (viewYear == "4th Year") {
          headerTitle = "VI-VII SEM EP ROLES";
          currentRef = topperS1to5;
          studentScore = s2 + s3 + s4 + s5;
          semesterOnlyPoints = s5;
          activeBreakdownLimits = sem5Limits;
          roleThresholds = {
            'Placement Coordinator': 0.7,
            'Chief Student Coordinator': 0.8,
            'Hackathon Secretary': 0.8,
            'Hackathon Treasurer': 0.6,
            'CoE Student Lead': 0.7,
            'Senior Student Mentor Lead ': 0.6,
            'Dept Documentation Lead': 0.5,
            'Digital Media Lead': 0.5,
            'EP Coordinator': 0.6
          };
        } else {
          headerTitle = "VII SEM EP ROLES";
          currentRef = topperGrand;
          studentScore = s2 + s3 + s4 + s5 + s6;
          semesterOnlyPoints = s6;
          activeBreakdownLimits = sem6Limits;
          roleThresholds = {
            'Chief Placement Coordinator': 0.8,
            'Placement Coordinator': 0.7,
          };
        }
        // --- LOCATE THIS IN YOUR BUILD METHOD ---


        return Scaffold(
 appBar: AppBar(
  title: const Text(
    "\u{1F44B} Welcome! \u{1F393}",
    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
  ),
  backgroundColor: AdminTheme.primaryColor,
  foregroundColor: const Color(0xFFF3E8F1),
  elevation: 2,
  actions: [
    IconButton(
      icon: const Icon(Icons.lock),
      onPressed: _changePassword,
      tooltip: 'Change Password',
    ),
    IconButton(
      icon: const Icon(Icons.logout, color: Color(0xFFF3E8F1), size: 24),
      onPressed: _logout,
      tooltip: 'Logout',
    ),
  ],
),

          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStudentProfileCard(myData, studentScore),
              const SizedBox(height: 25),
              
              _buildInspirationCard(), 
    
              const SizedBox(height: 25),
              
              _buildYearSelector(),
              const SizedBox(height: 25),
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.neutralDark,
                  letterSpacing: 0.3,
                ),
              ),
              Text("Benchmark (100%): ${currentRef.toInt()} EP", style: const TextStyle(color: AdminTheme.secondaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
              const Divider(),

              // Progress towards toppper
              _buildProgressSection(studentScore, currentRef),
              const SizedBox(height: 20),
              
              ...roleThresholds.entries.map((role) {
                double target = currentRef * role.value;
                bool isEligible = studentScore >= target;
                double gap = target - studentScore;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: isEligible
                      ? AdminTheme.successColor.withValues(alpha: 0.06)
                      : AdminTheme.dangerColor.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isEligible
                          ? AdminTheme.successColor.withValues(alpha: 0.3)
                          : AdminTheme.dangerColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isEligible
                            ? AdminTheme.successColor.withValues(alpha: 0.15)
                            : AdminTheme.dangerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEligible ? Icons.verified : Icons.lock_outline,
                        color: isEligible ? AdminTheme.successColor : AdminTheme.dangerColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      role.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1F2937),
                        letterSpacing: 0.2,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          "${(role.value * 100).toInt()}% of Benchmark -> ${target.toStringAsFixed(1)} EP",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AdminTheme.neutralDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!isEligible)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "? ${gap.toStringAsFixed(1)} EP to go",
                              style: const TextStyle(
                                color: AdminTheme.dangerColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? AdminTheme.successColor.withValues(alpha: 0.1)
                            : AdminTheme.dangerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isEligible ? "Eligible" : "Locked",
                        style: TextStyle(
                          color: isEligible ? AdminTheme.successColor : AdminTheme.dangerColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),
              Text(
                viewYear == "1st Year" ? "FIRST YEAR (SEM 1-2) ACTIVITY BREAKDOWN" :
                viewYear == "2nd Year" ? "SECOND YEAR (SEM 3) ACTIVITY BREAKDOWN" :
                viewYear == "3rd Year" ? "THIRD YEAR (SEM 4) ACTIVITY BREAKDOWN" :
                viewYear == "4th Year" ? "THIRD YEAR (SEM 5)ACTIVITY BREAKDOWN" :
                "FINAL YEAR (SEM 6)ACTIVITY BREAKDOWN",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              ...activeBreakdownLimits.entries.map((e) {
                int current = myData![e.key] ?? 0;
                int limit = e.value;
                double progress = (current / limit).clamp(0.0, 1.0);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${current >= limit ? '\u{2705}' : '\u{1F538}'} ${e.key.replaceAll('_', ' ').toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AdminTheme.neutralDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "$current / $limit",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: current >= limit ? AdminTheme.successColor : AdminTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AdminTheme.borderColor.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation(
                            current >= limit ? AdminTheme.successColor : AdminTheme.primaryLight
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AdminTheme.primaryLight.withValues(alpha: 0.08),
                      AdminTheme.primaryColor.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: AdminTheme.borderColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "\u{1F4CA} TOTAL SEMESTER EP:",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AdminTheme.neutralDark,
                      ),
                    ),
                    Text(
                      "$semesterOnlyPoints",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AdminTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildPointBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AdminTheme.blueShadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC7D2FE),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Progress section with visual engagement
  Widget _buildProgressSection(int currentScore, double topperScore) {
    double progressPercent = (currentScore / topperScore).clamp(0.0, 1.0);
    String progressEmoji = '';
    String motivationalMsg = '';
    
    if (progressPercent >= 1.0) {
      progressEmoji = '\u{1F3C6}';
      motivationalMsg = 'You\'re a TOPPER! Keep it up!';
    } else if (progressPercent >= 0.8) {
      progressEmoji = '\u{1F525}';
      motivationalMsg = 'Almost there! You\'re doing amazing! \u{1F525}';
    } else if (progressPercent >= 0.6) {
      progressEmoji = '\u{1F680}';
      motivationalMsg = 'Great progress! Keep pushing! \u{1F680}';
    } else if (progressPercent >= 0.4) {
      progressEmoji = '✓';
      motivationalMsg = 'You\'re on track! Keep going! ';
    } else {
      progressEmoji = '\u{1F331}';
      motivationalMsg = 'Every point counts! Start strong!';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.primaryAccent.withValues(alpha: 0.08),
        border: Border.all(
          color: AdminTheme.primaryLight.withValues(alpha: 0.2),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to Benchmark',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.primaryColor,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                progressEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: AdminTheme.primaryAccent.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                progressPercent >= 0.8 ? AdminTheme.successColor : 
                progressPercent >= 0.6 ? AdminTheme.primaryLight : 
                AdminTheme.warningColor
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progressPercent * 100).toStringAsFixed(0)}% - $currentScore / ${topperScore.toInt()} EP',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AdminTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            motivationalMsg,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AdminTheme.neutralDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  


  Widget _buildYearSelector() {
    final semesters = [
      {"value": "1st Year", "label": "SEM 2-3", "year": "\u{1F9ED} Year 1"},
      {"value": "2nd Year", "label": "SEM 3-4", "year": "\u{1F4DA} Year 2"},
      {"value": "3rd Year", "label": "SEM 4-5", "year": "\u{1F680} Year 3"},
      {"value": "4th Year", "label": "SEM 6-7", "year": "\u{1F393} Final-1"},
      {"value": "Final Year", "label": "SEM 7", "year": "\u{1F3AF} Final"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "Select Semester",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminTheme.neutralDark,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: semesters.map((sem) {
              final isSelected = viewYear == sem["value"];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() => viewYear = sem["value"] as String);
                  },
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AdminTheme.primaryLight,
                                AdminTheme.primaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AdminTheme.primaryColor
                            : AdminTheme.borderColor.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AdminTheme.primaryColor.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => viewYear = sem["value"] as String);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sem["label"] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AdminTheme.primaryColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                sem["year"] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AdminTheme.neutralDark.withValues(alpha: 0.6),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 6),
                                Container(
                                  width: 24,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// --- ADMIN DASHBOARD //---

 class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String filterYear = "SIXTH SEMESTER";
  bool showTable = false;
  String currentViewMode = "admin";
  String selectedBatch = "25";

  // ------------------------------------------------------------
  // Add Batch Dialog
  // ------------------------------------------------------------
  // ------------------------------------------------------------
  // Upload Students from CSV
  // ------------------------------------------------------------
  Future<void> _uploadStudentsFromCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes!;
      final csvStr = utf8.decode(bytes);
      final rows = const CsvToListConverter().convert(csvStr, eol: '\n');
      if (rows.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CSV has no data rows.")),
        );
        return;
      }
      final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final dataRows = rows.skip(1).where((r) => r.length >= headers.length).toList();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirm Upload"),
          content: Text(
            "Found ${dataRows.length} students.\n"
            "They will be added to Batch $selectedBatch.\n\n"
            "Columns detected: ${headers.join(', ')}",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Upload")),
          ],
        ),
      );
      if (confirmed != true) return;
      final firestoreBatch = FirebaseFirestore.instance.batch();
      int count = 0;
      for (final row in dataRows) {
        final Map<String, String> rowMap = {};
        for (int i = 0; i < headers.length; i++) {
          rowMap[headers[i]] = row[i].toString().trim();
        }
        final regNo = rowMap['regno'] ?? rowMap['reg no'] ?? rowMap['reg_no'] ?? '';
        final name = rowMap['name'] ?? '';
        final section = rowMap['section'] ?? 'Sec 1';
        if (regNo.isEmpty || name.isEmpty) continue;
        final docRef = FirebaseFirestore.instance.collection('users').doc();
        firestoreBatch.set(docRef, {
          'regNo': regNo,
          'name': name,
          'section': section,
          'batch': selectedBatch,
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;
      }
      await firestoreBatch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$count students uploaded to Batch $selectedBatch ?")),
      );
    } catch (e) {
      await ErrorLogger.logError(
        errorName: 'CSVUploadError',
        message: e.toString(),
        location: 'AdminDashboard._uploadStudentsFromCSV()',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showCreateUserDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    String selectedRole = 'staff';
    final TextEditingController batchController = TextEditingController();
    final TextEditingController sectionController = TextEditingController();
    bool _isCreating = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Create New User Account"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email Field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "user@example.com",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Name Field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    hintText: "John Doe",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Role Dropdown
                DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  items: ['staff', 'admin', 'student'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'staff');
                  },
                ),
                const SizedBox(height: 12),

                // Batch Field (for staff and students)
                if (selectedRole == 'student' || selectedRole == 'staff')
                  TextField(
                    controller: batchController,
                    decoration: InputDecoration(
                      labelText: "Batch",
                      hintText: "25",
                      border: const OutlineInputBorder(),
                      helperText: selectedRole == 'staff' ? "This staff will see only this batch's students" : null,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                if (selectedRole == 'student' || selectedRole == 'staff') const SizedBox(height: 12),

                // Section Field (for students only)
                if (selectedRole == 'student')
                  TextField(
                    controller: sectionController,
                    decoration: const InputDecoration(
                      labelText: "Section",
                      hintText: "A",
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (selectedRole == 'student') const SizedBox(height: 12),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Temporary Password",
                    hintText: "Min. 6 characters",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Info text
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "After account creation, share the email and password with the user. They should change the password on first login.",
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
      ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isCreating ? null : () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _isCreating
                  ? null
                  : () async {
                      if (emailController.text.isEmpty || 
                          nameController.text.isEmpty || 
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fill in all required fields")),
                        );
                        return;
                      }

                      setState(() => _isCreating = true);

                      try {
                        // Call Cloud Function
                        final response = await http.post(
                          Uri.parse('https://us-central1-cit-dept-dashboard.cloudfunctions.net/createUser'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': emailController.text.toLowerCase(),
                            'password': passwordController.text,
                            'name': nameController.text,
                            'role': selectedRole,
                            if (selectedRole == 'student' || selectedRole == 'staff') 'batch': batchController.text,
                            if (selectedRole == 'student') 'section': sectionController.text,
                          }),
                        );

                        if (!mounted) return;

                        if (response.statusCode == 201 || response.statusCode == 200) {
                          final result = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? 'User created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          final error = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: ${error['error'] ?? 'Failed to create user'}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Network error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isCreating = false);
                      }
                    },
              child: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create User"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBatchDialog() {
    TextEditingController batchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminTheme.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.library_add_outlined,
                color: AdminTheme.primaryLight,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create New Batch",
              style: TextStyle(
                color: AdminTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: batchController,
          decoration: InputDecoration(
            hintText: "Enter Batch Code (e.g., 29)",
            prefixIcon: const Icon(Icons.layers, color: AdminTheme.primaryLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminTheme.primaryLight, width: 2),
            ),
            filled: true,
            fillColor: AdminTheme.neutralLight,
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AdminTheme.neutralDark),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primaryLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 4,
            ),
            onPressed: () async {
              if (batchController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('batches').add({
                  'code': batchController.text,
                  'name': "Batch ${batchController.text}",
                  'active': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("? Batch Created Successfully"),
                    backgroundColor: AdminTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text(
              "Create",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Password Change
  // ------------------------------------------------------------
  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showOldPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: !showOldPassword,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showOldPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showOldPassword = !showOldPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: "New Password (min 6 chars)",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showNewPassword = !showNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                    ),
                  ),
                ),
      ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final old = oldPasswordController.text.trim();
                final newPwd = newPasswordController.text.trim();
                final confirm = confirmPasswordController.text.trim();

                if (old.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                if (newPwd.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New password must be at least 6 characters")),
                  );
                  return;
                }

                if (newPwd != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null || user.email == null) throw Exception("User not logged in");

                  // Reauthenticate
                  await user.reauthenticateWithCredential(
                    EmailAuthProvider.credential(email: user.email!, password: old),
                  );

                  // Update password
                  await user.updatePassword(newPwd);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password changed successfully")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString().contains('wrong-password') ? 'Incorrect current password' : 'Failed to change password'}")),
                  );
                }
              },
              child: const Text("Change"),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Create User (Staff/Admin) via Cloud Function
  // ------------------------------------------------------------


  // ignore: unused_element
  void _exportToCSV(List<Map<String, dynamic>> students) {
    List<List<dynamic>> rows = [];
    rows.add(["Register No", "Name", "Section", "Batch", "Total EP"]);
    for (var s in students) {
      rows.add([s['regNo'], s['name'], s['section'], selectedBatch, s['score']]);
    }
    const ListToCsvConverter().convert(rows);
    
    if (kIsWeb) {
      // Web-only CSV download (requires web context)
      // This code only runs in web builds
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CSV export available on web platform"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CSV export is available on web only"))
      );
    }
  }

  // ignore: unused_element
  Future<void> _exportSectionToCSV(String section, List<Map<String, dynamic>> students) async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No students in $section to export")),
      );
      return;
    }
    
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV export available on web only")),
      );
      return;
    }
    
    try {
      List<List<dynamic>> rows = [];
      rows.add(["Register No", "Name", "Section", "Batch", "Total EP"]);
      for (var s in students) {
        rows.add([
          s['regNo'] ?? 'N/A',
          s['name'] ?? 'N/A',
          s['section'] ?? 'N/A',
          selectedBatch,
          s['score'] ?? 0
        ]);
      }
      String csvData = const ListToCsvConverter().convert(rows);
      
      String timestamp = DateTime.now().toString().split('.')[0].replaceAll(':', '-');
      String fileName = "${filterYear}_${section}_${timestamp}.csv";
      
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("CSV prepared: $fileName")),
        );
      } else {
        // Mobile: Save to documents directory
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(csvData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✓ Saved: $fileName")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving file: $e")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Export failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateCumulativePoints(Map<String, dynamic> d, String filter) {
    int s2 = _sum(d, sem2Limits);
    int s3 = _sum(d, sem3Limits);
    int s4 = _sum(d, sem4Limits);
    int s5 = _sum(d, sem5Limits);
    int s6 = _sum(d, sem6Limits);
    if (filter == "First Year") return s2;
    if (filter == "THIRD SEMESTER") return s2 + s3;
    if (filter == "FOURTH SEMESTER") return s2 + s3 + s4;
    if (filter == "FIFTH SEMESTER") return s2 + s3 + s4 + s5;
    return s2 + s3 + s4 + s5 + s6;
  }

  int _sum(Map<String, dynamic> d, Map<String, int> l) {
    int t = 0;
    l.forEach((k, _) {
      var val = d[k] ?? 0;
      t += (val is int) ? val : (val as num).toInt();
    });
    return t;
  }

 
  Widget _buildBatchSelector() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('batches')
          .where('active', isEqualTo: true)
         
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final batches = snapshot.data!.docs;
        if (batches.isEmpty) {
          return const Text(
            "No batches yet. Use the + button to create one.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }
        // Sort batches by code in ascending numeric order
        final sortedBatches = List.from(batches)
          ..sort((a, b) {
            final codeA = int.tryParse(a['code']?.toString() ?? '0') ?? 0;
            final codeB = int.tryParse(b['code']?.toString() ?? '0') ?? 0;
            return codeA.compareTo(codeB);
          });
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sortedBatches.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final code = data['code']?.toString() ?? doc.id;
              final label = data['name']?.toString() ?? "Batch $code";
              final isSelected = selectedBatch == code;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => selectedBatch = code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade900 : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }



  // ------------------------------------------------------------
  // ? TEMPORARY: Attach Batch to Existing Students
  //   REMOVE this method + button after running once
  // ------------------------------------------------------------
  Future<void> _attachBatchToStudents() async {
    final TextEditingController batchInput =
        TextEditingController(text: selectedBatch);

    final confirmedBatch = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Assign Batch to Existing Students"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This will add the 'batch' field to all student documents "
              "that don't have one yet.\n\n"
              "Enter the batch code to assign:",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: batchInput,
              decoration: const InputDecoration(
                labelText: "Batch Code",
                hintText: "e.g. 26",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
            onPressed: () => Navigator.pop(ctx, batchInput.text.trim()),
            child: const Text("Assign"),
          ),
        ],
      ),
    );

    if (confirmedBatch == null || confirmedBatch.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Batch Assignment"),
        content: Text(
          "All students WITHOUT a batch field will be assigned:\n\n"
          "Batch: $confirmedBatch\n\n"
          "Students who already have a batch will be skipped safely.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Assign"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Assigning batch..."),
          ],
        ),
      ),
    );

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      int assigned = 0;
      int skipped = 0;

      List<QueryDocumentSnapshot> docs = snapshot.docs;
      for (int i = 0; i < docs.length; i += 400) {
        final batchGroup = docs.sublist(
          i,
          i + 400 > docs.length ? docs.length : i + 400,
        );
        final firestoreBatch = FirebaseFirestore.instance.batch();
        for (var doc in batchGroup) {
          final data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('batch') ||
              data['batch'] == null ||
              data['batch'].toString().isEmpty) {
            firestoreBatch.update(doc.reference, {'batch': confirmedBatch});
            assigned++;
          } else {
            skipped++;
          }
        }
        await firestoreBatch.commit();
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$assigned students assigned to Batch $confirmedBatch. "
            "$skipped already had a batch (skipped).",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ------------------------------------------------------------
  // ? MIGRATE BATCH 26 ? 25 (FIX UPLOADED MISTAKE)
  // ------------------------------------------------------------
  // ignore: unused_element
  Future<void> _migrateBatchStudents() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("?? Migrate Batch 26 ? 25"),
        content: const Text(
          "This will move ALL students from Batch 26 to Batch 25.\n\n"
          "This action cannot be easily undone.\n\n"
          "Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Migrate"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Migrating batch 26 ? 25..."),
          ],
        ),
      ),
    );

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('batch', isEqualTo: '26')
          .get();

      int migrated = 0;

      List<QueryDocumentSnapshot> docs = snapshot.docs;
      for (int i = 0; i < docs.length; i += 400) {
        final batchGroup = docs.sublist(
          i,
          i + 400 > docs.length ? docs.length : i + 400,
        );
        final firestoreBatch = FirebaseFirestore.instance.batch();
        for (var doc in batchGroup) {
          firestoreBatch.update(doc.reference, {'batch': '25'});
          migrated++;
        }
        await firestoreBatch.commit();
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "? Successfully migrated $migrated students from Batch 26 to Batch 25",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Migration failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // build()
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (currentViewMode == "staff") return _impersonate(const StaffDashboard());
    if (currentViewMode == "student") {}

    double maxPoints = filterYear == "First Year" ? 40
        : filterYear == "THIRD SEMESTER" ? 80
        : filterYear == "FOURTH SEMESTER" ? 120
        : filterYear == "FIFTH SEMESTER" ? 160 : 200;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        String s1TopperName = "N/A", s2TopperName = "N/A";
        int s1TopperScore = -1, s2TopperScore = -1;
        List<Map<String, dynamic>> students = [];
        double batchHighest = 0;
        String? firstStudentId;

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          int score = _calculateCumulativePoints(data, filterYear);
          if (score > batchHighest) batchHighest = score.toDouble();
          if (firstStudentId == null) firstStudentId = doc.id;
          var studentInfo = {
            'name': data['name'] ?? "Unknown",
            'regNo': data['regNo'] ?? "N/A",
            'score': score,
            'section': data['section'] ?? "Sec 1",
          };
          students.add(studentInfo);
          if (studentInfo['section'] == "Sec 1") {
            if (score > s1TopperScore) { s1TopperScore = score; s1TopperName = studentInfo['name'] as String; }
          } else {
            if (score > s2TopperScore) { s2TopperScore = score; s2TopperName = studentInfo['name'] as String; }
          }
        }

        if (currentViewMode == "student") {
          return _impersonate(StudentDashboard(uid: firstStudentId ?? "sample_uid"));
        }

        // Calculate section averages using correct formula
        // Section Average (μ) = Σ(Individual Student EP) / Total Students in Section
        double s1Sum = 0, s2Sum = 0;
        int s1Count = 0, s2Count = 0;
        
        for (var student in students) {
          if (student['section'] == "Sec 1") {
            s1Sum += student['score'];
            s1Count++;
          } else {
            s2Sum += student['score'];
            s2Count++;
          }
        }
        
        // Calculate mean for each section (μ)
        double s1Avg = s1Count > 0 ? s1Sum / s1Count : 0;
        double s2Avg = s2Count > 0 ? s2Sum / s2Count : 0;
        
        // Calculate achievement percentage: Achievement % = (μ / P_max) × 100
        double s1Achievement = (s1Avg / maxPoints) * 100;
        double s2Achievement = (s2Avg / maxPoints) * 100;
        
        String leadingSection = s1Achievement > s2Achievement ? "SECTION 1" : "SECTION 2";
        double winPercent = s1Achievement > s2Achievement ? s1Achievement : s2Achievement;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: GoogleFonts.poppins(
                      color: AdminTheme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "ADMIN",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add, color: AdminTheme.primaryLight),
                tooltip: "Create User",
                onPressed: _showCreateUserDialog,
                iconSize: 24,
              ),
              IconButton(
                icon: const Icon(Icons.lock, color: AdminTheme.primaryLight),
                onPressed: _changePassword,
                tooltip: 'Change Password',
                iconSize: 24,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_tree_outlined, color: AdminTheme.primaryLight),
                onSelected: (v) => setState(() => currentViewMode = v),
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: "admin", child: Text("Admin View", style: GoogleFonts.inter())),
                  PopupMenuItem(value: "staff", child: Text("Staff View", style: GoogleFonts.inter())),
                  PopupMenuItem(value: "student", child: Text("Student View", style: GoogleFonts.inter())),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AdminTheme.primaryLight, size: 24),
                onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginPage())),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
            children: [

              // Leading Section Card - Glassmorphism Effect
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AdminTheme.primaryColor,
                      AdminTheme.primaryLight.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AdminTheme.blueShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LEADING: $leadingSection",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Avg Achievement: ${winPercent.toStringAsFixed(1)}%",
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Upload Students CSV Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _uploadStudentsFromCSV,
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: Text("UPLOAD STUDENTS (CSV)", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Batch Selector
              Text(
                "SELECT BATCH",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AdminTheme.neutralDark,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: _buildBatchSelector(),
              ),
              const SizedBox(height: 20),

              // Attach Batch Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _attachBatchToStudents,
                  icon: const Icon(Icons.label_outline, size: 20),
                  label: Text(
                    "ATTACH BATCH TO EXISTING",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Semester Selector
              Text(
                "SELECT SEMESTER",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AdminTheme.neutralDark,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AdminTheme.borderColor, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: filterYear,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ["First Year", "THIRD SEMESTER", "FOURTH SEMESTER", "FIFTH SEMESTER", "SIXTH SEMESTER"]
                      .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text(
                          y,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ))
                      .toList(),
                  onChanged: (v) => setState(() { filterYear = v!; showTable = false; }),
                ),
              ),
              const SizedBox(height: 28),

              // Section Toppers Header
              Text(
                "SECTION TOPPERS",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AdminTheme.neutralDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _performerCard("SEC 1 TOPPER", s1TopperName, s1TopperScore)),
                const SizedBox(width: 14),
                Expanded(child: _performerCard("SEC 2 TOPPER", s2TopperName, s2TopperScore)),
              ]),
              const SizedBox(height: 32),

              // Achievement Chart Header
              Text(
                "SECTION ACHIEVEMENT RATIO (%)",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AdminTheme.neutralDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildBarChart(s1Avg, s2Avg, maxPoints),
              const SizedBox(height: 28),
              
              // Overall Section Performance
              _buildSectionPerformanceComparison(s1Avg, s2Avg),
              const SizedBox(height: 32),

              // Static Add Batch button (was floating)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddBatchDialog,
                  icon: const Icon(Icons.add_box, size: 20),
                  label: Text(
                    "Add Batch",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Verification Table Button - Navigate to Full Page
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerificationStatsPage(
                        selectedBatch: selectedBatch,
                        filterYear: filterYear,
                        students: students,
                        batchHighest: batchHighest,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.analytics, size: 20),
                  label: Text(
                    "GENERATE VERIFICATION TABLE",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UI Component helpers � ALL UNCHANGED
  // ------------------------------------------------------------

  // ------------------------------------------------------------
  // Modern Stats Card Helper
  // ------------------------------------------------------------
  // ignore: unused_element
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impersonate(Widget child) => Stack(
        children: [
          child,
          Positioned(
            bottom: 20, right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => currentViewMode = "admin"),
              label: const Text("Exit Preview"),
              icon: const Icon(Icons.admin_panel_settings),
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      );

  Widget _buildBarChart(double s1, double s2, double max) => SizedBox(
        height: 280,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AdminTheme.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AdminTheme.primaryColor.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Analytics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AdminTheme.neutralDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AdminTheme.successColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Data',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminTheme.successColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AdminTheme.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AdminTheme.primaryLight.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.trending_up, size: 14, color: AdminTheme.primaryLight),
                                const SizedBox(width: 6),
                                Text(
                                  'This Batch',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AdminTheme.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: max == 0 ? 100 : max,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AdminTheme.borderColor.withOpacity(0.6),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: s1 == 0 ? 0 : s1,
                            color: AdminTheme.primaryLight,
                            width: 40,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: max == 0 ? 100 : max,
                              color: AdminTheme.primaryLight.withOpacity(0.08),
                            ),
                          )
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: s2 == 0 ? 0 : s2,
                            color: AdminTheme.secondaryColor,
                            width: 40,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: max == 0 ? 100 : max,
                              color: AdminTheme.secondaryColor.withOpacity(0.08),
                            ),
                          )
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final style = TextStyle(
                              color: AdminTheme.neutralDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'Section 1';
                                break;
                              case 1:
                                text = 'Section 2';
                                break;
                              default:
                                text = '';
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: AdminTheme.neutralDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 12,
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        tooltipMargin: 12,
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          final sectionName =
                              groupIndex == 0 ? 'Section 1' : 'Section 2';
                          return BarTooltipItem(
                            '$sectionName\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '${rod.toY.toStringAsFixed(0)} Points',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: AdminTheme.primaryLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Section 1',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: AdminTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Section 2',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.neutralDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildSectionPerformanceComparison(double s1Avg, double s2Avg) {
    bool section1Better = s1Avg > s2Avg;
    double difference = (s1Avg - s2Avg).abs();
    String betterSection = section1Better ? "Section 1" : "Section 2";
    Color winnerColor = section1Better ? AdminTheme.primaryLight : AdminTheme.secondaryColor;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            winnerColor.withOpacity(0.08),
            winnerColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: winnerColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: winnerColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "OVERALL PERFORMANCE",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AdminTheme.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Icon(Icons.emoji_events, color: winnerColor, size: 20),
                        Text(
                          betterSection,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: winnerColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          "LEADING",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: winnerColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.topRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: winnerColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: winnerColor.withOpacity(0.4), width: 1.2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "+${difference.toStringAsFixed(1)}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: winnerColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            "Points Ahead",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: winnerColor.withOpacity(0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.primaryLight.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Section 1",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.primaryLight,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${s1Avg.toStringAsFixed(1)}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AdminTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.secondaryColor.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Section 2",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.secondaryColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${s2Avg.toStringAsFixed(1)}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AdminTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSectionTable(String title, List<Map<String, dynamic>> data, double topper, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          color: color,
                          fontSize: 18,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.length} students',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          'View Stats',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.borderColor, width: 1.2),
            boxShadow: AdminTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 40,
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(color.withOpacity(0.06)),
                  headingRowHeight: 56,
                  dataRowHeight: 76,
                  dataRowColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return color.withOpacity(0.05);
                    }
                    return Colors.transparent;
                  }),
                  headingTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  columns: const [
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text('Student', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                    DataColumn(label: Text('Register No', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                    DataColumn(label: Text('Points', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                  ],
                  rows: data.map((s) {
                    final name = (s['name'] ?? 'Unknown') as String;
                    final reg = s['regNo'] ?? 'N/A';
                    final section = s['section'] ?? '1';
                    final score = (s['score'] ?? 0) as num;
                    return DataRow(cells: [
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: color.withOpacity(0.12),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(color: color, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AdminTheme.neutralDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sec $section',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                      DataCell(Text(
                        reg,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.neutralDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${score.toInt()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: color,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ]);

  Widget _performerCard(String title, String name, int score) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminTheme.primaryLight.withOpacity(0.2), width: 1.5),
          boxShadow: AdminTheme.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AdminTheme.primaryLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminTheme.primaryLight.withOpacity(0.2), width: 1),
            ),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AdminTheme.primaryLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AdminTheme.neutralDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$score EP",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AdminTheme.primaryLight,
              letterSpacing: -0.5,
            ),
          ),
        ]),
      );
}
// --- STAFF DASHBOARD ---
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});
  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final _reg = TextEditingController();
  final _searchVerification = TextEditingController();
  // Renamed default to match your new request
  String activeYear = "First Year"; 
  final Map<String, TextEditingController> _ctrls = {};
  bool _isSaving = false;
  String sortBy = 'name'; // 'name', 'score', or 'percentage'
  bool sortAscending = true;
  
  // NEW: Staff batch assignment
  String? _staffBatch;
  bool _batchLoaded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadStaffBatch();
  }

  // NEW: Load staff's assigned batch from Firestore
  Future<void> _loadStaffBatch() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return;
      
      // Query by email instead of UID
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        final batch = query.docs.first['batch'];
        debugPrint("DEBUG: Loaded batch from Firestore: $batch (type: ${batch.runtimeType})");
        setState(() {
          _staffBatch = batch?.toString();
          debugPrint("DEBUG: _staffBatch set to: $_staffBatch");
          _batchLoaded = true;
        });
      } else {
        debugPrint("DEBUG: Staff document not found with email: ${user.email}");
        setState(() => _batchLoaded = true);
      }
    } catch (e) {
      debugPrint("Error loading staff batch: $e");
      setState(() => _batchLoaded = true);
    }
  }

  // Password Change Method
  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showOldPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: !showOldPassword,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showOldPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showOldPassword = !showOldPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  decoration: InputDecoration(
                    labelText: "New Password (min 6 chars)",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showNewPassword = !showNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                    ),
                  ),
                ),
      ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final old = oldPasswordController.text.trim();
                final newPwd = newPasswordController.text.trim();
                final confirm = confirmPasswordController.text.trim();

                if (old.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                if (newPwd.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New password must be at least 6 characters")),
                  );
                  return;
                }

                if (newPwd != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null || user.email == null) throw Exception("User not logged in");

                  // Reauthenticate
                  await user.reauthenticateWithCredential(
                    EmailAuthProvider.credential(email: user.email!, password: old),
                  );

                  // Update password
                  await user.updatePassword(newPwd);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password changed successfully")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString().contains('wrong-password') ? 'Incorrect current password' : 'Failed to change password'}")),
                  );
                }
              },
              child: const Text("Change"),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. DYNAMIC LIMITS & WRITE ACCESS ---
  // Maps the new Semester Labels to the correct Point Limit Maps
  Map<String, int> _getLimits() {
    switch (activeYear) {
      case "First Year": return sem2Limits;
      case "THIRD SEMESTER": return sem3Limits;
      case "FOURTH SEMESTER": return sem4Limits;
      case "FIFTH SEMESTER": return sem5Limits;
      case "SIXTH SEMESTER": return sem6Limits;
      default: return sem2Limits;
    }
  }

  void _initControllers() {
    _ctrls.clear();
    _getLimits().forEach((k, _) => _ctrls[k] = TextEditingController());
  }

  // --- 2. CUMULATIVE CALCULATION LOGIC ---
  int _calculateCumulativePoints(Map<String, dynamic> d, String year) {
    int s2 = _sum(d, sem2Limits);
    int s3 = _sum(d, sem3Limits);
    int s4 = _sum(d, sem4Limits);
    int s5 = _sum(d, sem5Limits);
    int s6 = _sum(d, sem6Limits);

    if (year == "First Year") return s2;
    if (year == "THIRD SEMESTER") return s2 + s3;
    if (year == "FOURTH SEMESTER") return s2 + s3 + s4;
    if (year == "FIFTH SEMESTER") return s2 + s3 + s4 + s5;
    return s2 + s3 + s4 + s5 + s6; // SIXTH SEMESTER Milestone
  }

  int _sum(Map<String, dynamic> d, Map<String, int> l) {
    int t = 0;
    l.forEach((k, _) {
      var val = d[k] ?? 0;
      t += (val is int) ? val : (val as num).toInt();
    });
    return t;
  }

  // --- MARKS ENTRY SEARCH & UPDATE ---
  void _search() async {
    try {
      String searchQuery = _reg.text.trim();
      if (searchQuery.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Please enter a registration number or name")),
              ],
            ),
            backgroundColor: const Color(0xFF06B6D4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // First: Try searching by regNo
      var q = await FirebaseFirestore.instance
          .collection('users')
          .where('regNo', isEqualTo: searchQuery)
          .get();

      // If regNo not found, search by name (case-insensitive fallback)
      if (q.docs.isEmpty) {
        q = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThan: searchQuery + 'z')
            .get();
      }

      if (q.docs.isEmpty) {
        await ErrorLogger.logError(
          errorName: 'StudentNotFound',
          message: 'Search query: $searchQuery',
          location: 'StaffDashboard._search()',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.search_off, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text("Student not found")),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // If multiple matches found, show selection dialog
      if (q.docs.length > 1) {
        if (!mounted) return;
        final selected = await showDialog<DocumentSnapshot>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Multiple Students Found"),
            content: SizedBox(
              width: 300,
              child: ListView.builder(
                itemCount: q.docs.length,
                itemBuilder: (context, i) {
                  final data = q.docs[i].data();
                  final name = data['name'] ?? 'Unknown';
                  final regNo = data['regNo'] ?? 'N/A';
                  final batch = data['batch'] ?? 'N/A';
                  return ListTile(
                    title: Text(name),
                    subtitle: Text('RegNo: $regNo | Batch: $batch'),
                    onTap: () => Navigator.pop(context, q.docs[i]),
                  );
                },
              ),
            ),
          ),
        );
        if (selected == null) return;
        var data = selected.data() as Map<String, dynamic>?;
        if (data == null) return;
        
        // Check batch permission
        if (_staffBatch != null && data['batch']?.toString() != _staffBatch) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Student not in your batch (Batch $_staffBatch)")),
                  ],
                ),
                backgroundColor: const Color(0xFFFB923C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          return;
        }
        
        setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Student: ${data['name']}")),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        var data = q.docs.first.data() as Map<String, dynamic>?;
        if (data == null) return;
        
        // Check if student belongs to this staff's batch
        if (_staffBatch != null && data['batch']?.toString() != _staffBatch) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Student not in your batch (Batch $_staffBatch)")),
                  ],
                ),
                backgroundColor: const Color(0xFFFB923C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          return;
        }
        
        setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("${data['name'] ?? 'Student'} loaded")),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      await ErrorLogger.logError(
        errorName: 'SearchError',
        message: e.toString(),
        location: 'StaffDashboard._search()',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Search error: $e")),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _update() async {
    setState(() => _isSaving = true);
    try {
      Map<String, int> updates = {};
      Map<String, int> currentLimits = _getLimits();
      bool isInvalid = false;
      String errorField = "";

      _ctrls.forEach((k, v) {
        int val = int.tryParse(v.text) ?? 0;
        if (val > (currentLimits[k] ?? 0)) {
          isInvalid = true;
          errorField = k.toUpperCase();
        }
        updates[k] = val;
      });

      if (isInvalid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text("$errorField exceeds limit!")),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
      if (q.docs.isNotEmpty) {
        await q.docs.first.reference.update(updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text("Marks updated successfully!")),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
          // Clear form after successful update
          _reg.clear();
          _initControllers();
        }
      }
    } catch (e) {
      await ErrorLogger.logError(
        errorName: 'UpdateError',
        message: e.toString(),
        location: 'StaffDashboard._update()',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Update error: $e")),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- OPEN VERIFICATION PAGE (NEW UI) ---
  void _openVerificationPage() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => VerificationPage(
        activeYear: activeYear,
      ),
    ));
  }

  // --- VERIFICATION REPORT MODAL ---
  // ignore: unused_element
  void _showVerificationReport() {
    _searchVerification.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (_, controller) => StreamBuilder<QuerySnapshot>(
          stream: _staffBatch != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .where('batch', isEqualTo: _staffBatch)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            double batchHighest = 0;
            for (var doc in snapshot.data!.docs) {
              int s = _calculateCumulativePoints(doc.data() as Map<String, dynamic>, activeYear);
              if (s > batchHighest) batchHighest = s.toDouble();
            }

            List<Map<String, dynamic>> students = snapshot.data!.docs.map((doc) {
              var d = doc.data() as Map<String, dynamic>;
              return {
                'name': d['name'] ?? 'N/A',
                'section': d['section'] ?? 'Sec 1',
                'score': _calculateCumulativePoints(d, activeYear),
              };
            }).toList();

            return StatefulBuilder(
              builder: (context, setState) {
                // Filter students based on search query
                String searchQuery = _searchVerification.text.toLowerCase();
                List<Map<String, dynamic>> filteredStudents = students.where((s) {
                  return (s['name'] as String).toLowerCase().contains(searchQuery);
                }).toList();

                return ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text("${activeYear} VERIFICATION", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    Text("Reference Topper: ${batchHighest.toInt()} EP", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _searchVerification,
                      decoration: InputDecoration(
                        hintText: "Search student name...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchVerification.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchVerification.clear();
                                setState(() {});
                              },
                            )
                          : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),
                    if (filteredStudents.isEmpty && searchQuery.isNotEmpty)
                      const Center(child: Text("No students found", style: TextStyle(color: Colors.grey))),
                    const Divider(height: 30),
                    // SECTION 1
                    const Text("SECTION 1", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 12),
                    _buildTable("SECTION 1", filteredStudents.where((s) => s['section'] == "Sec 1").toList(), batchHighest),
                    const SizedBox(height: 30),
                    // SECTION 2
                    const Text("SECTION 2", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    _buildTable("SECTION 2", filteredStudents.where((s) => s['section'] == "Sec 2").toList(), batchHighest),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> data, double topper) {
    // Sort data based on current sort settings
    List<Map<String, dynamic>> sortedData = List.from(data);
    sortedData.sort((a, b) {
      int comparison = 0;
      if (sortBy == 'name') {
        comparison = (a['name'] as String).compareTo(b['name'] as String);
      } else if (sortBy == 'score') {
        comparison = (a['score'] as int).compareTo(b['score'] as int);
      } else if (sortBy == 'percentage') {
        double percentA = topper > 0 ? (a['score'] / topper) * 100 : 0;
        double percentB = topper > 0 ? (b['score'] / topper) * 100 : 0;
        comparison = percentA.compareTo(percentB);
      }
      return sortAscending ? comparison : -comparison;
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Wrap(
            spacing: 5,
            children: [
              FilterChip(
                label: const Text('Name'),
                selected: sortBy == 'name',
                onSelected: (_) => setState(() => sortBy = 'name'),
              ),
              FilterChip(
                label: const Text('Score'),
                selected: sortBy == 'score',
                onSelected: (_) => setState(() => sortBy = 'score'),
              ),
              FilterChip(
                label: const Text('%'),
                selected: sortBy == 'percentage',
                onSelected: (_) => setState(() => sortBy = 'percentage'),
              ),
              IconButton(
                icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 18),
                onPressed: () => setState(() => sortAscending = !sortAscending),
                tooltip: sortAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 10),
      ...sortedData.map((s) {
        double p = topper > 0 ? (s['score'] / topper) * 100 : 0;
        bool ok = p >= 40.0;
        return GestureDetector(
          onTap: () async {
            // Fetch full student data for editing
            var q = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: s['name']).get();
            if (q.docs.isNotEmpty && mounted) {
              var studentDoc = q.docs.first;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => StudentVerificationPage(studentData: studentDoc.data(), docId: studentDoc.id, activeYear: activeYear)
              ));
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: ok ? Colors.green.shade50 : Colors.red.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(s['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700, width: 2),
                  ),
                  child: Text("${s['score']} EP", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("${p.toStringAsFixed(1)}%", textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                ),
                Chip(label: Text(ok ? "ELIGIBLE" : "LOCKED", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)), 
                  backgroundColor: ok ? Colors.green : Colors.red, labelStyle: const TextStyle(color: Colors.white))
              ],
            ),
          ),
        );
      }).toList(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Portal", style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF0E7490),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.white),
            onPressed: _changePassword,
            tooltip: 'Change Password',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF6B6B), size: 24),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            tooltip: 'Logout',
          )
        ],
      ),
      backgroundColor: const Color(0xFFF0F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BATCH INFO BANNER - Enhanced
            if (_batchLoaded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _staffBatch != null
                        ? [const Color(0xFF06B6D4).withOpacity(0.1), const Color(0xFF0EA5E9).withOpacity(0.05)]
                        : [const Color(0xFFFCD34D).withOpacity(0.1), const Color(0xFFFB923C).withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _staffBatch != null ? const Color(0xFF06B6D4) : const Color(0xFFFB923C),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _staffBatch != null ? Icons.verified_user : Icons.info_outline,
                      color: _staffBatch != null ? const Color(0xFF0E7490) : const Color(0xFFB45309),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _staffBatch != null
                            ? "Batch $_staffBatch Students"
                            : "No batch assigned. Contact admin.",
                        style: TextStyle(
                          color: _staffBatch != null ? const Color(0xFF0E7490) : const Color(0xFFB45309),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // SEMESTER SELECTOR - Modern Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0F2FE), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E7490).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Evaluation Period",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0E7490),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF0F9FA),
                    ),
                    child: DropdownButton<String>(
                      value: activeYear,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      style: const TextStyle(
                        color: Color(0xFF0E7490),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      items: ["First Year", "THIRD SEMESTER", "FOURTH SEMESTER", "FIFTH SEMESTER", "SIXTH SEMESTER"]
                          .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text(y),
                          ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          activeYear = v!;
                          _initControllers();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ACTION BUTTONS ROW
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openVerificationPage,
                    icon: const Icon(Icons.analytics_outlined, size: 20),
                    label: const Text("Verify All", style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
      ],
            ),
            const SizedBox(height: 24),

            // MARKS ENTRY SECTION - Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0F2FE), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E7490).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Find & Update Student Marks",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF0E7490),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Field
                  TextField(
                    controller: _reg,
                    decoration: InputDecoration(
                      labelText: "Enter Registration No. or Name",
                      labelStyle: const TextStyle(color: Color(0xFF0E7490), fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF06B6D4)),
                      suffixIcon: _reg.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF0E7490)),
                            onPressed: () {
                              _reg.clear();
                              setState(() {});
                            },
                          )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0F2FE), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F9FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.person_search, size: 20),
                      label: const Text("Search Student", style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E7490),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: const Color(0xFFE0F2FE), thickness: 1.5),
                  const SizedBox(height: 16),

                  // MARKS INPUT FIELDS
                  ..._ctrls.entries.map((e) {
                    int max = _getLimits()[e.key] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key.toUpperCase().replaceAll('_', ' '),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF0E7490),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Max: $max",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0E7490),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: e.value,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter marks (0-$max)",
                              hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(color: Color(0xFFE0F2FE), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FCFD),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              suffixIcon: e.value.text.isNotEmpty
                                  ? Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF06B6D4).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        e.value.text,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0E7490),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  : null,
                            ),
                            onChanged: (v) => setState(() {}),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),

                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _update,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                      child: _isSaving
                          ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                            ),
                          )
                          : const Text(
                            "SAVE UPDATES",
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.5),
                          ),
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

// --- STUDENT VERIFICATION PAGE ---
class StudentVerificationPage extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final String docId;
  final String activeYear;

  const StudentVerificationPage({
    super.key,
    required this.studentData,
    required this.docId,
    required this.activeYear,
  });

  @override
  State<StudentVerificationPage> createState() => _StudentVerificationPageState();
}

class _StudentVerificationPageState extends State<StudentVerificationPage> with SingleTickerProviderStateMixin {
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initControllers();
    
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }

  void _initControllers() {
    _controllers = {};
    Map<String, int> limits = _getLimitsForYear(widget.activeYear);
    limits.forEach((key, _) {
      _controllers[key] = TextEditingController(text: (widget.studentData[key] ?? 0).toString());
    });
  }

  Map<String, int> _getLimitsForYear(String year) {
    switch (year) {
      case "First Year": return sem2Limits;
      case "THIRD SEMESTER": return sem3Limits;
      case "FOURTH SEMESTER": return sem4Limits;
      case "FIFTH SEMESTER": return sem5Limits;
      case "SIXTH SEMESTER": return sem6Limits;
      default: return sem2Limits;
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    Map<String, int> updates = {};
    Map<String, int> limits = _getLimitsForYear(widget.activeYear);
    bool hasError = false;
    String errorField = "";

    _controllers.forEach((key, controller) {
      int value = int.tryParse(controller.text) ?? 0;
      if (value > (limits[key] ?? 0)) {
        hasError = true;
        errorField = key.toUpperCase();
      }
      updates[key] = value;
    });

    if (hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("$errorField exceeds maximum limit!")),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.docId).update(updates);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("? Record updated successfully!")),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Error: $e")),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> limits = _getLimitsForYear(widget.activeYear);
    String studentName = widget.studentData['name'] ?? 'Student';
    String regNo = widget.studentData['regNo'] ?? 'N/A';
    String section = widget.studentData['section'] ?? 'N/A';
    
    // Calculate current total
    int currentTotal = 0;
    _controllers.forEach((_, controller) {
      currentTotal += int.tryParse(controller.text) ?? 0;
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Student Marks", style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF0E7490),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          )
        ],
      ),
      backgroundColor: const Color(0xFFF0F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STUDENT INFO CARD
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF06B6D4).withOpacity(0.12),
                        const Color(0xFF0EA5E9).withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person, color: Color(0xFF0E7490), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF0E7490),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Reg: $regNo | Sec: $section",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0E7490),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: const Color(0xFF0E7490).withOpacity(0.2), thickness: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Period: ${widget.activeYear}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0E7490),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Total: $currentTotal EP",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF0E7490),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // MARKS EDITING SECTION
              Text(
                "Update ${widget.activeYear} Marks",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0E7490),
                ),
              ),
              const SizedBox(height: 14),

              ..._controllers.entries.toList().asMap().entries.map((indexEntry) {
                final index = indexEntry.key;
                final e = indexEntry.value;
                int max = limits[e.key] ?? 0;
                int current = int.tryParse(e.value.text) ?? 0;
                double progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
                bool isValid = current <= max;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        0.1 + (index * 0.08),
                        0.5 + (index * 0.08),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.key.toUpperCase().replaceAll('_', ' '),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF0E7490),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF06B6D4).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "$current/$max",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0E7490),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isValid)
                                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)
                                  else
                                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Progress bar with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE0F2FE),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isValid ? const Color(0xFF06B6D4) : const Color(0xFFEF4444),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        // Input field
                        TextField(
                          controller: e.value,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: "Enter marks (0-$max)",
                            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                            errorText: !isValid ? "Exceeds maximum of $max" : null,
                            errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 14, right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.edit, color: Color(0xFF0E7490), size: 18),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 48),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isValid ? const Color(0xFFE0F2FE) : const Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isValid ? const Color(0xFF06B6D4) : const Color(0xFFEF4444),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FCFD),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 28),

              // SAVE BUTTON
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      disabledBackgroundColor: const Color(0xFFCBD5E1),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: _isSaving
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                          ),
                        )
                        : const Text(
                          "SAVE ALL CHANGES",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CANCEL BUTTON
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0E7490), width: 1.5),
                      foregroundColor: const Color(0xFF0E7490),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ACTIVITY BREAKDOWN PAGE (NEW MODAL UI) ---
class ActivityBreakdownPage extends StatefulWidget {
  final String year;
  final Map<String, dynamic> studentData;

  const ActivityBreakdownPage({
    super.key,
    required this.year,
    required this.studentData,
  });

  @override
  State<ActivityBreakdownPage> createState() => _ActivityBreakdownPageState();
}

class _ActivityBreakdownPageState extends State<ActivityBreakdownPage> {
  Map<String, int> _getLimits() {
    switch (widget.year) {
      case "1st Year":
        return sem2Limits;
      case "2nd Year":
        return sem3Limits;
      case "3rd Year":
        return sem4Limits;
      case "4th Year":
        return sem5Limits;
      case "Final Year":
        return sem6Limits;
      default:
        return sem2Limits;
    }
  }

  String _getTitle() {
    switch (widget.year) {
      case "1st Year":
        return "\u{1F9ED} Year 1 (SEM 2-3)";
      case "2nd Year":
        return "\u{1F4DA} Year 2 (SEM 3-4)";
      case "3rd Year":
        return "\u{1F680} Year 3 (SEM 4-5)";
      case "4th Year":
        return "\u{1F393} Year 4 (SEM 6-7)";
      case "Final Year":
        return "\u{1F3AF} Final Year (SEM 7)";
      default:
        return widget.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> limits = _getLimits();
    String title = _getTitle();
    int totalPoints = 0;
    int achievedPoints = 0;

    limits.forEach((key, maxPoints) {
      int current = widget.studentData[key] ?? 0;
      achievedPoints += current;
      totalPoints += maxPoints;
    });

    double percentage = totalPoints > 0 ? (achievedPoints / totalPoints) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0E7490),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF0F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF06B6D4).withOpacity(0.15),
                    const Color(0xFF0EA5E9).withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Progress",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0E7490),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$achievedPoints / $totalPoints EP",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0E7490),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF06B6D4).withOpacity(0.2),
                              const Color(0xFF0EA5E9).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${percentage.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0E7490),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF06B6D4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE0F2FE),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Activity Breakdown
            Text(
              "\u{1F4CB} Activity Details",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF0E7490),
              ),
            ),
            const SizedBox(height: 14),
            ...limits.entries.map((e) {
              int current = widget.studentData[e.key] ?? 0;
              int limit = e.value;
              double progress = (current / limit).clamp(0.0, 1.0);
              bool isCompleted = current >= limit;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF10B981).withOpacity(0.3)
                          : const Color(0xFFE0F2FE),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCompleted
                            ? const Color(0xFF10B981).withOpacity(0.08)
                            : const Color(0xFF06B6D4).withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${isCompleted ? '\u{2705}' : '\u{1F538}'} ${e.key.replaceAll('_', ' ').toUpperCase()}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E7490),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF10B981).withOpacity(0.15)
                                  : const Color(0xFF06B6D4).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$current / $limit",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0E7490),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE0F2FE),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFF06B6D4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            Center(
              child: Text(
                percentage >= 100
                    ? "\u{1F389} All activities completed!"
                    : "Keep improving!",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: percentage >= 100
                      ? const Color(0xFF10B981)
                      : const Color(0xFF0E7490),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- VERIFICATION PAGE (NEW UI WITH TABS) ---
class VerificationPage extends StatefulWidget {
  final String activeYear;
  final String? staffBatch;
  const VerificationPage({
    super.key,
    required this.activeYear,
    this.staffBatch,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String sortBy = 'name';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }



  int _calculateCumulativePoints(Map<String, dynamic> d, String year) {
    int s2 = _sum(d, sem2Limits);
    int s3 = _sum(d, sem3Limits);
    int s4 = _sum(d, sem4Limits);
    int s5 = _sum(d, sem5Limits);
    int s6 = _sum(d, sem6Limits);

    if (year == "First Year") return s2;
    if (year == "THIRD SEMESTER") return s2 + s3;
    if (year == "FOURTH SEMESTER") return s2 + s3 + s4;
    if (year == "FIFTH SEMESTER") return s2 + s3 + s4 + s5;
    return s2 + s3 + s4 + s5 + s6;
  }

  int _sum(Map<String, dynamic> d, Map<String, int> l) {
    int t = 0;
    l.forEach((k, _) {
      var val = d[k] ?? 0;
      t += (val is int) ? val : (val as num).toInt();
    });
    return t;
  }

  List<Map<String, dynamic>> _sortStudents(List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> sortedData = List.from(data);
    sortedData.sort((a, b) {
      int comparison = 0;
      if (sortBy == 'name') {
        comparison = (a['name'] as String).compareTo(b['name'] as String);
      } else if (sortBy == 'score') {
        comparison = (a['score'] as int).compareTo(b['score'] as int);
      } else if (sortBy == 'percentage') {
        double percentA = (a['topper'] as double) > 0 ? (a['score'] / a['topper']) * 100 : 0;
        double percentB = (b['topper'] as double) > 0 ? (b['score'] / b['topper']) * 100 : 0;
        comparison = percentA.compareTo(percentB);
      }
      return sortAscending ? comparison : -comparison;
    });
    return sortedData;
  }

  // --- CSV EXPORT FUNCTION ---
  Future<void> _exportToCSV(List<Map<String, dynamic>> allStudents) async {
    try {
      String searchQuery = _searchController.text.toLowerCase();
      
      // Filter students based on search query
      List<Map<String, dynamic>> filteredStudents = allStudents
    .where((s) => (s['name'] as String).toLowerCase().contains(searchQuery) ||
                  (s['regNo'] ?? '').toString().toLowerCase().contains(searchQuery))
    .toList();
      
          

// Sort by section: Section 1 first, then Section 2
// Sort by section first, then by name within each section
filteredStudents.sort((a, b) {
  String sectionA = (a['section'] ?? 'N/A').toString();
  String sectionB = (b['section'] ?? 'N/A').toString();
  
  // First compare sections
  int sectionCompare = sectionA.compareTo(sectionB);
  if (sectionCompare != 0) {
    return sectionCompare;
  }
  
  // If sections are same, compare names alphabetically
  String nameA = (a['name'] ?? 'N/A').toString();
  String nameB = (b['name'] ?? 'N/A').toString();
  return nameA.compareTo(nameB);
});

      if (filteredStudents.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No students to export')),
          );
        }
        return;
      }

      // Prepare CSV data
      List<List<dynamic>> csvData = [];
      
      // Add headers
      csvData.add([
        'Registration No',
        'Student Name',
        'Section',
        'EP Score',
        'Percentage (%)',
        'Status',
        'EP Gap',
      ]);

      double batchHighest = 0;
      
      // Calculate cumulative points for each student and find highest
      List<int> cumulativeScores = [];
      for (var student in filteredStudents) {
        int score = _calculateCumulativePoints(student, widget.activeYear);
        cumulativeScores.add(score);
        if (score > batchHighest) batchHighest = score.toDouble();
      }

      // Add student rows
      for (int i = 0; i < filteredStudents.length; i++) {
        var student = filteredStudents[i];
        int score = cumulativeScores[i];
        double percentage = batchHighest > 0 ? (score / batchHighest) * 100 : 0;
        bool isEligible = percentage >= 40.0;
        int gap = isEligible ? 0 : (batchHighest * 0.4 - score).ceil().abs();

        csvData.add([
          student['regNo'] ?? 'N/A',
          student['name'] ?? 'N/A',
          student['section'] ?? 'N/A',
          score,
          percentage.toStringAsFixed(1),
          isEligible ? 'ELIGIBLE' : 'LOCKED',
          gap,
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Create filename with timestamp
      String timestamp = DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-').split('.')[0];
      String fileName = 'Verification_${widget.activeYear}_$timestamp.csv';

      // Save/download file
      if (!kIsWeb) {
        // Mobile/Desktop: Save to documents
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(csv);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('CSV saved: ${file.path}')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving CSV: $e')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Widget _buildSectionContent(String section, double topperScore, List<Map<String, dynamic>> allStudents) {
    String searchQuery = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> sectionStudents = allStudents
        .where((s) => s['section'] == section)
        .where((s) => (s['name'] as String).toLowerCase().contains(searchQuery))
        .toList();
    
    sectionStudents = _sortStudents(sectionStudents);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Header with Stats
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF06B6D4).withOpacity(0.15),
                const Color(0xFF0EA5E9).withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    section,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF0E7490),
                      letterSpacing: 0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${topperScore.toInt()} EP",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0E7490),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people, color: Color(0xFF0E7490), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "${sectionStudents.length} Students",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0E7490),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Sort Controls
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilterChip(
              label: const Text("Name", style: TextStyle(fontWeight: FontWeight.w600)),
              selected: sortBy == 'name',
              selectedColor: const Color(0xFF06B6D4).withOpacity(0.3),
              backgroundColor: const Color(0xFFE0F2FE),
              labelStyle: TextStyle(
                color: sortBy == 'name' ? const Color(0xFF0E7490) : const Color(0xFF0E7490),
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => setState(() => sortBy = 'name'),
            ),
            FilterChip(
              label: const Text("Score", style: TextStyle(fontWeight: FontWeight.w600)),
              selected: sortBy == 'score',
              selectedColor: const Color(0xFF06B6D4).withOpacity(0.3),
              backgroundColor: const Color(0xFFE0F2FE),
              labelStyle: TextStyle(
                color: sortBy == 'score' ? const Color(0xFF0E7490) : const Color(0xFF0E7490),
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => setState(() => sortBy = 'score'),
            ),
            FilterChip(
              label: const Text("%", style: TextStyle(fontWeight: FontWeight.w600)),
              selected: sortBy == 'percentage',
              selectedColor: const Color(0xFF06B6D4).withOpacity(0.3),
              backgroundColor: const Color(0xFFE0F2FE),
              labelStyle: TextStyle(
                color: sortBy == 'percentage' ? const Color(0xFF0E7490) : const Color(0xFF0E7490),
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => setState(() => sortBy = 'percentage'),
            ),
            ActionChip(
              label: Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18,
                color: const Color(0xFF0E7490),
              ),
              backgroundColor: const Color(0xFFE0F2FE),
              onPressed: () => setState(() => sortAscending = !sortAscending),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (sectionStudents.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: const Color(0xFF06B6D4).withOpacity(0.3)),
                const SizedBox(height: 12),
                Text(
                  "No students found",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0E7490).withOpacity(0.6),
                  ),
                ),
      ],
            ),
          )
        else
          ...sectionStudents.map((student) {
            double percentage = topperScore > 0 ? (student['score'] / topperScore) * 100 : 0;
            bool isEligible = percentage >= 40.0;
            
            return GestureDetector(
              onTap: () async {
                var q = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: student['name']).get();
                if (q.docs.isNotEmpty && mounted) {
                  var studentDoc = q.docs.first;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StudentVerificationPage(
                      studentData: studentDoc.data(),
                      docId: studentDoc.id,
                      activeYear: widget.activeYear,
                    ),
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEligible ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFEF4444).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isEligible 
                          ? const Color(0xFF10B981).withOpacity(0.08)
                          : const Color(0xFFEF4444).withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEligible ? Icons.check_circle : Icons.lock_outline,
                        color: isEligible ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF0E7490),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Reg: ${student['regNo']}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF06B6D4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${student['score']} EP | ${percentage.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0E7490),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isEligible ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFFEF4444).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            isEligible ? "ELIGIBLE" : "LOCKED",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isEligible ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E7490),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          "${widget.activeYear} Verification",
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E7490).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
      ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF06B6D4),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF0E7490),
              labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "SECTION 1"),
                Tab(text: "SECTION 2"),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF0F9FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search student name...",
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF06B6D4)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF0E7490)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(color: Color(0xFFE0F2FE), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.staffBatch != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'student')
                      .where('batch', isEqualTo: widget.staffBatch)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'student')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading students...",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0E7490).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                double batchHighest = 0;
                List<Map<String, dynamic>> students = [];

                for (var doc in snapshot.data!.docs) {
                  var d = doc.data() as Map<String, dynamic>;
                  int score = _calculateCumulativePoints(d, widget.activeYear);
                  if (score > batchHighest) batchHighest = score.toDouble();
                  
                  students.add({
                    'name': d['name'] ?? 'N/A',
                    'regNo': d['regNo'] ?? 'N/A',
                    'section': d['section'] ?? 'Sec 1',
                    'score': score,
                    'topper': batchHighest,
                  });
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSectionContent("Sec 1", batchHighest, students),
                    _buildSectionContent("Sec 2", batchHighest, students),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- VERIFICATION STATS PAGE (FULL SCREEN) ---
class VerificationStatsPage extends StatefulWidget {
  final String selectedBatch;
  final String filterYear;
  final List<Map<String, dynamic>> students;
  final double batchHighest;
  
  const VerificationStatsPage({
    super.key,
    required this.selectedBatch,
    required this.filterYear,
    required this.students,
    required this.batchHighest,
  });

  @override
  State<VerificationStatsPage> createState() => _VerificationStatsPageState();
}

class _VerificationStatsPageState extends State<VerificationStatsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String sortBy = 'name'; // name, score, percentage
  bool sortAscending = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterAndSort(List<Map<String, dynamic>> data, double topper) {
    final q = _searchCtrl.text.toLowerCase();
    List<Map<String, dynamic>> filtered = data.where((s) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final reg = (s['regNo'] ?? '').toString().toLowerCase();
      return name.contains(q) || reg.contains(q);
    }).toList();

    filtered.sort((a, b) {
      int cmp = 0;
      if (sortBy == 'name') {
        cmp = (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString());
      } else if (sortBy == 'score') {
        cmp = (a['score'] ?? 0 as num).compareTo((b['score'] ?? 0 as num));
      } else if (sortBy == 'percentage') {
        final pa = topper > 0 ? ((a['score'] ?? 0) as num) / topper : 0;
        final pb = topper > 0 ? ((b['score'] ?? 0) as num) / topper : 0;
        cmp = pa.compareTo(pb);
      }
      return sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Verification ${widget.filterYear}",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        backgroundColor: AdminTheme.primaryColor,
        elevation: 2,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "Search by name or reg no...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('By Name'),
                selected: sortBy == 'name',
                onSelected: (_) => setState(() => sortBy = 'name'),
              ),
              FilterChip(
                label: const Text('By Score'),
                selected: sortBy == 'score',
                onSelected: (_) => setState(() => sortBy = 'score'),
              ),
              FilterChip(
                label: const Text('By %'),
                selected: sortBy == 'percentage',
                onSelected: (_) => setState(() => sortBy = 'percentage'),
              ),
              ActionChip(
                label: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                onPressed: () => setState(() => sortAscending = !sortAscending),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFullTable(
            "SECTION 1 VERIFICATION",
            _filterAndSort(widget.students.where((s) => s['section'] == "Sec 1").toList(), widget.batchHighest),
            widget.batchHighest,
            AdminTheme.primaryLight,
          ),
          const SizedBox(height: 40),
          _buildFullTable(
            "SECTION 2 VERIFICATION",
            _filterAndSort(widget.students.where((s) => s['section'] == "Sec 2").toList(), widget.batchHighest),
            widget.batchHighest,
            AdminTheme.secondaryColor,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFullTable(String title, List<Map<String, dynamic>> data, double topper, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          "${data.length} students - Batch ${widget.selectedBatch}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        if (data.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("No students in this section", style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...data.map((s) {
            double percentage = topper > 0 ? (s['score'] / topper) * 100 : 0;
            bool eligible = percentage >= 40.0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: eligible ? Colors.green.shade50 : Colors.red.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "RegNo: ${s['regNo']}",
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade700, width: 1),
                          ),
                          child: Text(
                            "${s['score']} EP",
                            style: const TextStyle(fontSize: 6, fontWeight: FontWeight.w900, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${percentage.toStringAsFixed(1)}%",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                          ),
                        ),
                        Chip(
                          label: Text(
                            eligible ? "ELIGIBLE" : "BELOW TARGET",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: eligible ? Colors.green : Colors.red,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}









