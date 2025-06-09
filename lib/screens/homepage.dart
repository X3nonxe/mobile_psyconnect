import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:psyconnect/blocs/auth/auth_bloc.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/models/user_model.dart';
import 'package:psyconnect/screens/profile_screen.dart';
import 'package:psyconnect/screens/psycholog-screen/consultation_management_screen.dart';
import 'package:psyconnect/screens/psycholog-screen/home_screen_psycholog.dart';
import 'package:psyconnect/screens/psycholog-screen/message_all_tab_psycholog.dart';
import 'package:psyconnect/screens/psycholog-screen/profile_psycholog_screen.dart';
import 'package:psyconnect/screens/schedule_screen.dart';
import 'package:psyconnect/screens/user-screen/dashboard_screen_user.dart';
import 'package:psyconnect/widgets/tab-bar-pages/message_tab_all.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedPageIndex = 0;

  List<Widget> _buildPages(User? user) {
    return [
      user?.role == 'psychologist'
          ? const PsychologistDashboard()
          : const DashboardScreen(),
      user?.role == 'psychologist'
          ? const MessageTabAllPsycholog()
          : const MessageTabAllClient(),
      user?.role == 'psychologist'
          ? ConsultationManagementScreen()
          : const SheduleScreen(),
      user?.role == 'psychologist'
          ? const ProfilePsychologScreen()
          : const ClientProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: IndexedStack(
              index: _selectedPageIndex,
              children: _buildPages(state.user),
            ),
            bottomNavigationBar: AnimatedBottomNavigationBar(
              icons: const [
                FontAwesomeIcons.home,
                FontAwesomeIcons.envelope,
                FontAwesomeIcons.clipboardCheck,
                FontAwesomeIcons.user,
              ],
              iconSize: 20,
              activeIndex: _selectedPageIndex,
              height: 80,
              splashSpeedInMilliseconds: 300,
              gapLocation: GapLocation.none,
              activeColor: bluePrimaryColor,
              inactiveColor: const Color.fromARGB(255, 223, 219, 219),
              onTap: (index) => setState(() => _selectedPageIndex = index),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
