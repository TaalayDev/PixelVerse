import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets.dart';
import 'about_screen.dart';
import 'pixel_draw_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final List<Project> _projects = [];
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _generateDummyProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _generateDummyProjects() {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      _projects.add(Project(
        id: 'project_$i',
        name: 'Project ${i + 1}',
        width: random.nextInt(32) + 16,
        height: random.nextInt(32) + 16,
        color: Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      drawer: _buildDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout();
          } else {
            return _buildTabletDesktopLayout();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewProject(context),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          elevation: _isScrolled ? 4 : 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'PixelVerse Projects',
              style: TextStyle(
                color: _isScrolled ? Colors.white : Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            background: _buildAppBarBackground(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: AdaptiveProjectGrid(projects: _projects, isFirstOpen: true),
        ),
      ],
    );
  }

  Widget _buildTabletDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: _buildDrawer(),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverAppBar(
                title: Text('PixelVerse Projects'),
                pinned: true,
                leading: SizedBox.shrink(),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: AdaptiveProjectGrid(
                  projects: _projects,
                  isFirstOpen: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://picsum.photos/id/237/1000/1000'),
              fit: BoxFit.cover,
            ),
          ),
          child: Text(
            'PixelVerse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AboutScreen(),
            ));
            // Navigate to about page
          },
        ),
      ],
    );
  }

  Widget _buildAppBarBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://picsum.photos/id/237/1000/1000',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToNewProject(BuildContext context) async {
    final result = await showDialog<({String name, int width, int height})>(
      context: context,
      builder: (BuildContext context) => const NewProjectDialog(),
    );

    if (result != null && context.mounted) {
      final newProject = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PixelDrawScreen(
            id: 'new_project',
            name: result.name,
            width: result.width,
            height: result.height,
          ),
        ),
      );
    }
  }
}

class AdaptiveProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final bool isFirstOpen;

  const AdaptiveProjectGrid({
    super.key,
    required this.projects,
    required this.isFirstOpen,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    var count = 2;
    if (size.width < 600) {
      count = 2;
    } else if (size.width < 1200) {
      count = 4;
    } else {
      count = 6;
    }

    return _buildGrid(crossAxisCount: count);
  }

  Widget _buildGrid({required int crossAxisCount}) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: ProjectTile(project: projects[index]),
              ),
            ),
          );
        },
        childCount: projects.length,
      ),
    );
  }
}

class Project {
  final String id;
  final String name;
  final int width;
  final int height;
  final Color color;

  Project({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.color,
  });
}

class ProjectTile extends StatelessWidget {
  final Project project;

  const ProjectTile({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PixelDrawScreen(
              id: project.id,
              name: project.name,
              width: project.width,
              height: project.height,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: project.color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: project.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: PixelGridPainter(
                width: project.width,
                height: project.height,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Center(
              child: Text(
                project.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Text(
                '${project.width}x${project.height}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelGridPainter extends CustomPainter {
  final int width;
  final int height;
  final Color color;

  PixelGridPainter({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final cellWidth = size.width / width;
    final cellHeight = size.height / height;

    for (int i = 1; i < width; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }

    for (int i = 1; i < height; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
