import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:ui';

//pages
import '../home/admin_home_screen.dart';
import '../home/commuter_home_screen.dart';
import '../home/driver_home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _commuterFormKey = GlobalKey<FormState>();
  final _driverFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _commuterEmailCtrl = TextEditingController();
  final _commuterPassCtrl = TextEditingController();

  final _driverEmailCtrl = TextEditingController();
  final _driverPassCtrl = TextEditingController();

  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPassCtrl = TextEditingController();

  String _signupRole = 'commuter';
  bool _obscurePassword = true;

  // Temporary hardcoded admin credentials (remove before final git push)
  static const String _tempAdminEmail = 'rkashne@gmail.com';
  static const String _tempAdminPass = '#1212Wawasa';

  // Temporary in-memory registry for local role isolation testing
  final Map<String, Map<String, String>> _tempUsers = {
    'commuter@lookout.ph': {'password': 'password123', 'role': 'commuter'},
    'driver@lookout.ph': {'password': 'password123', 'role': 'driver'},
  };

  @override
  void dispose() {
    _commuterEmailCtrl.dispose();
    _commuterPassCtrl.dispose();
    _driverEmailCtrl.dispose();
    _driverPassCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPassCtrl.dispose();
    super.dispose();
  }

  void _handleLogin({
    required GlobalKey<FormState> formKey,
    required String expectedRole,
    required String rawEmail,
    required String rawPassword,
  }) {
    if (!formKey.currentState!.validate()) return;

    final email = rawEmail.trim().toLowerCase();
    final password = rawPassword.trim();

    // Admin check: pwede login ang admin sa commuter and driver side login boxes
    if (email == _tempAdminEmail && password == _tempAdminPass) {
      _navigateToDashboard('admin');
      return;
    }

    // Standard account lookup
    final account = _tempUsers[email];
    if (account == null || account['password'] != password) {
      _showMessage('Invalid email or password.');
      return;
    }

    // Role isolation:commuter d makalogin sa driver side, driver indi makalogin sa commuter side
    final actualRole = account['role']!;
    if (actualRole != expectedRole) {
      _showMessage(
        'Access denied. This account is registered as a ${actualRole.toUpperCase()}.',
      );
      return;
    }

    _navigateToDashboard(actualRole);
  }

  void _handleSignup() {
    if (!_signupFormKey.currentState!.validate()) return;

    final email = _signupEmailCtrl.text.trim().toLowerCase();
    final password = _signupPassCtrl.text.trim();

    if (email == _tempAdminEmail || _tempUsers.containsKey(email)) {
      _showMessage('Email is already registered.');
      return;
    }

    _tempUsers[email] = {'password': password, 'role': _signupRole};

    _showMessage(
      'Registered as ${_signupRole.toUpperCase()}! You can now log in.',
    );

    _signupNameCtrl.clear();
    _signupEmailCtrl.clear();
    _signupPassCtrl.clear();
  }

  void _navigateToDashboard(String role) {
    Navigator.pushReplacement(
      context,
      role == "commuter"
          ? MaterialPageRoute(builder: (_) => CommuterHomeScreen())
          : role == "driver"
          ? MaterialPageRoute(builder: (_) => DriverHomeScreen())
          : MaterialPageRoute(builder: (_) => AdminHomeScreen()),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Image.asset(
                    'assets/images/lookoutBanner.png',
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.25),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/lookoutLogo.svg',
                          width: 72,
                          height: 72,
                        ),
                        const SizedBox(height: 8),
                        const Text('LookOut!'),
                        const Text('Iloilo City Real-Time PUV Tracker'),
                        const SizedBox(height: 24),
                        const TabBar(
                          tabs: [
                            Tab(text: 'Commuter'),
                            Tab(text: 'Driver'),
                            Tab(text: 'Sign Up'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 360,
                          child: TabBarView(
                            children: [
                              _buildLoginForm(
                                formKey: _commuterFormKey,
                                roleLabel: 'Commuter',
                                expectedRole: 'commuter',
                                emailController: _commuterEmailCtrl,
                                passwordController: _commuterPassCtrl,
                              ),
                              _buildLoginForm(
                                formKey: _driverFormKey,
                                roleLabel: 'Driver',
                                expectedRole: 'driver',
                                emailController: _driverEmailCtrl,
                                passwordController: _driverPassCtrl,
                              ),
                              _buildSignupForm(),
                            ],
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
      ),
    );
  }

  Widget _buildLoginForm({
    required GlobalKey<FormState> formKey,
    required String roleLabel,
    required String expectedRole,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$roleLabel Login'),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (val) => (val == null || !val.contains('@'))
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Enter your password' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _handleLogin(
              formKey: formKey,
              expectedRole: expectedRole,
              rawEmail: emailController.text,
              rawPassword: passwordController.text,
            ),
            child: Text('Log In as $roleLabel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'commuter',
                  label: Text('Commuter'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: 'driver',
                  label: Text('Driver'),
                  icon: Icon(Icons.directions_bus_outlined),
                ),
              ],
              selected: {_signupRole},
              onSelectionChanged: (selection) {
                setState(() => _signupRole = selection.first);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _signupNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (val) => (val == null || !val.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _signupPassCtrl,
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                labelText: 'Password (min 6 chars)',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (val) => (val == null || val.length < 6)
                  ? 'Minimum 6 characters'
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSignup,
              child: Text(
                'Create ${_signupRole == 'commuter' ? 'Commuter' : 'Driver'} Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
