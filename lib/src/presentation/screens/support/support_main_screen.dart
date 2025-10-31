import 'package:flutter/material.dart';
import 'package:gsloution_mobile/src/presentation/screens/support/support_sections/ongoing_discussion_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/support/support_sections/support_faq_question_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/support/support_sections/support_header_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/support/support_sections/support_section.dart';

class SupportMainScreen extends StatelessWidget {
  const SupportMainScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70,
        child: Column(
          children: [
            const SupportHeaderSection(),
            Expanded(
                child: ListView(
              children: const [
                SupportSection(),
                SizedBox(
                  height: 50,
                ),
                OngoingDiscussionSection(),
                SizedBox(
                  height: 50,
                ),
                SupportFaqQuestionSection(),
                SizedBox(
                  height: 20,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
