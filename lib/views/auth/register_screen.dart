import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleRegister() async {
    if (_usernameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      debugPrint('Signup success');
      // No Navigator.pop() needed
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Email might already exist.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Create Account',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign up to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 50),
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Sign Up'),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
