

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:fl_chart/fl_chart.dart'; // Required for the graph

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIT Dept ECE Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

// --- EVALUATION POINT LIMITS ---
final Map<String, int> year1Limits = {
  'workshop_pts': 4, 'nptel_pts': 6, 'volProject_pts': 6, 'classRep_pts': 4, 
  'linkedin_pts': 4, 'discipline_pts': 6, 'symposium_pts': 6, 'higherStudies_pts': 2, 'noArrears_pts': 2
}; 

final Map<String, int> year2Limits = {
  'mini_project_pts': 10, 'leadership_pts': 10, 'network_exposure_pts': 10, 
  'hackathon_prize_pts': 8, 'no_arrears_y2_pts': 2
}; 

final Map<String, int> year3Limits = {
  'internship_pts': 5, 'coe_project_pts': 5, 'bootcamp_org_pts': 5, 'mock_interview_org_pts': 5, 
  'expert_connections_pts': 5, 'alumni_testimonials_pts': 5, 'no_arrears_y3_pts': 5, 'conf_publication_pts': 5
}; 

// --- LEADERSHIP ROLES (III SEMESTER) ---
final List<String> year1Roles = [
  'Class Representative',
  'CoE Student Volunteer',
  'Event Lead (II Year)',
  'Documentation & Report Lead',
  'Digital Media Lead',
  'Alumni Relations Coordinator',
  'Coding Club Secretary',
  'Placement Coordinator (Training)',
];

