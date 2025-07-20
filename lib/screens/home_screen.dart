// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Import the AuthService to handle signing out
import 'receipt_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Dummy analytics data
    final int totalReceipts = 12;
    final double totalSpent = 2450.75;
    final int expiringWarranties = 2;
    final int recurringPayments = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RASEED Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${currentUser?.displayName ?? currentUser?.email ?? 'User'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AnalyticsTile(label: 'Receipts', value: '$totalReceipts'),
                    _AnalyticsTile(label: 'Spent', value: '₹$totalSpent'),
                    _AnalyticsTile(label: 'Warranties', value: '$expiringWarranties'),
                    _AnalyticsTile(label: 'Recurring', value: '$recurringPayments'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Receipts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: totalReceipts,
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.teal),
                  title: Text('Receipt #${i + 1}'),
                  subtitle: Text('Amount: ₹${(totalSpent / totalReceipts).toStringAsFixed(2)}'),
                  trailing: Text('2025-07-${10 + i}'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => ReceiptForm(
              onSubmit: (data) {
                // TODO: Save receipt to Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Receipt added: ${data['title']}')),
                );
              },
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 32),
        tooltip: 'Add Receipt',
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Receipts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Recurring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: 'Warranty',
          ),
        ],
        onTap: (index) {
          // TODO: Implement navigation to respective screens
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recurring Payments')));
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chatbot')));
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expiry/Warranty')));
          }
        },
      ),
    );
  }
}

class _AnalyticsTile extends StatelessWidget {
  final String label;
  final String value;
  const _AnalyticsTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

