import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rutsnrides_admin/core/common_wid/widget.dart';
import 'package:rutsnrides_admin/core/theme/app_theme.dart';
import 'package:rutsnrides_admin/feature/auth/controller/auth_controller.dart';


class SignInWidget extends StatelessWidget {
  const SignInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.enquiryPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: AppTheme.enquiryPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Admin Portal",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.enquiryPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Username Field
          Text(
            "Username",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: controller.usernameController,
            hintText: "Enter your username",
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 20),

          // Password Field
          Text(
            "Password",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomTextField(
              controller: controller.passwordController,
              hintText: "Enter your password",
              prefixIcon: Icons.lock_outline,
              obscureText: !controller.showPassword.value,
              suffixIcon: IconButton(
                onPressed: () {
                  controller.showPassword.value =
                      !controller.showPassword.value;
                },
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppTheme.enquiryPrimary.withOpacity(0.7),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Remember me & Forgot password
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         Obx(
          //           () => Checkbox(
          //             value: controller.rememberMe.value,
          //             onChanged: (value) {
          //               controller.rememberMe.value = value ?? false;
          //             },
          //             activeColor: AppTheme.enquiryPrimary,
          //           ),
          //         ),
          //         Text(
          //           "Remember me",
          //           style: theme.textTheme.bodyMedium?.copyWith(
          //             color: Colors.grey[700],
          //           ),
          //         ),
          //       ],
          //     ),
          //     // TextButton(
          //     //   onPressed: () {
          //     //     // Add forgot password functionality
          //     //     _showForgotPasswordDialog(context);
          //     //   },
          //     //   child: Text(
          //     //     "Forgot Password?",
          //     //     style: theme.textTheme.bodyMedium?.copyWith(
          //     //       color: AppTheme.enquiryPrimary,
          //     //       fontWeight: FontWeight.w500,
          //     //     ),
          //     //   ),
          //     // ),

          //   ],
          // ),
          const SizedBox(height: 24),

          // Sign In Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.loginLoad.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.enquiryPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: controller.loginLoad.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        "Sign In",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "or",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),

          const SizedBox(height: 24),

          // Alternative sign in options
          Center(
            child: Text(
              "Contact administrator for access",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
