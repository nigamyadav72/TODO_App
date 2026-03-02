import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/decorative_background.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "let's start",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Illustration with floating elements
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main Character
                    Container(
                      height: 320,
                      width: 280,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('https://ouch-cdn2.icons8.com/mO3hVl9w-bB7m8Vj-asA9m9n0Bv1r-zP-n3G8NqU1Qo/rs:fit:368:368/czM6Ly9pY29uczgu/b3VjaC1wcm9kLnNp/Z25hdHVyZS83ZTM5/MTkzOC00MDUzLTRj/OTEtYWRmNS0yYmE1/YjBlMzViOWYucG5n'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Floating Elements (Simulated with Icons)
                    _buildFloatingIcon(Icons.timer_outlined, -120, -100, Colors.redAccent),
                    _buildFloatingIcon(Icons.calendar_today, 120, -80, Colors.blueAccent),
                    _buildFloatingIcon(Icons.notifications_none, -100, 100, Colors.orangeAccent),
                    _buildFloatingIcon(Icons.pie_chart_outline, 110, 80, Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  'Task Management &\nTo-Do List',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 26,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This productive tool is designed to help you better manage your task project-wise conveniently!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Let\'s Start', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, double x, double y, Color color) {
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

