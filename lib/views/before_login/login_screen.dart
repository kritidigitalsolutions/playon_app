import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/custom_text_fields.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController ctr = Get.put(LoginController());

  // Bottom Sheet for Terms & Conditions
  void _showTermsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                "Terms & Conditions",
                style: text24(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    """Welcome to PlayOn App!

These terms and conditions outline the rules and regulations for the use of our application.

1. Terms
By accessing this app, we assume you accept these terms and conditions. Do not continue to use PlayOn App if you do not agree to all of the terms and conditions stated on this page.

2. License
Unless otherwise stated, PlayOn App and/or its licensors own the intellectual property rights for all material on PlayOn App.

3. User Account
When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms.

4. Privacy Policy
Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your personal information.

5. Prohibited Uses
You may not use our app:
- For any unlawful purpose
- To solicit others to perform or participate in any unlawful acts
- To violate any international, federal, provincial or state regulations, rules, laws, or local ordinances
- To infringe upon or violate our intellectual property rights

6. Termination
We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever.

7. Limitation of Liability
In no event shall PlayOn App, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages.

8. Changes to Terms
We reserve the right to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days notice.

9. Contact Us
If you have any questions about these Terms, please contact us at support@playon.com.

Last updated: ${DateTime.now().year}
                    """,
                    style: text24(fontWeight: FontWeight.normal).copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Close Button
              AppButton(
                radius: 8,
                title: "I Understand",
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Sheet for Privacy Policy
  void _showPrivacyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                "Privacy Policy",
                style: text24(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    """Privacy Policy for PlayOn App

Your privacy is critically important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information.

1. Information We Collect
We may collect information about you in a variety of ways:
- Personal Data: Name, phone number, email address
- Usage Data: App usage statistics, preferences
- Device Information: Device type, operating system, unique device identifiers

2. How We Use Your Information
We use the information we collect to:
- Provide, operate, and maintain our app
- Improve, personalize, and expand our app
- Understand and analyze how you use our app
- Develop new products, services, features, and functionality
- Communicate with you for customer service and updates

3. Sharing Your Information
We may share your information with:
- Service providers who assist us in operating our app
- Business partners with your consent
- Legal authorities when required by law

4. Data Security
We use administrative, technical, and physical security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.

5. Your Data Rights
You have the right to:
- Access your personal data
- Correct inaccurate data
- Request deletion of your data
- Object to processing of your data
- Withdraw consent at any time

6. Cookies and Tracking
We may use cookies and similar tracking technologies to track activity on our app and hold certain information.

7. Third-Party Services
Our app may contain links to third-party websites. We are not responsible for the privacy practices of these external sites.

8. Children's Privacy
Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13.

9. Changes to This Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.

10. Contact Us
If you have questions about this Privacy Policy, please contact us at:
Email: privacy@playon.com
Phone: +91-XXXXXXXXXX

Last updated: ${DateTime.now().year}
                    """,
                    style: text24(fontWeight: FontWeight.normal).copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Close Button
              AppButton(
                radius: 8,
                title: "I Understand",
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithImg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: ctr.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Enhanced Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo or Icon
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.sports_cricket,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Main Heading
                      Text(
                        "Get Started",
                        style: text24(
                          fontWeight: FontWeight.bold,
                        ).copyWith(fontSize: 32, height: 1.2),
                      ),

                      const SizedBox(height: 12),

                      // Subheading
                      Text(
                        "Enter your mobile number to continue",
                        style: text24(fontWeight: FontWeight.normal).copyWith(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Mobile Number Input
                  NumberTextField(
                    radius: 8,
                    maxLength: 10,
                    controller: ctr.phoneCtr,
                    hintText: "Enter Your Mobile Number",
                  ),

                  const SizedBox(height: 20),

                  // Continue Button
                  AppButton(
                    radius: 8,
                    title: "Continue",
                    onTap: () {
                      if (ctr.formKey.currentState!.validate()) {
                        Get.toNamed(AppRoutes.otpVerify);
                      }
                    },
                  ),

                  const Spacer(),

                  // Tappable Terms and Privacy
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "By continuing, you agree to our ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showTermsBottomSheet(context),
                            child: Text(
                              "Terms",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            " & ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showPrivacyBottomSheet(context),
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
