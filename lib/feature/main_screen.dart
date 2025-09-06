import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/storage/local_storage.dart';
import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/core/utils/utils.dart';
import 'package:rutsnrides_admin/feature/auth/controller/auth_controller.dart';
import 'package:rutsnrides_admin/feature/booking/view/booking_page.dart';
import 'package:rutsnrides_admin/feature/enquiry/view/enquiry_page.dart';
import 'package:rutsnrides_admin/feature/ongoing/view/attandance_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<CategoryItem> categories = [
    CategoryItem("Enquiry", Icons.question_answer, AppTheme.enquiryPrimary),
    // CategoryItem("Follow Up", Icons.update, Colors.orange[700]!),
    CategoryItem("Booking", Icons.book_online, AppTheme.bookingPrimary),
    CategoryItem("Ongoing", Icons.timelapse, AppTheme.ongoingPrimary),
  ];

  var controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showLogoutConfirmation();
            },
            icon: Icon(Icons.logout),
          ),
        ],
        title: const Text(
          'Ruts N Rides',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),

        elevation: 0,
        // backgroundColor: Colors.transparent,
        // foregroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return CategoryWid(category: categories[index]);
          },
        ),
      ),
    );
  }

  void showLogoutConfirmation() {
    Get.defaultDialog(
      title: "Confirm Logout",
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      content: Text(
        "Are you sure you want to logout?",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.enquirySecondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () async {
          // showSuccess("You have been successfully logged out.");

          await controller.logout(context);
        },
        child: Text("Yes, Logout"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
      ),
      backgroundColor: Colors.white,
      radius: 8,
    );
  }
}

class CategoryItem {
  final String title;
  final IconData icon;
  final Color color;

  CategoryItem(this.title, this.icon, this.color);
}

class CategoryWid extends StatelessWidget {
  final CategoryItem category;
  const CategoryWid({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
          if (category.title == "Enquiry") {
            Get.to(() => EnquiryPage());
          } else if (category.title == "Booking") {
            Get.to(() => BookingPage());
          } else if (category.title == "Ongoing") {
            Get.to(() => AttendanceScreen());
          }
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: category.color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   'Tap To View', // You can replace this with dynamic data
              //   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
