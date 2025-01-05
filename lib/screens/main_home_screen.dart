import 'package:flutter/material.dart';

import '../utils/colors.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'CodeFusion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: backgroundColor,
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  const Text(
                    'CodeFusion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Home'),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pushNamed(context, '/main-home');
              },
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              title: const Text('Meet & Chat'),
              leading: const Icon(Icons.group),
              onTap: () {
                Navigator.pushNamed(context, '/meet-home');
              },
            ),
            ListTile(
              title: const Text('Ques & Ans'),
              leading: const Icon(Icons.forum_outlined),
              onTap: () {
                Navigator.pushNamed(context, '/que-answer');
              },
            ),
            ListTile(
              title: const Text('Mentorship'),
              leading: const Icon(Icons.school_rounded),
              onTap: () {
                Navigator.pushNamed(context, '/mentorship');
              },
            ),
            ListTile(
              title: const Text('Resources'),
              leading: const Icon(Icons.menu_book_rounded),
              onTap: () {
                Navigator.pushNamed(context, '/resources');
              },
            ),
            ListTile(
              title: const Text('Job Recommendations'),
              leading: const Icon(Icons.business_center_rounded),
              onTap: () {
                Navigator.pushNamed(context, '/job-recommend');
              },
            ),
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.pushNamed(context, '/job-recommend');
              },
            ),
            const ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: null,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          SearchBar(),
          SizedBox(height: 20),
          SectionTitle(title: 'Personalized for you'),
          SizedBox(height: 10),
          PersonalizedCards(),
          SizedBox(height: 20),
          SectionTitle(title: 'Notifications'),
          SizedBox(height: 10),
          NotificationList(),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search jobs, forums, projects',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class PersonalizedCards extends StatelessWidget {
  const PersonalizedCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CompanyCard(
            imagePath: 'assets/images/google.png',
            companyName: 'Google',
            jobCount: '1,200+ software engineer jobs',
          ),
          CompanyCard(
            imagePath: 'assets/images/facebook.png',
            companyName: 'Facebook',
            jobCount: '1,000+ developer jobs',
          ),
          CompanyCard(
            imagePath: 'assets/images/amazon.png',
            companyName: 'Amazon',
            jobCount: '900+ developer jobs',
          ),
        ],
      ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final String imagePath;
  final String companyName;
  final String jobCount;

  const CompanyCard({
    Key? key,
    required this.imagePath,
    required this.companyName,
    required this.jobCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 16.0),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              companyName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              jobCount,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        NotificationTile(
          title: 'New job post from Google',
          subtitle:
              'Software Engineer - University Graduate, Leading with AI team',
          time: '10min',
        ),
        NotificationTile(
          title: 'New job post from Facebook',
          subtitle: 'Software Engineer - University Grad, Infrastructure',
          time: '20min',
        ),
        NotificationTile(
          title: 'New job post from Amazon',
          subtitle: 'Software Development Engineer I, Prime Video',
          time: '30min',
        ),
      ],
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const NotificationTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_none),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
