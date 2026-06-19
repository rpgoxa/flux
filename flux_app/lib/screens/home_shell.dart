import 'package:flutter/material.dart';

import 'package:flux_app/widgets/flux_app_bar.dart';
import 'package:flux_app/widgets/flux_bottom_nav.dart';
import 'package:flux_app/screens/app_settings_screen.dart';
import 'package:flux_app/screens/record_home_screen.dart';
import 'package:flux_app/screens/video_gallery_screen.dart';

/// Root scaffold holding the three primary tabs and shared chrome.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  FluxTab _tab = FluxTab.record;

  static const _pages = [
    RecordHomeScreen(),
    VideoGalleryScreen(),
    AppSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const FluxAppBar(),
            Expanded(
              child: IndexedStack(
                index: _tab.index,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FluxBottomNav(
        current: _tab,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