// --- LEADERSHIP ROLES (IV SEMESTER - 4th SEM) ---
final List<String> year2Roles = [
  'Class Representative',
  'Class Committee Member',
  'CoE Student Volunteer (IoT / Coding Club In-charge / Secretary)',
  'Event Lead (Department / Symposium with Seniors)',
  'IV Coordinator',
  'Placement Coordinator – Training Programs',
  'Alumni Relations Coordinator',
  'Documentation & Report Lead',
  'Digital Media Lead (IoT lab & 5G centre LinkedIn page maintenance)',
];

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.purple.shade600,
              Colors.deepPurple.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(children: [
              const Icon(Icons.school, size: 80, color: Colors.white),
              const Text("CIT ECE LOGIN", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: "Email ID",
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.email, color: Colors.white70),
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
              const SizedBox(height: 20),
              TextField(
                controller: _pass,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
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
                          child: const Text("LOGIN", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      TextButton(
                        onPressed: _resetPassword,
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// --- STUDENT DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  final String uid;
  const StudentDashboard({super.key, required this.uid});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String viewYear = "First Year";

  // Helper function to sum points based on current year limits
  int _sum(Map<String, dynamic> d, Map<String, int> l) {
    int t = 0;
    l.forEach((k, _) => t += (d[k] ?? 0) as int);
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // 1. Get ALL students to find the batch topper (reference)
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots(),
      builder: (context, snapAll) {
        return StreamBuilder<DocumentSnapshot>(
          // 2. Get the specific logged-in student's data
          stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapAll.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            
            var d = snapshot.data!.data() as Map<String, dynamic>;
            
            // Current student's individual totals
            int y1 = _sum(d, year1Limits);
            int y2 = _sum(d, year2Limits);
            int y3 = _sum(d, year3Limits);

            // --- FIX START: DECLARE AND CALCULATE TOPPERS ---
            double topperY1 = 0;   // III Sem Selection Reference
            double topperY12 = 0;  // IV Sem Selection Reference
            double topperY123 = 0; // VI Sem Selection Reference
            double topperGrand = 0;// VII Sem Strategic Reference

            for (var doc in snapAll.data!.docs) {
              var sd = doc.data() as Map<String, dynamic>;
              int s1 = _sum(sd, year1Limits);
              int s2 = _sum(sd, year2Limits);
              int s3 = _sum(sd, year3Limits);

              if (s1 > topperY1) topperY1 = s1.toDouble();
              if ((s1 + s2) > topperY12) topperY12 = (s1 + s2).toDouble();
              if ((s1 + s2 + s3) > topperY123) topperY123 = (s1 + s2 + s3).toDouble();
              if ((s1 + s2 + s3) > topperGrand) topperGrand = (s1 + s2 + s3).toDouble();
            }
            // --- FIX END ---

            // Configuration based on active selection from your framework
            Map<String, double> roleThresholds = {};
            double currentRef = 0;
            int studentScore = 0;
            String headerTitle = "";

            if (viewYear == "First Year") {
              roleThresholds = {
                'Class Representative': 0.4, 'CoE Student Volunteer': 0.4,
                'Event Lead (II Year)': 0.4, 'Doc & Report Lead': 0.4,
                'Digital Media Lead': 0.4, 'Alumni Relations Coord': 0.4,
                'Coding Club Secretary': 0.6, 'Placement Coord (Training)': 0.6,
              };
              currentRef = topperY1; studentScore = y1; headerTitle = "III SEMESTER ELIGIBILITY";
            } else if (viewYear == "Second Year") {
              roleThresholds = {
                'Class Representative': 0.4, 'Class Committee Member': 0.4,
                'CoE Student Volunteer (IoT)': 0.6, 'IV Coordinator': 0.6,
                'Placement Coordinator': 0.6, 'Digital Media Lead': 0.6,
              };
              currentRef = topperY12; studentScore = y1 + y2; headerTitle = "IV SEMESTER SELECTION";
            } else {
              roleThresholds = {
                'Chief Student Coordinator': 0.8, 'Hackathon Secretary': 0.8,
                'Placement Coordinator (Core)': 0.7, 'CoE Student Lead': 0.7,
                'Chief Placement Coordinator (Strategic)': 0.8,
              };
              currentRef = topperGrand; studentScore = y1 + y2 + y3; headerTitle = "FINAL YEAR STRATEGIC ROLES";
            }

            Map<String, int> activeLimits = (viewYear == "First Year") ? year1Limits : (viewYear == "Second Year" ? year2Limits : year3Limits);

            return Scaffold(
              appBar: AppBar(title: Text("$viewYear Analysis"), actions: [
                IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))
              ]),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text("Welcome, ${d['name']}!", textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: "First Year", label: Text("Y1")),
                      ButtonSegment(value: "Second Year", label: Text("Y2")),
                      ButtonSegment(value: "Third Year", label: Text("Y3")),
                    ],
                    selected: {viewYear},
                    onSelectionChanged: (s) => setState(() => viewYear = s.first),
                  ),
                  const SizedBox(height: 20),

                  Text(headerTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text("Batch Topper Reference: ${currentRef.toInt()} EP", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),

                  ...roleThresholds.entries.map((role) {
                    double target = currentRef * role.value;
                    bool isOk = studentScore >= target;
                    double gap = target - studentScore;

                    return Card(
                      color: isOk ? Colors.green.shade50 : Colors.orange.shade50,
                      child: ListTile(
                        dense: true,
                        leading: Icon(isOk ? Icons.stars : Icons.lock_outline, color: isOk ? Colors.green : Colors.orange),
                        title: Text(role.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Criteria: ${(role.value * 100).toInt()}% of Highest"),
                            if (!isOk) Text("Need: ${gap.toStringAsFixed(1)} EP more", style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Text(isOk ? "QUALIFIED" : "LOCKED", style: TextStyle(color: isOk ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                    );
                  }).toList(),

                  const Divider(height: 40),
                  const Text("YEARLY ACTIVITY BREAKDOWN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...activeLimits.entries.map((e) => ListTile(
                    dense: true,
                    title: Text(e.key.replaceAll('_', ' ').toUpperCase()),
                    trailing: Text("${d[e.key] ?? 0} / ${e.value}"),
                  )),
                ],
              ),
            );
          },
        );
      },
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
  String filterYear = "Cumulative (Y1-Y3)";

  int _calculatePoints(Map<String, dynamic> d, String filter) {
    int total = 0;
    if (filter == "First Year" || filter == "Cumulative (Y1-Y3)") {
      year1Limits.forEach((k, _) => total += (d[k] ?? 0) as int);
    }
    if (filter == "Second Year" || filter == "Cumulative (Y1-Y3)") {
      year2Limits.forEach((k, _) => total += (d[k] ?? 0) as int);
    }
    if (filter == "Third Year" || filter == "Cumulative (Y1-Y3)") {
      year3Limits.forEach((k, _) => total += (d[k] ?? 0) as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double maxPoints = filterYear == "First Year" ? 40 : (filterYear == "Second Year" ? 80 : 120);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Batch Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Maintains original document order from Firestore/CSV import
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          double s1Sum = 0, s2Sum = 0;
          int s1Count = 0, s2Count = 0;
          String s1BestName = "N/A";
          int s1BestScore = -1;
          String s2BestName = "N/A";
          int s2BestScore = -1;

          List<Map<String, dynamic>> allStudents = [];
          double batchHighest = 0;

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            int score = _calculatePoints(data, filterYear);
            String name = data['name'] ?? "Unknown";

            if (score > batchHighest) batchHighest = score.toDouble();

            allStudents.add({
              'name': name,
              'regNo': data['regNo'] ?? "N/A",
              'score': score,
              'section': data['section'] ?? "Sec 1",
            });

            if (data['section'] == "Sec 1") {
              s1Sum += score;
              s1Count++;
              if (score > s1BestScore) { s1BestScore = score; s1BestName = name; }
            } else {
              s2Sum += score;
              s2Count++;
              if (score > s2BestScore) { s2BestScore = score; s2BestName = name; }
            }
          }

          double s1Avg = s1Count > 0 ? s1Sum / s1Count : 0;
          double s2Avg = s2Count > 0 ? s2Sum / s2Count : 0;
          double overallPercent = ((s1Avg + s2Avg) / 2) / maxPoints * 100;

          // Define Eligibility Buckets based on framework percentages
          var elite80 = allStudents.where((s) => s['score'] >= (batchHighest * 0.8) && batchHighest > 0).toList();
          var strategic70 = allStudents.where((s) => s['score'] >= (batchHighest * 0.7) && s['score'] < (batchHighest * 0.8)).toList();
          var functional60 = allStudents.where((s) => s['score'] >= (batchHighest * 0.6) && s['score'] < (batchHighest * 0.7)).toList();
          var standard40 = allStudents.where((s) => s['score'] >= (batchHighest * 0.4) && s['score'] < (batchHighest * 0.6)).toList();

          // Segregate for Section-wise tables (Maintains order within each section)
          var sec1List = allStudents.where((s) => s['section'] == "Sec 1").toList();
          var sec2List = allStudents.where((s) => s['section'] == "Sec 2").toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<String>(
                  value: filterYear,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ["Cumulative (Y1-Y3)", "First Year", "Second Year", "Third Year"]
                      .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (v) => setState(() => filterYear = v!),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                color: Colors.blue.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(children: [
                    Text("AVERAGE CLASS SCORE ($filterYear)", style: const TextStyle(color: Colors.white70)),
                    Text("${overallPercent.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _performerCard("SEC 1 TOPPER", s1BestName, s1BestScore)),
                  const SizedBox(width: 10),
                  Expanded(child: _performerCard("SEC 2 TOPPER", s2BestName, s2BestScore)),
                ],
              ),
              const SizedBox(height: 30),

              const Text("SECTION COMPARISON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        maxY: maxPoints,
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: s1Avg, color: Colors.blue.shade600, width: 40)]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: s2Avg, color: Colors.orange.shade600, width: 40)]),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? "SEC 1" : "SEC 2"))),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const Divider(height: 50),
              const Text("ROLE ELIGIBILITY VERIFICATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              const SizedBox(height: 10),
              _eligibilityGroup("ELITE TIER (>=80%)", "Qualified for Chief Roles", elite80, Colors.amber),
              _eligibilityGroup("STRATEGIC TIER (>=70%)", "Qualified for Placement Leads", strategic70, Colors.deepPurple),
              _eligibilityGroup("FUNCTIONAL TIER (>=60%)", "Qualified for Club/CoE Leads", functional60, Colors.blue),
              _eligibilityGroup("FOUNDATION TIER (>=40%)", "Qualified for Class Reps", standard40, Colors.green),

              const Divider(height: 50),
              
              // NEW SECTION: SECTION 1 ORDERED TABLE
              const Text("SECTION 1 MARKS (CSV ORDER)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              const SizedBox(height: 10),
              _buildOrderedTable(sec1List, batchHighest),

              const SizedBox(height: 40),

              // NEW SECTION: SECTION 2 ORDERED TABLE
              const Text("SECTION 2 MARKS (CSV ORDER)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
              const SizedBox(height: 10),
              _buildOrderedTable(sec2List, batchHighest),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderedTable(List<Map<String, dynamic>> students, double topper) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Total EP")),
          DataColumn(label: Text("%")),
          DataColumn(label: Text("Status")),
        ],
        rows: students.map((s) {
          double p = topper > 0 ? (s['score'] / topper) * 100 : 0;
          return DataRow(cells: [
            DataCell(Text(s['name'], style: const TextStyle(fontSize: 12))),
            DataCell(Text("${s['score']}")),
            DataCell(Text("${p.toStringAsFixed(1)}%")),
            DataCell(Text(
              p >= 40.0 ? "ELIGIBLE" : "NOT ELIGIBLE",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: p >= 40.0 ? Colors.green : Colors.red,
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _performerCard(String title, String name, int score) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
        Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("$score EP", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _eligibilityGroup(String title, String subtitle, List<Map<String, dynamic>> students, Color color) {
    return ExpansionTile(
      leading: Icon(Icons.verified_user, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      children: students.isEmpty 
        ? [const ListTile(title: Text("No students in this tier", style: TextStyle(fontSize: 12, color: Colors.grey)))]
        : students.map((s) => ListTile(
            title: Text(s['name'], style: const TextStyle(fontSize: 13)),
            subtitle: Text("Reg: ${s['regNo']} | ${s['section']}", style: const TextStyle(fontSize: 11)),
            trailing: Text("${s['score']} EP", style: const TextStyle(fontWeight: FontWeight.bold)),
          )).toList(),
    );
  }
}
// --- STAFF DASHBOARD ---
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});
  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final _reg = TextEditingController();
  String activeYear = "First Year";
  final Map<String, TextEditingController> _ctrls = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _ctrls.clear();
    _getLimits().forEach((k, _) => _ctrls[k] = TextEditingController());
  }

  Map<String, int> _getLimits() => (activeYear == "First Year")
      ? year1Limits
      : (activeYear == "Second Year" ? year2Limits : year3Limits);

  // Core Point Calculation Logic
  int _calculateCumulativePoints(Map<String, dynamic> d, String year) {
    int total = 0;
    year1Limits.forEach((k, _) => total += (d[k] ?? 0) as int);
    if (year != "First Year") year2Limits.forEach((k, _) => total += (d[k] ?? 0) as int);
    if (year == "Third Year") year3Limits.forEach((k, _) => total += (d[k] ?? 0) as int);
    return total;
  }

  // --- MARKS ENTRY (WRITE ACCESS) ---
  void _search() async {
    var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
    if (q.docs.isNotEmpty) {
      var data = q.docs.first.data();
      setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student not found")));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $errorField exceeds point limit!"), backgroundColor: Colors.red));
      setState(() => _isSaving = false);
      return;
    }

    var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
    if (q.docs.isNotEmpty) {
      await q.docs.first.reference.update(updates);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marks Updated!")));
    }
    setState(() => _isSaving = false);
  }

  // --- VERIFICATION REPORT (READ ACCESS) ---
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
            // 1. Identify topper based on cumulative selection
            for (var doc in snapshot.data!.docs) {
              int s = _calculateCumulativePoints(doc.data() as Map<String, dynamic>, activeYear);
              if (s > batchHighest) batchHighest = s.toDouble();
            }

            // 2. Process data in Firestore/CSV order
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
                Text("$activeYear VERIFICATION TABLE", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
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
        columnWidths: const {
          0: FlexColumnWidth(2.5), 1: FlexColumnWidth(0.8), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1.5)
        },
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
            double percentage = topper > 0 ? (s['score'] / topper) * 100 : 0;
            bool isEligible = percentage >= 40.0; // Base leadership threshold

            return TableRow(children: [
              Padding(padding: EdgeInsets.all(8), child: Text(s['name'], style: const TextStyle(fontSize: 10))),
              Padding(padding: EdgeInsets.all(8), child: Text("${s['score']}", style: const TextStyle(fontSize: 10))),
              Padding(padding: EdgeInsets.all(8), child: Text("${percentage.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 10))),
              Padding(padding: const EdgeInsets.all(8), child: Text(
                isEligible ? "ELIGIBLE" : "NOT ELIGIBLE",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isEligible ? Colors.green.shade700 : Colors.red.shade700),
              )),
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
          DropdownButton<String>(
            value: activeYear, isExpanded: true,
            items: ["First Year", "Second Year", "Third Year"].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
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

