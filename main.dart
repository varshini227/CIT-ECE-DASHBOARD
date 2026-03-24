import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'splash_screen.dart'; 
import 'firebase_options.dart'; 
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/error_logger.dart';

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
        // Branding colors derived from your ECE logo
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6), // Tech Blue
          primary: const Color(0xFF001D3D),   // Deep Navy from logo background
          secondary: const Color(0xFF00F5D4), // Electric Teal from circuit traces
          surface: Colors.white,
        ),
        
        // Customizing AppBars to match the metallic/navy logo style
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF001D3D), 
          foregroundColor: Color(0xFFF3E8F1), // Off-white/Silver from logo text
          centerTitle: true,
          elevation: 5,
        ),

        // FIXED: Changed CardTheme to CardThemeData to resolve diagnostic error
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: const Color(0xFF0077B6).withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),

        // Applying the theme to the SegmentedButtons/Tabs
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: const Color(0xFF0077B6),
            selectedForegroundColor: Colors.white,
          ),
        ),
      ),
      // This will now find the SplashScreen class correctly
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
  String viewYear = "First Year";
  // --- PLACE THIS CODE INSIDE _StudentDashboardState ---
Widget _buildInspirationCard() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF001D3D), // Matches your professional Navy branding
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.blue.shade300, width: 1),
    ),
    child: const Column(
      children: [
        Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
        SizedBox(height: 12),
        Text(
          "\"You don’t have to be great to start, but you have to start to be great.\"",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "— Zig Ziglar",
          style: TextStyle(
            color: Color(0xFFF3E8F1), // Metallic Silver from your theme
            fontSize: 11,
            fontWeight: FontWeight.bold,
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
        if (viewYear == "First Year") {
          headerTitle = "III SEM EP ROLES";
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
        } else if (viewYear == "Second Year") {
          headerTitle = "IV SEM EP ROLES";
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
        } else if (viewYear == "Third Year") {
          headerTitle = "V SEM EP ROLES";
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
        } else if (viewYear == "VI Sem") {
          headerTitle = "VI SEM EP ROLES";
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
  title: Text("Welcome, ${myData['name']}"),
  // Deep Navy background for high visibility and professional branding
  backgroundColor: const Color(0xFF001D3D), 
  // Metallic Silver/White text for clear contrast
  foregroundColor: const Color(0xFFF3E8F1), 
  actions: [
    IconButton(
      icon: const Icon(Icons.lock),
      onPressed: _changePassword,
      tooltip: 'Change Password',
    ),
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: _logout,
      tooltip: 'Logout',
    ),
  ],
),

          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildInspirationCard(), 
    
              const SizedBox(height: 25),
              
             // Changed $semesterOnlyPoints to $studentScore to show cumulative marks
_buildPointBox(
  "${viewYear.toUpperCase()} CUMULATIVE MARKS", 
  "$studentScore EP", 
  const Color.fromARGB(255, 3, 3, 97)
),
const SizedBox(height: 20),
              _buildYearSelector(),
              const SizedBox(height: 25),
              Text(headerTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Benchmark (100%): ${currentRef.toInt()} EP", style: const TextStyle(color: Color.fromARGB(255, 40, 168, 160), fontSize: 11)),
              const Divider(),

              
              ...roleThresholds.entries.map((role) {
                double target = currentRef * role.value;
                bool isEligible = studentScore >= target;
                double gap = target - studentScore;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isEligible ?  Color.fromARGB(255, 247, 254, 254) : Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(isEligible ? Icons.verified : Icons.lock_outline, color: isEligible ? Colors.green : Colors.red),
                    title: Text(role.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Criteria: ${(role.value * 100).toInt()}% of Topper (${target.toStringAsFixed(1)} EP)"),
                        if (!isEligible)
                          Text("Need: ${gap.toStringAsFixed(1)} more EP", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    trailing: Text(
                      isEligible ? "ELIGIBLE" : "LOCKED",
                      style: TextStyle(color: isEligible ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),
              Text("${viewYear.toUpperCase()} ACTIVITY BREAKDOWN", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              ...activeBreakdownLimits.entries.map((e) => ListTile(
                dense: true,
                title: Text(e.key.replaceAll('_', ' ').toUpperCase()),
                trailing: Text("${myData![e.key] ?? 0} / ${e.value}"),
              )),
              
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL SEMESTER EP:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$semesterOnlyPoints", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
 
  


  Widget _buildYearSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: "First Year", label: Text("SEM 3")),
          ButtonSegment(value: "Second Year", label: Text("SEM 4")),
          ButtonSegment(value: "Third Year", label: Text("SEM 5")),
          ButtonSegment(value: "VI Sem", label: Text("SEM 6")),
          ButtonSegment(value: "VII Sem", label: Text("SEM 7")),
        ],
        selected: {viewYear},
        onSelectionChanged: (s) => setState(() => viewYear = s.first),
      ),
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

  // ════════════════════════════════════════════════════════════
  // Add Batch Dialog
  // ════════════════════════════════════════════════════════════
  void _showAddBatchDialog() {
    TextEditingController batchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Academic Batch"),
        content: TextField(
          controller: batchController,
          decoration: const InputDecoration(hintText: "Enter Batch Code (e.g., 29)"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
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
                  const SnackBar(content: Text("Batch Created Successfully")),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Password Change
  // ════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════
  // Create User (Staff/Admin) via Cloud Function
  // ════════════════════════════════════════════════════════════
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

  void _exportToCSV(List<Map<String, dynamic>> students) {
    List<List<dynamic>> rows = [];
    rows.add(["Register No", "Name", "Section", "Batch", "Total EP"]);
    for (var s in students) {
      rows.add([s['regNo'], s['name'], s['section'], selectedBatch, s['score']]);
    }
    String csvData = const ListToCsvConverter().convert(rows);
    final bytes = Uri.encodeComponent(csvData);
    html.AnchorElement(href: "data:text/csv;charset=utf-8,$bytes")
      ..setAttribute("download", "ECE_Batch_${selectedBatch}_Report.csv")
      ..click();
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

  // ════════════════════════════════════════════════════════════
  // Upload Students from CSV
  // ════════════════════════════════════════════════════════════
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
        SnackBar(content: Text("$count students uploaded to Batch $selectedBatch ✓")),
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

  // ════════════════════════════════════════════════════════════
  // ★ TEMPORARY: Attach Batch to Existing Students
  //   REMOVE this method + button after running once
  // ════════════════════════════════════════════════════════════
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
              "that don't have one yet.\n\nEnter the batch code to assign:",
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

  // ════════════════════════════════════════════════════════════
  // ★ MIGRATE BATCH 26 → 25 (FIX UPLOADED MISTAKE)
  // ════════════════════════════════════════════════════════════
  Future<void> _migrateBatchStudents() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚠️ Migrate Batch 26 → 25"),
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
            Text("Migrating batch 26 → 25..."),
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
            "✓ Successfully migrated $migrated students from Batch 26 to Batch 25",
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

  // ════════════════════════════════════════════════════════════
  // build()
  // ════════════════════════════════════════════════════════════
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

        double s1Sum = 0, s2Sum = 0;
        int s1Count = 0, s2Count = 0;
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
            s1Sum += score; s1Count++;
            if (score > s1TopperScore) { s1TopperScore = score; s1TopperName = studentInfo['name'] as String; }
          } else {
            s2Sum += score; s2Count++;
            if (score > s2TopperScore) { s2TopperScore = score; s2TopperName = studentInfo['name'] as String; }
          }
        }

        if (currentViewMode == "student") {
          return _impersonate(StudentDashboard(uid: firstStudentId ?? "sample_uid"));
        }

        double s1Avg = s1Count > 0 ? s1Sum / s1Count : 0;
        double s2Avg = s2Count > 0 ? s2Sum / s2Count : 0;
        String leadingSection = s1Avg > s2Avg ? "SECTION 1" : "SECTION 2";
        double winPercent = ((s1Avg > s2Avg ? s1Avg : s2Avg) / maxPoints) * 100;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Admin Batch Analytics"),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: "Create User",
                onPressed: _showCreateUserDialog,
              ),
              IconButton(
                icon: const Icon(Icons.lock),
                onPressed: _changePassword,
                tooltip: 'Change Password',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_tree_outlined, color: Colors.blue),
                onSelected: (v) => setState(() => currentViewMode = v),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: "admin", child: Text("Admin View")),
                  const PopupMenuItem(value: "staff", child: Text("Staff View")),
                  const PopupMenuItem(value: "student", child: Text("Student View")),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginPage())),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddBatchDialog,
            backgroundColor: Colors.blue.shade900,
            child: const Icon(Icons.add_to_photos, color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // Leading Section Card
              Card(
                color: Colors.indigo.shade800,
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
                  title: Text("LEADING: $leadingSection",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("Avg Achievement: ${winPercent.toStringAsFixed(1)}%",
                      style: const TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 25),

              // Batch Selector chips
              const Text("SELECT BATCH",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: _buildBatchSelector(),
              ),
              const SizedBox(height: 12),

              // Upload Students CSV
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _uploadStudentsFromCSV,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("UPLOAD STUDENTS (CSV)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ★ TEMPORARY — remove after running once
              ElevatedButton.icon(
                onPressed: _attachBatchToStudents,
                icon: const Icon(Icons.label_outline),
                label: const Text("ATTACH BATCH TO EXISTING STUDENTS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              // ★ END TEMPORARY

              // Semester Selector
              DropdownButton<String>(
                value: filterYear,
                isExpanded: true,
                items: ["First Year", "THIRD SEMESTER", "FOURTH SEMESTER", "FIFTH SEMESTER", "SIXTH SEMESTER"]
                    .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (v) => setState(() { filterYear = v!; showTable = false; }),
              ),
              const SizedBox(height: 25),

              // Section Toppers
              const Text("SECTION TOPPERS", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _performerCard("SEC 1 TOPPER", s1TopperName, s1TopperScore)),
                const SizedBox(width: 10),
                Expanded(child: _performerCard("SEC 2 TOPPER", s2TopperName, s2TopperScore)),
              ]),
              const SizedBox(height: 30),

              // Bar Chart
              const Text("SECTION ACHIEVEMENT RATIO (%)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildBarChart(s1Avg, s2Avg, maxPoints),
              const Divider(height: 50),

              // Verification Table Toggle
              ElevatedButton.icon(
                onPressed: () => setState(() => showTable = !showTable),
                icon: Icon(showTable ? Icons.visibility_off : Icons.analytics),
                label: Text(showTable ? "HIDE DATA TABLE" : "GENERATE VERIFICATION TABLE"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
              ),

              if (showTable) ...[
                const SizedBox(height: 20),
                _buildSectionTable("SECTION 1 VERIFICATION",
                    students.where((s) => s['section'] == "Sec 1").toList(), batchHighest, Colors.blue),
                const SizedBox(height: 30),
                _buildSectionTable("SECTION 2 VERIFICATION",
                    students.where((s) => s['section'] == "Sec 2").toList(), batchHighest, Colors.orange),
              ],
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // UI Component helpers — ALL UNCHANGED
  // ════════════════════════════════════════════════════════════

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
        height: 180,
        child: BarChart(BarChartData(
          maxY: max,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: s1, color: Colors.blue, width: 40)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: s2, color: Colors.orange, width: 40)]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) => Text(v == 0 ? "SEC 1" : "SEC 2"),
              ),
            ),
          ),
        )),
      );

  Widget _buildSectionTable(String title, List<Map<String, dynamic>> data, double topper, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 10),
        DataTable(
          headingRowColor: MaterialStateProperty.all(color.withOpacity(0.1)),
          columns: const [
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("EP")),
            DataColumn(label: Text("%")),
          ],
          rows: data.map((s) {
            double p = topper > 0 ? (s['score'] / topper) * 100 : 0;
            return DataRow(cells: [
              DataCell(Text(s['name'], style: const TextStyle(fontSize: 11))),
              DataCell(Text("${s['score']}")),
              DataCell(Text("${p.toStringAsFixed(1)}%")),
            ]);
          }).toList(),
        ),
      ]);

  Widget _performerCard(String title, String name, int score) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold)),
          Text(name, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Text("$score EP", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
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
          const SnackBar(content: Text("Please enter a registration number or name")),
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
            const SnackBar(content: Text("Student not found")),
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
                content: Text("Student not in your batch (Batch $_staffBatch)"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
      } else {
        var data = q.docs.first.data() as Map<String, dynamic>?
;
        if (data == null) return;
        
        // Check if student belongs to this staff's batch
        if (_staffBatch != null && data['batch']?.toString() != _staffBatch) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Student not in your batch (Batch $_staffBatch)"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
      }
    } catch (e) {
      await ErrorLogger.logError(
        errorName: 'SearchError',
        message: e.toString(),
        location: 'StaffDashboard._search()',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Search error: $e")),
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
        if (val > (currentLimits[k] ?? 0)) { isInvalid = true; errorField = k.toUpperCase(); }
        updates[k] = val;
      });

      if (isInvalid) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $errorField exceeds point limit!"), backgroundColor: Colors.red));
        setState(() => _isSaving = false);
        return;
      }

      var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
      if (q.docs.isNotEmpty) {
        await q.docs.first.reference.update(updates);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marks Updated Successfully!")));
      }
    } catch (e) {
      await ErrorLogger.logError(
        errorName: 'UpdateError',
        message: e.toString(),
        location: 'StaffDashboard._update()',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
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
                    _buildTable("SECTION 1", filteredStudents.where((s) => s['section'] == "Sec 1").toList(), batchHighest),
                    const SizedBox(height: 30),
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
                builder: (_) => StudentVerificationPage(studentData: studentDoc.data() as Map<String, dynamic>, docId: studentDoc.id, activeYear: activeYear)
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
      appBar: AppBar(title: const Text("CIT ECE Staff Portal"), actions: [
        IconButton(
          icon: const Icon(Icons.lock),
          onPressed: _changePassword,
          tooltip: 'Change Password',
        ),
        IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // NEW: Batch Info Banner
          if (_batchLoaded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _staffBatch != null ? Colors.blue.shade50 : Colors.orange.shade50,
                border: Border.all(color: _staffBatch != null ? Colors.blue : Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _staffBatch != null ? Icons.check_circle : Icons.info,
                    color: _staffBatch != null ? Colors.blue : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _staffBatch != null
                          ? "Viewing Batch $_staffBatch students only"
                          : "You are not assigned to any batch. Contact admin.",
                      style: TextStyle(
                        color: _staffBatch != null ? Colors.blue.shade800 : Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          // DROPDOWN WITH NEW SEMESTER LABELS
          DropdownButton<String>(
            value: activeYear, 
            isExpanded: true,
            items: ["First Year", "THIRD SEMESTER", "FOURTH SEMESTER", "FIFTH SEMESTER", "SIXTH SEMESTER"]
                .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
            onChanged: (v) => setState(() { activeYear = v!; _initControllers(); }),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _openVerificationPage, icon: const Icon(Icons.analytics_outlined), label: const Text("GENERATE VERIFICATION TABLE"))),
          const Divider(height: 40),
          TextField(controller: _reg, decoration: InputDecoration(labelText: "Student Reg No", suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search), border: const OutlineInputBorder())),
          const SizedBox(height: 20),
          ..._ctrls.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(controller: e.value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "${e.key.toUpperCase()} (Max: ${_getLimits()[e.key]})", border: const OutlineInputBorder())),
          )),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isSaving ? null : _update, child: _isSaving ? const CircularProgressIndicator() : const Text("SAVE UPDATES"))),
        ]),
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

