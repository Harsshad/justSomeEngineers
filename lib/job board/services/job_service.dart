import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  final String apiUrl = 'https://linkedin-jobs-api2.p.rapidapi.com/active-jb-24h';
  final String apiKey = '4963218ba4msh00c741ebb5d3a2bp1e0993jsna299d674c8ab';

  Future<List<Job>> fetchJobs(String title, String location) async {
    final response = await http.get(
      Uri.parse('$apiUrl?title_filter="$title"&location_filter=$location'),
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'linkedin-jobs-api2.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((job) => Job.fromJson(job)).toList();
    } else {
      print('Failed to load jobs: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load jobs');
    }
  }
}

class Job {
  final String title;
  final String organization;
  final String location;
  final String url;

  Job({
    required this.title,
    required this.organization,
    required this.location,
    required this.url,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'],
      organization: json['organization'],
      location: json['locations_derived']?.join(', ') ?? '',
      url: json['url'],
    );
  }
}
