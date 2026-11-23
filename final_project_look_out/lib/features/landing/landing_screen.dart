//updated to connect to firestore - Joshua

import 'dart:ui';

//firebase
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//services
import '../../services/auth_service.dart';

// Pages
import '../home/admin_home_screen.dart';
import '../home/commuter_home_screen.dart';
import '../home/driver_home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _authService = AuthService();

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

  // LOGIN
  void _handleLogin({
    required GlobalKey<FormState> formKey,
    required String expectedRole,
    required String rawEmail,
    required String rawPassword,
  }) async {
    if (!formKey.currentState!.validate()) return;

    final email = rawEmail.trim().toLowerCase();
    final password = rawPassword.trim();

    try{

      final userData = await _authService.login(
        email: email,
        password: password,
        loginTab: expectedRole
      );

      if(!mounted) return;

      if(userData == null)
      {
        await _authService.signOut();
        _showMessage("User Not FOund");
        return;
      }

      final String actualRole = userData['role'] ?? 'commuter';

      if(actualRole != 'admin' && actualRole != expectedRole)
      {
        _showMessage("Wrong login tab. This account is registered as${actualRole.toUpperCase()}");
      }

      _navigateToDashboard(actualRole);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } catch (e) {
      if (!mounted) return;
      _showMessage('Login failed. Please try again.');
    }
  }

  // SIGN UP
  void _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    try {
      await _authService.signUp(
        email: _signupEmailCtrl.text.trim(),
        password: _signupPassCtrl.text.trim(),
        fullName: _signupNameCtrl.text.trim(),
        role: _signupRole,
      );

      await _authService.signOut();

      if (!mounted) return;
      _showMessage(
        'Registered as ${_signupRole.toUpperCase()}! You can now log in.',
      );

      _signupNameCtrl.clear();
      _signupEmailCtrl.clear();
      _signupPassCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    }
  }

  // NAVIGATION
  void _navigateToDashboard(String role) {
    Navigator.pushReplacement(
      context,
      role == 'commuter'
          ? MaterialPageRoute(builder: (_) => CommuterHomeScreen())
          : role == 'driver'
          ? MaterialPageRoute(builder: (_) => DriverHomeScreen())
          : MaterialPageRoute(builder: (_) => AdminHomeScreen()),
    );
  }

  // NOTIFICATION
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(text)),
    );
  }

  // REUSABLE INPUT DECORATION
  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Stack(
          children: [
            // BLURRED BACKGROUND
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

            // BACKGROUND OVERLAY
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.primary.withValues(alpha: 0.12),
                      colors.surface.withValues(alpha: 0.90),
                    ],
                  ),
                ),
              ),
            ),

            // MAIN CONTENT
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        // APP LOGO
                        SvgPicture.asset(
                          'assets/images/lookoutLogo.svg',
                          width: 90,
                          height: 90,
                        ),

                        const SizedBox(height: 12),

                        // APP NAME
                        Text(
                          'LookOut!',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Iloilo City Real-Time PUV Tracker',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // AUTHENTICATION CARD
                        Card(
                          elevation: 4,
                          color: colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  'Welcome!',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'Log in or create an account to get started.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),

                                const SizedBox(height: 20),

                                // TABS
                                TabBar(
                                  labelColor: colors.onPrimaryContainer,
                                  unselectedLabelColor: colors.onSurfaceVariant,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  dividerColor: Colors.transparent,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  tabs: const [
                                    Tab(text: 'Commuter'),
                                    Tab(text: 'Driver'),
                                    Tab(text: 'Sign Up'),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // TAB CONTENT
                                SizedBox(
                                  height: 390,
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

                        const SizedBox(height: 24),

                        // FOOTER
                        Text(
                          'Made for Iloilo City',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
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

  // LOGIN FORM
  Widget _buildLoginForm({
    required GlobalKey<FormState> formKey,
    required String roleLabel,
    required String expectedRole,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$roleLabel Login',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Enter your account details to continue.',
            style: theme.textTheme.bodySmall,
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              context,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            validator: (val) => (val == null || !val.contains('@'))
                ? 'Enter a valid email'
                : null,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration:
                _inputDecoration(
                  context,
                  label: 'Password',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Enter your password' : null,
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _handleLogin(
                formKey: formKey,
                expectedRole: expectedRole,
                rawEmail: emailController.text,
                rawPassword: passwordController.text,
              ),
              child: Text(
                'Log In as $roleLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SIGNUP FORM
  Widget _buildSignupForm() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create an Account',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Choose your account type and enter your details.',
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 16),

            // ROLE SELECTION
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
                setState(() {
                  _signupRole = selection.first;
                });
              },
            ),

            const SizedBox(height: 16),

            // FULL NAME
            TextFormField(
              controller: _signupNameCtrl,
              decoration: _inputDecoration(
                context,
                label: 'Full Name',
                icon: Icons.badge_outlined,
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Enter your name'
                  : null,
            ),

            const SizedBox(height: 12),

            // EMAIL
            TextFormField(
              controller: _signupEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                context,
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              validator: (val) => (val == null || !val.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),

            const SizedBox(height: 12),

            // PASSWORD
            TextFormField(
              controller: _signupPassCtrl,
              obscureText: _obscurePassword,
              decoration:
                  _inputDecoration(
                    context,
                    label: 'Password (min 6 chars)',
                    icon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
              validator: (val) => (val == null || val.length < 6)
                  ? 'Minimum 6 characters'
                  : null,
            ),

            const SizedBox(height: 20),

            // CREATE ACCOUNT BUTTON
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSignup,
                child: Text(
                  'Create ${_signupRole == 'commuter' ? 'Commuter' : 'Driver'} Account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
