import 'dart:convert';
import 'package:codefusion/config.dart';
import 'package:http/http.dart' as http;

class JobService {
  final String apiUrl = Config.linkedInApiUrl;
  final String apiKey = Config.linkedInApiKey;

  Future<List<Job>> fetchJobs(String location) async {
    final response = await http.get(
      Uri.parse('$apiUrl?location_filter=%22$location%22'),
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