import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/job_service.dart';

class JobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  late Future<List<Job>> jobs;
  List<Job> filteredJobs = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    jobs = JobService().fetchJobs();
  }

  void _filterJobs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredJobs = [];
      } else {
        filteredJobs = filteredJobs
            .where((job) =>
                job.title.toLowerCase().contains(query.toLowerCase()) ||
                job.organization.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Recommendations'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: JobSearchDelegate(jobs),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Job>>(
        future: jobs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final jobList = snapshot.data!;
            filteredJobs = jobList;
            return ListView.builder(
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(job.title),
                    subtitle: Text('${job.organization} - ${job.location}'),
                    trailing: IconButton(
                      icon: Icon(Icons.link),
                      onPressed: () {
                        launchUrl(Uri.parse(job.url));
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No jobs available.',
              ),
            );
          }
        },
      ),
    );
  }

  void launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class JobSearchDelegate extends SearchDelegate {
  final Future<List<Job>> jobs;

  JobSearchDelegate(this.jobs);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear,),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Job>>(
      future: jobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final jobList = snapshot.data!;
          final filteredJobs = jobList.where((job) {
            return job.title.toLowerCase().contains(query.toLowerCase()) ||
                job.organization.toLowerCase().contains(query.toLowerCase());
          }).toList();
          return ListView.builder(
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];
              return ListTile(
                title: Text(job.title),
                subtitle: Text('${job.organization} - ${job.location}'),
                trailing: IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    launchUrl(Uri.parse(job.url));
                  },
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No jobs available.'));
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
