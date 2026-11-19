import 'package:final_project_look_out/widgets/lookout_app_bar.dart';
import 'package:final_project_look_out/widgets/lookout_bottom_nav.dart';
import 'package:final_project_look_out/widgets/lookout_drawer.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (
      Scaffold(
        appBar: const LookOutAppBar(
          title: 'Admin Dashboard', //replace with the actual title.
        ),

        drawer: const LookOutDrawer(
          header: SizedBox.shrink(),
          items: [],
        ),

        bottomNavigationBar: const LookOutBottomNav(),

        body: const Center(
          child: Text("this is Admin")
        )
      )
    );
  }
}
