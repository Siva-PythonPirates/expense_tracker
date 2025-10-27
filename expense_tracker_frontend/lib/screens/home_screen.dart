import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'expenses_screen.dart';
import 'analytics_screen.dart';
import 'scan_receipt_screen.dart';
import 'login_screen.dart';
import 'backend_setup_screen.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    const ExpensesScreen(),
    const AnalyticsScreen(),
  ];

  final List<IconData> _icons = [
    Icons.receipt_long_rounded,
    Icons.analytics_rounded,
  ];

  final List<String> _labels = [
    'Expenses',
    'Analytics',
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _fabController.forward().then((_) => _fabController.reverse());
  }

  void _scanReceipt() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ScanReceiptScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _selectedIndex == 0
                    ? isDark
                        ? [
                            const Color(0xFF1a1a2e),
                            const Color(0xFF16213e),
                          ]
                        : [
                            const Color(0xFF6C5CE7),
                            const Color(0xFFA29BFE),
                          ]
                    : isDark
                        ? [
                            const Color(0xFF2d1b3d),
                            const Color(0xFF3d2645),
                          ]
                        : [
                            const Color(0xFFfd79a8),
                            const Color(0xFFFFA07A),
                          ],
              ),
            ),
            height: 220,
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar with Profile Menu
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _labels[_selectedIndex],
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Track your spending',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      // Profile Dropdown Menu
                      ProfileMenu(
                        username: authService.currentUser?.username ?? 'User',
                        onLogout: () async {
                          await authService.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                
                // Screen Content
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Modern Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7))
                            .withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _icons[index],
                        color: isSelected
                            ? (isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7))
                            : (isDark ? Colors.grey[400] : Colors.grey),
                        size: 26,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          _labels[index],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      
      // Scan Receipt FAB
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.9).animate(_fabController),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF8B7FE8), const Color(0xFFB8B1FF)]
                  : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7))
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _scanReceipt,
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
            label: Text(
              'Scan Receipt',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Profile Menu Widget
class ProfileMenu extends StatefulWidget {
  final String username;
  final VoidCallback onLogout;
  final bool isDark;

  const ProfileMenu({
    super.key,
    required this.username,
    required this.onLogout,
    required this.isDark,
  });

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  bool _isMenuOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isMenuOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenu,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: 220,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(-170, size.height + 10),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: widget.isDark ? const Color(0xFF1e1e2e) : Colors.white,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.isDark
                                  ? [const Color(0xFF8B7FE8), const Color(0xFFB8B1FF)]
                                  : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.username[0].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.username,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Manage Account',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menu Items
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              // Theme Toggle
                              Consumer<ThemeService>(
                                builder: (context, themeService, _) {
                                  return InkWell(
                                    onTap: () {
                                      themeService.toggleTheme();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            themeService.isDarkMode
                                                ? Icons.light_mode_rounded
                                                : Icons.dark_mode_rounded,
                                            size: 22,
                                            color: widget.isDark ? Colors.white70 : Colors.black87,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              themeService.isDarkMode ? 'Light Mode' : 'Dark Mode',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: widget.isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: themeService.isDarkMode
                                                  ? const Color(0xFF8B7FE8)
                                                  : const Color(0xFF6C5CE7),
                                            ),
                                            child: AnimatedAlign(
                                              alignment: themeService.isDarkMode
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              duration: const Duration(milliseconds: 200),
                                              child: Container(
                                                width: 18,
                                                height: 18,
                                                margin: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.dns_rounded,
                                label: 'Change Backend IP',
                                onTap: () {
                                  _closeMenu();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BackendSetupScreen(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              _buildMenuItem(
                                icon: Icons.logout_rounded,
                                label: 'Logout',
                                onTap: () {
                                  _closeMenu();
                                  widget.onLogout();
                                },
                                isDestructive: true,
                              ),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive
                  ? Colors.red[400]
                  : (widget.isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDestructive
                    ? Colors.red[400]
                    : (widget.isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.username[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
