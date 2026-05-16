import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Premium animated splash screen with Atomberg branding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _progressWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)),
    );

    _progressWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.85, curve: Curves.easeInOut)),
    );

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        context.go('/role-select');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Stack(
        children: [
          // Ambient glow
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.03),
              ),
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.surfaceVariant,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A1F2937),
                                blurRadius: 32,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lightbulb_outlined,
                            size: 48,
                            color: AppColors.primaryContainer,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Progress line
                        SizedBox(
                          width: 48,
                          height: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressWidth.value,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryContainer,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'AtomQuest Hackathon 1.0',
                          style: AppTypography.headlineLgMobile.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeIn,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'POWERED BY ',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'ATOMBERG',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
