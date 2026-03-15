import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'splash_screen.dart'; 
import 'firebase_options.dart'; // Add this line at the top

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
  String currentViewMode = "admin"; // Tracks impersonation for Staff/Student views

  // --- CORE LOGIC: Cumulative Point Summation ---
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

  @override
  Widget build(BuildContext context) {
    // --- GOD MODE ROUTING ---
    if (currentViewMode == "staff") return _impersonate(const StaffDashboard());
    if (currentViewMode == "student") {
      // Logic to find a real ID is handled inside the StreamBuilder below
    }

    double maxPoints = filterYear == "First Year" ? 40 : 
                       filterYear == "THIRD SEMESTER" ? 80 : 
                       filterYear == "FOURTH SEMESTER" ? 120 : 
                       filterYear == "FIFTH SEMESTER" ? 160 : 200;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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

          // Calculate Section Averages and Section Toppers
          if (studentInfo['section'] == "Sec 1") {
            s1Sum += score; s1Count++;
            if (score > s1TopperScore) { s1TopperScore = score; s1TopperName = studentInfo['name'] as String; }
          } else {
            s2Sum += score; s2Count++;
            if (score > s2TopperScore) { s2TopperScore = score; s2TopperName = studentInfo['name'] as String; }
          }
        }

        if (currentViewMode == "student") return _impersonate(StudentDashboard(uid: firstStudentId ?? "sample_uid"));

        double s1Avg = s1Count > 0 ? s1Sum / s1Count : 0;
        double s2Avg = s2Count > 0 ? s2Sum / s2Count : 0;
        String leadingSection = s1Avg > s2Avg ? "SECTION 1" : "SECTION 2";
        double winPercent = ((s1Avg > s2Avg ? s1Avg : s2Avg) / maxPoints) * 100;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Admin Batch Analytics"),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_tree_outlined, color: Colors.blue),
                onSelected: (v) => setState(() => currentViewMode = v),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: "admin", child: Text("Admin View")),
                  const PopupMenuItem(value: "staff", child: Text("Staff View")),
                  const PopupMenuItem(value: "student", child: Text("Student View")),
                ],
              ),
              IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()))),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Comparison Winner Card
              Card(
                color: Colors.indigo.shade800,
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
                  title: Text("LEADING: $leadingSection", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("Avg Achievement: ${winPercent.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 25),

              // 2. Semester Selector
              DropdownButton<String>(
                value: filterYear, isExpanded: true,
                items: ["First Year", "THIRD SEMESTER", "FOURTH SEMESTER", "FIFTH SEMESTER", "SIXTH SEMESTER"].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (v) => setState(() { filterYear = v!; showTable = false; }),
              ),
              const SizedBox(height: 25),

              // 3. Section Topper Gallery
              const Text("SECTION TOPPERS", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _performerCard("SEC 1 TOPPER", s1TopperName, s1TopperScore)),
                const SizedBox(width: 10),
                Expanded(child: _performerCard("SEC 2 TOPPER", s2TopperName, s2TopperScore)),
              ]),
              const SizedBox(height: 30),

              // 4. Bar Chart Comparison
              
              const Text("SECTION ACHIEVEMENT RATIO (%)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildBarChart(s1Avg, s2Avg, maxPoints),
              
              const Divider(height: 50),

              // 5. Verification Table Toggle
              ElevatedButton.icon(
                onPressed: () => setState(() => showTable = !showTable),
                icon: Icon(showTable ? Icons.visibility_off : Icons.analytics),
                label: Text(showTable ? "HIDE DATA TABLE" : "GENERATE VERIFICATION TABLE"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
              ),

              if (showTable) ...[
                const SizedBox(height: 20),
                _buildSectionTable("SECTION 1 VERIFICATION", students.where((s) => s['section'] == "Sec 1").toList(), batchHighest, Colors.blue),
                const SizedBox(height: 30),
                _buildSectionTable("SECTION 2 VERIFICATION", students.where((s) => s['section'] == "Sec 2").toList(), batchHighest, Colors.orange),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _impersonate(Widget child) => Stack(children: [child, Positioned(bottom: 20, right: 20, child: FloatingActionButton.extended(onPressed: () => setState(() => currentViewMode = "admin"), label: const Text("Exit Preview"), icon: const Icon(Icons.admin_panel_settings), backgroundColor: Colors.redAccent))]);

  Widget _buildBarChart(double s1, double s2, double max) => SizedBox(height: 180, child: BarChart(BarChartData(maxY: max, barGroups: [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: s1, color: Colors.blue, width: 40)]), BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: s2, color: Colors.orange, width: 40)])], titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? "SEC 1" : "SEC 2")))))));

  Widget _buildSectionTable(String title, List<Map<String, dynamic>> data, double topper, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 10), DataTable(headingRowColor: MaterialStateProperty.all(color.withOpacity(0.1)), columns: const [DataColumn(label: Text("Name")), DataColumn(label: Text("EP")), DataColumn(label: Text("%"))], rows: data.map((s) { double p = topper > 0 ? (s['score'] / topper) * 100 : 0; return DataRow(cells: [DataCell(Text(s['name'], style: const TextStyle(fontSize: 11))), DataCell(Text("${s['score']}")), DataCell(Text("${p.toStringAsFixed(1)}%"))]); }).toList())]);

  Widget _performerCard(String title, String name, int score) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold)), Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text("$score EP", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))]));
}





