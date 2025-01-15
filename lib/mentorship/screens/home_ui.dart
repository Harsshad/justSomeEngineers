import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MentorshipPage extends StatefulWidget {
  const MentorshipPage({super.key});

  @override
  _MentorshipPageState createState() => _MentorshipPageState();
}

class _MentorshipPageState extends State<MentorshipPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mentorship',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search for mentors',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('Technology'),
                  _filterChip('Design'),
                  _filterChip('Product'),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Harsshad Sivsharan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Senior Product Designer at Google'),
                trailing: IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () {
                    // Add favorite functionality here
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    '5',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ratingBar(5, 80),
                        _ratingBar(4, 20),
                        _ratingBar(3, 0),
                        _ratingBar(2, 0),
                        _ratingBar(1, 0),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.work, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  _sectionTitle('Experience'),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '10 sessions available\n'
                'I’ve been a designer for over 10 years and have worked in companies such as Google, Airbnb, and Facebook. I can help you with your design career, portfolio, and interview preparation.',
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  _sectionTitle('Availability'),
                ],
              ),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add booking functionality here
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12,),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary
                ),
                child:  Text('Book mentorship',style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _ratingBar(int stars, int percentage) {
    return Row(
      children: [
        Text(stars.toString()),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage / 100,
            color: Colors.blue,
            backgroundColor: Colors.grey[300],
          ),
        ),
        const SizedBox(width: 8),
        Text('$percentage%'),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}


/*
Dont delete this

When designing a login and registration flow for mentors, it's important to consider the specific needs and functionalities they will require to provide their services effectively. Below is a detailed breakdown of the UI, fields, and functionalities that mentors should see after logging in:

Mentor Login/Registration Flow
Registration Fields for Mentors:

Basic Information:
Full Name
Email Address
Password
Profile Picture Upload
Professional Details:
Current Role/Position
Years of Experience
Areas of Expertise (e.g., Flutter, Firebase, DSA, etc.)
LinkedIn Profile URL
Portfolio/Website URL (optional)
Availability:
Available Time Slots (daily/weekly calendar)
Preferred Communication Modes (Video, Chat, Email)
Rate Information (if mentors are paid):
Hourly Rate
Free/Paid Mentorship
Bio:
Short bio or a summary of their professional journey.
Login:

Email and Password
Option to log in via Google or LinkedIn (for easy onboarding).
Mentor Dashboard After Login
UI Sections and Functionalities
Profile Section:

View/Edit profile details.
Update availability (calendar integration).
Manage payment details (if applicable, like connecting to Stripe or PayPal).
Visibility toggle: Public (users can find them) or Private.
Session Management:

Current Sessions:
List of ongoing or scheduled mentorship sessions.
View session details (topic, mentee, date/time, mode).
Completed Sessions:
Past session history, with mentee feedback and notes.
Session Scheduling:
Option to set custom time slots for availability.
Integration with Google Calendar or other calendar tools for scheduling.
Mentee Interaction:

Chat/Messaging System:
In-app chat with mentees.
Notifications for new messages.
Video Call Options:
Start video calls directly from the platform.
Integration with tools like Zoom, Google Meet, or WebRTC.
Task Assignments:
Assign small tasks or exercises to mentees and track their progress.
File Sharing:
Share documents, code snippets, or resources directly through the platform.
Knowledge Sharing:

Resources Upload:
Upload learning materials (PDFs, links, videos).
Blog Writing:
Write articles on specific topics and share with mentees.
FAQs:
Create a list of frequently asked questions based on mentees' queries.
Review and Feedback System:

Mentee Reviews:
View feedback and ratings from mentees.
Option to respond to reviews.
Self-Evaluation:
Analyze the performance of sessions and areas for improvement.
Mentorship Impact Stats:
Number of mentees mentored, total sessions conducted, average feedback score.
Earnings Dashboard (if applicable):

Earning Summary:
Total earnings, payouts, and pending amounts.
Payment History:
Track payments from mentees.
Invoices:
Generate and share invoices for paid mentorships.
Notifications and Alerts:

Notifications for session bookings, cancellations, or reschedules.
Reminders for upcoming sessions.
Mentor Community:

Discussion Forums:
Collaborate with other mentors.
Share insights or tips on mentoring.
Events and Webinars:
Participate in or host mentorship-related events.
Additional Features for Mentors
Mentee Profiles:

View mentees' profiles with their goals, skills, and progress.
Match mentors with mentees based on areas of expertise.
Analytics Dashboard:

View insights about their mentorship activities.
Mentee satisfaction rates and areas where mentees need more help.
Support and FAQs:

Access to mentorship guidelines and tips.
Dedicated support channel for mentors.
Example Mentor Dashboard UI
Top Navigation Bar:

Sections: Dashboard | Sessions | Messages | Earnings | Profile
Sidebar (if applicable):

Quick Links: Calendar | Notifications | Settings | Help
Main Dashboard:

Quick Stats:
Upcoming Sessions: 3
Mentees: 10
Rating: 4.8/5
Next Session Card:
Mentee: John Doe
Topic: Flutter Basics
Time: Today at 3 PM
Calendar View:
Visualize available slots and scheduled sessions.

*/