// forgot_password_tabs.dart
import 'package:flutter/material.dart';
import 'package:psyconnect/widgets/tab-bar-pages/first_tab.dart';
import 'package:psyconnect/widgets/tab-bar-pages/second_tab.dart';

class ForgotPasswordTabs extends StatelessWidget {
  final TabController tabController;

  const ForgotPasswordTabs({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 235, 235, 235)),
          color: const Color.fromARGB(255, 241, 241, 241),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                indicatorColor: const Color.fromARGB(255, 241, 241, 241),
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.blue, // Gantilah dengan warna yang sesuai
                controller: tabController,
                tabs: const [
                  Tab(text: "Email"),
                  Tab(text: "Phone"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: const [FirstTab(), SecondTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