class _StudentVerificationPageState extends State<StudentVerificationPage> {
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
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
          SnackBar(content: Text("Error: $errorField exceeds maximum limit!"), backgroundColor: Colors.red)
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.docId).update(updates);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student record updated successfully!"), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> limits = _getLimitsForYear(widget.activeYear);
    
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.studentData['name']} - ${widget.activeYear}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
            tooltip: 'Save Changes',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Student Information", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Text("Name: ${widget.studentData['name'] ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                    Text("Reg No: ${widget.studentData['regNo'] ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                    Text("Section: ${widget.studentData['section'] ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text("Edit ${widget.activeYear} Points", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            ..._controllers.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextField(
                controller: e.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "${e.key.toUpperCase()} (Max: ${limits[e.key]})",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => e.value.clear(),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
                label: _isSaving ? const CircularProgressIndicator() : const Text("SAVE ALL CHANGES"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  Widget _buildSectionContent(String section, double topperScore, List<Map<String, dynamic>> allStudents) {
    String searchQuery = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> sectionStudents = allStudents
        .where((s) => s['section'] == section)
        .where((s) => (s['name'] as String).toLowerCase().contains(searchQuery))
        .toList();
    
    sectionStudents = _sortStudents(sectionStudents);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: section == "Sec 1" ? Colors.blue.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: section == "Sec 1" ? Colors.blue.shade700 : Colors.green.shade700, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(section, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
              Chip(
                label: Text("Topper: ${topperScore.toInt()} EP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                backgroundColor: section == "Sec 1" ? Colors.blue : Colors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$section VERIFICATION", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                const SizedBox(height: 8),
                Text("Total Students: ${sectionStudents.length}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text("Reference Topper: ${topperScore.toInt()} EP", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Sort Controls
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
        if (sectionStudents.isEmpty)
          const Center(child: Text("No students found", style: TextStyle(color: Colors.grey)))
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
                      studentData: studentDoc.data() as Map<String, dynamic>,
                      docId: studentDoc.id,
                      activeYear: widget.activeYear,
                    ),
                  ));
                }
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isEligible ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text("${student['score']} EP • ${percentage.toStringAsFixed(1)}%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue.shade800)),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(isEligible ? "ELIGIBLE" : "LOCKED", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        backgroundColor: isEligible ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
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
        backgroundColor: const Color(0xFF0C4A82),
        title: Text("${widget.activeYear} Verification", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF004A99),
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF0C4A82),
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "SECTION 1"),
                Tab(text: "SECTION 2"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search student name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onChanged: (_) => setState(() {}),
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
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                double batchHighest = 0;
                List<Map<String, dynamic>> students = [];

                for (var doc in snapshot.data!.docs) {
                  var d = doc.data() as Map<String, dynamic>;
                  int score = _calculateCumulativePoints(d, widget.activeYear);
                  if (score > batchHighest) batchHighest = score.toDouble();
                  
                  students.add({
                    'name': d['name'] ?? 'N/A',
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