// --- STAFF DASHBOARD ---
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});
  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final _reg = TextEditingController();
  // Renamed default to match your new request
  String activeYear = "First Year"; 
  final Map<String, TextEditingController> _ctrls = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
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
    var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
    if (q.docs.isNotEmpty) {
      var data = q.docs.first.data();
      setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student not found")));
    }
  }

  void _update() async {
    setState(() => _isSaving = true);
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
    setState(() => _isSaving = false);
  }

  // --- VERIFICATION REPORT MODAL ---
  void _showVerificationReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (_, controller) => StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots(),
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

            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Text("${activeYear} VERIFICATION", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text("Reference Topper: ${batchHighest.toInt()} EP", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 30),
                _buildTable("SECTION 1", students.where((s) => s['section'] == "Sec 1").toList(), batchHighest),
                const SizedBox(height: 30),
                _buildTable("SECTION 2", students.where((s) => s['section'] == "Sec 2").toList(), batchHighest),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> data, double topper) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      const SizedBox(height: 10),
      Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {0: FlexColumnWidth(2.5), 1: FlexColumnWidth(0.8), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1.5)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.blue.shade50),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("EP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              Padding(padding: EdgeInsets.all(8), child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            ],
          ),
          ...data.map((s) {
            double p = topper > 0 ? (s['score'] / topper) * 100 : 0;
            bool ok = p >= 40.0;
            return TableRow(children: [
              Padding(padding: EdgeInsets.all(8), child: Text(s['name'], style: const TextStyle(fontSize: 10))),
              Padding(padding: EdgeInsets.all(8), child: Text("${s['score']}", style: const TextStyle(fontSize: 10))),
              Padding(padding: EdgeInsets.all(8), child: Text("${p.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 10))),
              Padding(padding: const EdgeInsets.all(8), child: Text(ok ? "ELIGIBLE" : "NOT ELIGIBLE",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: ok ? Colors.green : Colors.red))),
            ]);
          }),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CIT ECE Staff Portal"), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // DROPDOWN WITH NEW SEMESTER LABELS
          DropdownButton<String>(
            value: activeYear, 
            isExpanded: true,
            items: ["First Year", "THIRD SEMESTER", "FOURTH SEMESTER", "FIFTH SEMESTER", "SIXTH SEMESTER"]
                .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
            onChanged: (v) => setState(() { activeYear = v!; _initControllers(); }),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _showVerificationReport, icon: const Icon(Icons.analytics_outlined), label: const Text("GENERATE VERIFICATION TABLE"))),
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
