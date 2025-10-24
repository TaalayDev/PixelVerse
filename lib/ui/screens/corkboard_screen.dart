import 'package:flutter/material.dart';

class CorkboardScreen extends StatefulWidget {
  const CorkboardScreen({Key? key}) : super(key: key);

  @override
  State<CorkboardScreen> createState() => _CorkboardScreenState();
}

class _CorkboardScreenState extends State<CorkboardScreen> with SingleTickerProviderStateMixin {
  bool _isPanelOpen = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Documents', 'Photos', 'Notes', 'Links'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      if (_isPanelOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Corkboard
          AnimatedBuilder(
            animation: _widthAnimation,
            builder: (context, child) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * _widthAnimation.value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD2A679),
                    Color(0xFFC19A6B),
                    Color(0xFFB88A57),
                  ],
                ),
                border: Border.all(
                  color: Color.fromARGB(255, 92, 70, 63),
                  width: 20,
                ),
              ),
              child: CustomPaint(
                painter: CorkboardPainter(),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: 80,
                          color: Colors.red.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pin your items here',
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFF5D4037).withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _togglePanel,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D6E63),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPanelOpen ? Icons.close : Icons.folder_open,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Documents Panel
          if (_isPanelOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset((1 - value) * 400, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(-2, 0),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Tab Bar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: _tabs.asMap().entries.map((entry) {
                              int index = entry.key;
                              String tab = entry.value;
                              bool isSelected = _selectedTabIndex == index;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedTabIndex = index;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                                      border: Border(
                                        left: BorderSide(
                                          color: isSelected ? Colors.blue : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getTabIcon(index),
                                          size: 20,
                                          color: isSelected ? Colors.blue : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          tab,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            color: isSelected ? Colors.blue : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Tab Content
                        Expanded(
                          child: _buildTabContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.description;
      case 1:
        return Icons.photo_library;
      case 2:
        return Icons.note;
      case 3:
        return Icons.link;
      default:
        return Icons.folder;
    }
  }

  Widget _buildTabContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildItemCard(
          'Sample ${_tabs[_selectedTabIndex]} 1',
          'Added today',
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          'Sample ${_tabs[_selectedTabIndex]} 2',
          'Added yesterday',
        ),
        const SizedBox(height: 12),
        _buildItemCard(
          'Sample ${_tabs[_selectedTabIndex]} 3',
          'Added 2 days ago',
        ),
      ],
    );
  }

  Widget _buildItemCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class CorkboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB88A57).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw cork texture pattern
    final random = 42; // Seed for consistent pattern
    for (int i = 0; i < 200; i++) {
      final x = (random * i * 7) % size.width;
      final y = (random * i * 13) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
