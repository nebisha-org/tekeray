import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekeray/main.dart'; // Import main.dart to navigate to PropertyBrowseScreen

// Define a key for our SharedPreferences flag
const String HAS_SEEN_WELCOME_KEY = 'hasSeenWelcome';
const String USER_ROLE_KEY = 'userRole'; // To store 'tenant' or 'landlord'

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Function to set the user role and navigate
  Future<void> _setUserRoleAndNavigate(
    BuildContext context,
    String role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ROLE_KEY, role); // Store the chosen role
    await prefs.setBool(
      HAS_SEEN_WELCOME_KEY,
      true,
    ); // Mark welcome screen as seen

    // For now, we navigate to PropertyBrowseScreen regardless of role.
    // In the future, you might navigate to a different initial screen for landlords.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PropertyBrowseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.home_work,
                  size: 120,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to Tekeray!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'How would you like to use the app?',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => _setUserRoleAndNavigate(context, 'tenant'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'I am a Tenant (Browse Properties)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _setUserRoleAndNavigate(context, 'landlord'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueGrey.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white70, width: 1),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'I am a Landlord (List Properties)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
