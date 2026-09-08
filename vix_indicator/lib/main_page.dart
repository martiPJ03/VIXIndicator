import 'package:flutter/material.dart';
import './screens/thresholds_page.dart';
import './screens/vix_home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    VixHomePage(title: 'Vix Indicator'),
    ThresholdsPage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavigationTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Thresholds',
          ),
        ],
      ),
    );
  }
}