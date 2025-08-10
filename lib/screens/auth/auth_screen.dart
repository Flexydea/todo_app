// lib/screens/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/user_model.dart';
import 'package:todo_app/providers/profile_photo_provider.dart';
import 'package:todo_app/screens/home_tabs_screen.dart';
import 'package:todo_app/utils/auth_reset.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late final TabController _tab;
  final Color green =
      const Color.fromARGB(255, 6, 117, 11); // Tailwind-ish green

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          isDark ? const Color(0xFFF8FAF9) : const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Top curved banner
          Positioned.fill(
            child: Column(
              children: [
                _CurvedTop(
                    color: isDark
                        ? const Color.fromARGB(255, 6, 117, 11)
                        : const Color.fromARGB(255, 6, 117, 11)),
                const Spacer(),
                _CurvedBottom(
                    color: isDark
                        ? const Color.fromARGB(255, 6, 117, 11)
                        : const Color.fromARGB(255, 6, 117, 11)),
              ],
            ),
          ),

          // Card content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 8,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tab bar
                        Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withOpacity(.04),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TabBar(
                              controller: _tab,
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  width: 5.0, // Thickness of the underline
                                  color: Colors.green, // Color of the underline
                                ),
                                insets: EdgeInsets.symmetric(
                                    horizontal: 16.0), // Padding from tab edges
                              ),
                              labelColor: Colors.green, // Active tab text color
                              unselectedLabelColor:
                                  isDark ? Colors.white70 : Colors.black87,
                              labelStyle: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold), // Active tab style
                              unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.normal),
                              tabs: const [
                                Tab(text: 'Sign In'),
                                Tab(text: 'Sign Up'),
                              ],
                            )),
                        const SizedBox(height: 18),

                        // Forms
                        SizedBox(
                          height: 338, // enough space for keyboard on phones
                          child: TabBarView(
                            controller: _tab,
                            children: const [
                              _SignInForm(),
                              _SignUpForm(),
                            ],
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
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  double _strength = 0.0;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _updateStrength(String v) {
    var s = 0.0;
    if (v.length >= 6) s += .25;
    if (RegExp(r'[A-Z]').hasMatch(v)) s += .25;
    if (RegExp(r'[0-9]').hasMatch(v)) s += .25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) s += .25;
    setState(() => _strength = s.clamp(0.0, 1.0));
  }

  Color _strengthColor() {
    if (_strength < .25) return Colors.red;
    if (_strength < .5) return Colors.orange;
    if (_strength < .75) return Colors.amber;
    return Colors.green;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      // Ensure boxes are open
      final userBox = Hive.isBoxOpen('userBox')
          ? Hive.box<User>('userBox')
          : await Hive.openBox<User>('userBox');

      final settingsBox = Hive.isBoxOpen('settingsBox')
          ? Hive.box('settingsBox')
          : await Hive.openBox('settingsBox');

      final email = _email.text.trim().toLowerCase();

      // 1) Check duplicate email
      final exists = userBox.values.any(
        (u) => u.email.trim().toLowerCase() == email,
      );
      if (exists) {
        _toast('Email already registered');
        return;
      }

      // 2) Create user object
      final user = User(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      // 3) Save user; get numeric key
      final int userKey = await userBox.add(user);

      // 4) Persist "logged in" user key in settingsBox
      await settingsBox.put('currentUser', userKey);
      await settingsBox.put('displayName', user.name);
      await settingsBox.delete('profileImageBytes');
      await resetAppDataForNewUser(context);

      _toast('Account created!');

      if (!mounted) return;
      context.read<ProfilePhotoProvider>().loadForCurrentUser();

      // 5) Go to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeTabsScreen()),
        (route) => false,
      );
    } catch (e) {
      _toast('Sign up failed. Please try again.');
      debugPrint('Sign up error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            )),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          const SizedBox(height: 12),
          Text('Create an account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: 18),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
              if (!ok) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            onChanged: _updateStrength,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Create a password';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _strength == 0 ? null : _strength,
              minHeight: 6,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(.25),
              color: _strengthColor(),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 6, 117, 11),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sign Up',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 1) Validate form
    if (!_form.currentState!.validate()) return;

    // 2) Start loading + clear any old snackbars
    setState(() => _loading = true);
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      // 3) Open boxes (idempotent if already open)
      final userBox = Hive.isBoxOpen('userBox')
          ? Hive.box<User>('userBox')
          : await Hive.openBox<User>('userBox');

      final settingsBox = Hive.isBoxOpen('settingsBox')
          ? Hive.box('settingsBox')
          : await Hive.openBox('settingsBox');

      final email = _email.text.trim().toLowerCase();
      final pwd = _password.text.trim();

      // 4) Look up a matching user (email + password)
      MapEntry<dynamic, User>? entry;
      try {
        entry = userBox.toMap().entries.firstWhere((e) {
          final u = e.value;
          return u is User &&
              u.email.trim().toLowerCase() == email &&
              u.password == pwd;
        });
      } catch (_) {
        entry = null; // none found
      }

      // 5) Invalid credentials -> stop spinner and exit
      if (entry == null) {
        if (mounted) setState(() => _loading = false); // <-- stop spinner
        _toast('Invalid credentials');
        return;
      }

      // 6) Persist logged-in user key + name for UI
      final int newUserKey = entry.key as int;
      final int? prevUserKey = settingsBox.get('currentUser') as int?;
      await settingsBox.put('currentUser', newUserKey);
      await settingsBox.put('displayName', entry.value.name);

      // 7) If the account CHANGED, wipe per-user data and avatar bytes
      if (prevUserKey == null || prevUserKey != newUserKey) {
        await resetAppDataForNewUser(context); // clears tasks/reminders/etc.
        await settingsBox.delete('profileImageBytes'); // clear previous avatar
      }

      // 8) (Optional) Load this user's photo path/bytes if you store per-user
      if (mounted) {
        context.read<ProfilePhotoProvider>().loadForCurrentUser();
      }

      _toast('Welcome back!');

      // 9) Navigate to home
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Any unexpected error
      _toast('Sign in failed. Please try again.');
      debugPrint('Sign in error: $e');
    } finally {
      // 10) Always stop the spinner unless we've already navigated
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            )),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color.fromARGB(255, 6, 117, 11);

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          const SizedBox(height: 12),
          Text('Welcome back!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: 18),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
              if (!ok) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch.adaptive(
                  value: _remember,
                  activeColor: green,
                  onChanged: (v) => setState(() => _remember = v)),
              const SizedBox(width: 6),
              const Text('Remember me'),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Forgot?')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sign In',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// Decorative shapes
class _CurvedTop extends StatelessWidget {
  final Color color;
  const _CurvedTop({required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TopClipper(),
      child: Container(height: 220, color: color),
    );
  }
}

class _CurvedBottom extends StatelessWidget {
  final Color color;
  const _CurvedBottom({required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomClipper(),
      child: Container(height: 100, color: color),
    );
  }
}

class _TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 40);
    p.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height - 40);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, 40);
    p.quadraticBezierTo(size.width * 0.5, 0, size.width, 40);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
