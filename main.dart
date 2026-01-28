import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
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

  int _sum(Map<String, dynamic> d, Map<String, int> l) {
    int t = 0;
    l.forEach((k, _) => t += (d[k] ?? 0) as int);
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots(),
      builder: (context, snapAll) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapAll.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            var d = snapshot.data!.data() as Map<String, dynamic>;
            
            int y1 = _sum(d, year1Limits);
            int y2 = _sum(d, year2Limits);
            int y3 = _sum(d, year3Limits);

            int studentTotal = y1 + y2 + y3; 
            int currentEarned = (viewYear == "First Year") ? y1 : (viewYear == "Second Year" ? y1 + y2 : y1 + y2 + y3);
            int currentMax = (viewYear == "First Year") ? 40 : (viewYear == "Second Year" ? 80 : 120);

            double batchHighest = 0;
            double yearHighest = 0;
            Map<String, int> activeLimits = (viewYear == "First Year") ? year1Limits : (viewYear == "Second Year" ? year2Limits : year3Limits);

            for (var doc in snapAll.data!.docs) {
              var sd = doc.data() as Map<String, dynamic>;
              int st = _sum(sd, year1Limits) + _sum(sd, year2Limits) + _sum(sd, year3Limits);
              int yt = _sum(sd, activeLimits);
              if (st > batchHighest) batchHighest = st.toDouble();
              if (yt > yearHighest) yearHighest = yt.toDouble();
            }

            bool isYearEligible = yearHighest > 0 && (_sum(d, activeLimits) >= (yearHighest * 0.5));
            
            // Leadership Roles: Calculate top 50% eligibility for First Year and Second Year
            List<Map<String, dynamic>> allStudentsScores = [];
            int roleCalculationScore = 0;
            String roleTitle = "";
            List<String> activeRoles = [];
            
            if (viewYear == "First Year") {
              for (var doc in snapAll.data!.docs) {
                var sd = doc.data() as Map<String, dynamic>;
                int y1Score = _sum(sd, year1Limits);
                allStudentsScores.add({'name': sd['name'] ?? 'Unknown', 'score': y1Score});
              }
              allStudentsScores.sort((a, b) => b['score'].compareTo(a['score']));
              roleCalculationScore = y1;
              roleTitle = "III SEMESTER LEADERSHIP ROLES";
              activeRoles = year1Roles;
            } else if (viewYear == "Second Year") {
              for (var doc in snapAll.data!.docs) {
                var sd = doc.data() as Map<String, dynamic>;
                int cumulativeScore = _sum(sd, year1Limits) + _sum(sd, year2Limits);
                allStudentsScores.add({'name': sd['name'] ?? 'Unknown', 'score': cumulativeScore});
              }
              allStudentsScores.sort((a, b) => b['score'].compareTo(a['score']));
              roleCalculationScore = y1 + y2;
              roleTitle = "IV SEMESTER LEADERSHIP ROLES";
              activeRoles = year2Roles;
            }
            
            
            int eligibleCount = (allStudentsScores.length / 2).ceil();
            int currentStudentRank = allStudentsScores.indexWhere((s) => s['name'] == (d['name'] ?? '')) + 1;
            bool isLeadershipEligible = (viewYear == "First Year" || viewYear == "Second Year") && currentStudentRank > 0 && currentStudentRank <= eligibleCount;
            int gapToEligibility = isLeadershipEligible ? 0 : (eligibleCount > 0 ? allStudentsScores[eligibleCount - 1]['score'] - roleCalculationScore : 0);

            return Scaffold(
              appBar: AppBar(title: Text("$viewYear Analysis"), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))]),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text("Welcome, ${d['name'] ?? 'Student'}!", textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SegmentedButton<String>(
                    segments: const [ButtonSegment(value: "First Year", label: Text("Y1")), ButtonSegment(value: "Second Year", label: Text("Y2")), ButtonSegment(value: "Third Year", label: Text("Y3"))],
                    selected: {viewYear},
                    onSelectionChanged: (s) => setState(() => viewYear = s.first),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: isYearEligible ? Colors.green : Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isYearEligible ? Icons.check_circle : Icons.error, color: Colors.white),
                          const SizedBox(width: 10),
                          Text("$viewYear Status: ${isYearEligible ? 'ELIGIBLE' : 'NOT ELIGIBLE'}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(color: Colors.blue, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                    const Text("Cumulative Earned Points", style: TextStyle(color: Colors.white)),
                    Text("$currentEarned / $currentMax", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ]))),
                  const Divider(height: 40),
                  if (viewYear == "First Year" || viewYear == "Second Year") ...[
                    Text(roleTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                    const SizedBox(height: 10),
                    Card(
                      color: isLeadershipEligible ? Colors.green.shade50 : Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLeadershipEligible ? "✅ ELIGIBLE FOR ROLES" : "❌ NOT ELIGIBLE",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isLeadershipEligible ? Colors.green.shade700 : Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Rank: $currentStudentRank / ${allStudentsScores.length}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                if (!isLeadershipEligible && gapToEligibility >= 0)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text("Points Needed", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text("+$gapToEligibility EP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (isLeadershipEligible) ...[
                              const SizedBox(height: 12),
                              Divider(color: Colors.green.shade300),
                              const SizedBox(height: 8),
                              Text(
                                "Available Positions: ${activeRoles.length} roles for top ${eligibleCount} students",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Available Roles:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          ...activeRoles.map((role) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(child: Text(role, style: const TextStyle(fontSize: 11))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                  if (viewYear == "Third Year") ...[
                    const Divider(height: 40),
                    const Text("6th Sem Role Eligibility (80% / 70%):", style: TextStyle(fontWeight: FontWeight.bold)), 
                    _eligibilityTile("Chief Coordinator (80%)", studentTotal >= (batchHighest * 0.8)), 
                    _eligibilityTile("Placement Lead (70%)", studentTotal >= (batchHighest * 0.7)), 
                  ],
                  const Divider(height: 40),
                  ...activeLimits.entries.map((e) => ListTile(title: Text(e.key.replaceAll('_', ' ').toUpperCase()), trailing: Text("${d[e.key] ?? 0} / ${e.value}"))),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _eligibilityTile(String label, bool isOk) => ListTile(
    leading: Icon(isOk ? Icons.check_circle : Icons.cancel, color: isOk ? Colors.green : Colors.red),
    title: Text(label),
    trailing: Text(isOk ? "ELIGIBLE" : "NOT ELIGIBLE", style: TextStyle(color: isOk ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
  );
}

// --- ADMIN DASHBOARD ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // NEW: Year Filter State
  String filterYear = "Cumulative (Y1-Y3)";

  // Helper to calculate points based on selected filter
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
    // Determine max points based on filter for the graph and percentage (maintain cumulative logic)
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
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          double s1Sum = 0, s2Sum = 0;
          int s1Count = 0, s2Count = 0;
          
          String s1BestName = "N/A";
          int s1BestScore = -1;
          String s2BestName = "N/A";
          int s2BestScore = -1;

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            int score = _calculatePoints(data, filterYear);
            String name = data['name'] ?? "Unknown";

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

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // YEAR FILTER DROPDOWN
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

              // OVERALL PERCENTAGE CARD
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

              // BEST PERFORMERS ROW
              Row(
                children: [
                  Expanded(
                    child: _performerCard("SEC 1 TOPPER", s1BestName, s1BestScore),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _performerCard("SEC 2 TOPPER", s2BestName, s2BestScore),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // BAR GRAPH
              const Text("SECTION COMPARISON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 280,
                    child: BarChart(
                      BarChartData(
                        maxY: maxPoints,
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: s1Avg,
                                color: Colors.blue.shade600,
                                width: 50,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: s2Avg,
                                color: Colors.orange.shade600,
                                width: 50,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, m) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  v == 0 ? "SECTION 1\n(${s1Count} students)" : "SECTION 2\n(${s2Count} students)",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text("Total Points", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            axisNameSize: 30,
                            sideTitles: const SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxPoints / 4,
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade400, width: 1),
                            left: BorderSide(color: Colors.grey.shade400, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // SECTION COMPARISON DETAILS
              Card(
                color: s1Avg > s2Avg ? Colors.blue.shade50 : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text("Section 1 Average", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("${s1Avg.toStringAsFixed(2)} pts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                          Column(
                            children: [
                              const Text("Section 2 Average", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("${s2Avg.toStringAsFixed(2)} pts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        s1Avg > s2Avg
                            ? "📊 Section 1 is performing better by ${(s1Avg - s2Avg).toStringAsFixed(2)} points"
                            : "📊 Section 2 is performing better by ${(s2Avg - s1Avg).toStringAsFixed(2)} points",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: s1Avg > s2Avg ? Colors.blue.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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

  @override
  void initState() { super.initState(); _initControllers(); }
  void _initControllers() { _ctrls.clear(); _getLimits().forEach((k, _) => _ctrls[k] = TextEditingController()); }
  Map<String, int> _getLimits() => (activeYear == "First Year") ? year1Limits : (activeYear == "Second Year" ? year2Limits : year3Limits);

  void _search() async {
    var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
    if (q.docs.isNotEmpty) {
      var data = q.docs.first.data();
      setState(() => _ctrls.forEach((k, v) => v.text = (data[k] ?? 0).toString()));
    }
  }

  void _update() async {
    Map<String, int> updates = {};
    Map<String, int> currentLimits = _getLimits();
    bool isInvalid = false;
    String errorField = "";

    _ctrls.forEach((k, v) {
      int val = int.tryParse(v.text) ?? 0;
      int maxAllowed = currentLimits[k] ?? 0;
      if (val > maxAllowed) { isInvalid = true; errorField = k.toUpperCase(); }
      updates[k] = val;
    });

    if (isInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $errorField exceeds limit!"), backgroundColor: Colors.red));
      return;
    }

    var q = await FirebaseFirestore.instance.collection('users').where('regNo', isEqualTo: _reg.text.trim()).get();
    if (q.docs.isNotEmpty) {
      await q.docs.first.reference.update(updates);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marks Updated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Portal"), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          DropdownButton<String>(
            value: activeYear, isExpanded: true,
            items: ["First Year", "Second Year", "Third Year"].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
            onChanged: (v) => setState(() { activeYear = v!; _initControllers(); }),
          ),
          const SizedBox(height: 10),
          TextField(controller: _reg, decoration: InputDecoration(labelText: "Student Reg No", suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search), border: const OutlineInputBorder())),
          const Divider(height: 40),
          ..._ctrls.entries.map((e) {
            int max = _getLimits()[e.key] ?? 0;
            return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: e.value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "${e.key.toUpperCase()} (Max: $max)", border: const OutlineInputBorder())));
          }),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _update, child: const Text("UPDATE MARKS"))),
        ]),
      ),
    );
  }
}

