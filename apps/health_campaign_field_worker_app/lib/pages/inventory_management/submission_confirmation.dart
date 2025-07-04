
// import 'package:flutter/material.dart';

// class SubmissionConfirmationScreen extends StatelessWidget {
//   const SubmissionConfirmationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: DigitAppBar(title: const Text('Submission Complete')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Your data has been submitted successfully!',
//               style: TextStyle(fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             DigitElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/view-transactions'),
//               child: const Text('View Transactions'),
//             ),
//             const SizedBox(height: 12),
//             DigitElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/stock-details'),
//               child: const Text('Continue'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
