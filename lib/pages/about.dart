import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color(0xFFFFD700);
    const darkYellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryYellow.withOpacity(0.1),
                          const Color(0xFF121212),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryYellow, darkYellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryYellow.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 50,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Info Section
                      _buildSection(
                        title: 'App Information',
                        icon: Icons.mobile_friendly,
                        child: _buildAppInfoCard(),
                      ),

                      const SizedBox(height: 24),

                      // Developer Section
                      _buildSection(
                        title: 'Meet the Developers',
                        icon: Icons.code,
                        child: _buildDevelopersSection(),
                      ),

                      const SizedBox(height: 24),

                      // Features Section
                      _buildSection(
                        title: 'Key Features',
                        icon: Icons.star,
                        child: _buildFeaturesSection(),
                      ),

                      const SizedBox(height: 24),

                      // Contact & Support
                      _buildSection(
                        title: 'Contact & Support',
                        icon: Icons.support_agent,
                        child: _buildContactSection(),
                      ),

                      const SizedBox(height: 24),

                      // Legal Section
                      _buildSection(
                        title: 'Legal',
                        icon: Icons.gavel,
                        child: _buildLegalSection(),
                      ),

                      const SizedBox(height: 40),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    const primaryYellow = Color(0xFFFFD700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: primaryYellow,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apps,
                  color: Color(0xFF121212),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MyApp Pro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 2.1.0 (Build 210)',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'A powerful and intuitive mobile application designed to enhance your productivity and streamline your daily tasks. Built with cutting-edge technology and user-centric design principles.',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip('Released', 'Jan 2024'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip('Size', '45.2 MB'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip('Category', 'Productivity'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopersSection() {
    final developers = [
      {
        'name': 'Alex Johnson',
        'role': 'Lead Developer & UI/UX Designer',
        'avatar': Icons.person,
        'description':
            'Full-stack developer with 8+ years of experience in mobile app development. Passionate about creating intuitive user experiences.',
        'skills': ['Flutter', 'Dart', 'Firebase', 'UI/UX'],
      },
      {
        'name': 'Sarah Chen',
        'role': 'Backend Developer',
        'avatar': Icons.person_outline,
        'description':
            'Backend specialist focused on scalable architecture and API development. Expert in cloud technologies and database optimization.',
        'skills': ['Node.js', 'Python', 'AWS', 'MongoDB'],
      },
      {
        'name': 'Mike Rodriguez',
        'role': 'Mobile App Developer',
        'avatar': Icons.person_2,
        'description':
            'Mobile development enthusiast with expertise in cross-platform solutions. Committed to performance optimization and clean code.',
        'skills': ['Flutter', 'React Native', 'Swift', 'Kotlin'],
      },
    ];

    return Column(
      children: developers.map((dev) => _buildDeveloperCard(dev)).toList(),
    );
  }

  Widget _buildDeveloperCard(Map<String, dynamic> developer) {
    const primaryYellow = Color(0xFFFFD700);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: primaryYellow.withOpacity(0.2),
                child: Icon(
                  developer['avatar'] as IconData,
                  color: primaryYellow,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      developer['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      developer['role'] as String,
                      style: const TextStyle(
                        color: primaryYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            developer['description'] as String,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (developer['skills'] as List<String>).map((skill) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryYellow.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: primaryYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    const primaryYellow = Color(0xFFFFD700);

    final features = [
      {
        'icon': Icons.speed,
        'title': 'Lightning Fast',
        'description': 'Optimized performance for smooth user experience'
      },
      {
        'icon': Icons.security,
        'title': 'Secure & Private',
        'description': 'Your data is protected with end-to-end encryption'
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Cloud Sync',
        'description': 'Seamlessly sync across all your devices'
      },
      {
        'icon': Icons.offline_bolt,
        'title': 'Offline Ready',
        'description': 'Works perfectly even without internet connection'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: primaryYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactSection() {
    const primaryYellow = Color(0xFFFFD700);

    final contacts = [
      {
        'icon': Icons.email,
        'title': 'Email Support',
        'value': 'support@myapp.com'
      },
      {'icon': Icons.web, 'title': 'Website', 'value': 'www.myapp.com'},
      {
        'icon': Icons.bug_report,
        'title': 'Report Bugs',
        'value': 'bugs@myapp.com'
      },
      {
        'icon': Icons.star,
        'title': 'Rate Us',
        'value': 'App Store / Play Store'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: contacts.map((contact) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  contact['icon'] as IconData,
                  color: primaryYellow,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['value'] as String,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildLegalItem('Privacy Policy', Icons.privacy_tip),
          const SizedBox(height: 12),
          _buildLegalItem('Terms of Service', Icons.description),
          const SizedBox(height: 12),
          _buildLegalItem('Open Source Licenses', Icons.code),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, IconData icon) {
    const primaryYellow = Color(0xFFFFD700);

    return GestureDetector(
      onTap: () {
        // Handle navigation to legal documents
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryYellow,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[600],
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[700],
        ),
        const SizedBox(height: 20),
        Text(
          '© 2024 MyApp Pro. All rights reserved.',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ❤️ by the MyApp Team',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
