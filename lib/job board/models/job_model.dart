class Job {
  final String id;
  final String title;
  final String organization;
  final String organizationUrl;
  final String jobUrl;
  final String organizationLogo;
  final String location;
  final String salary;
  final String employmentType;
  final String source;
  final String sourceDomain;
  final String sourceType;

  Job({
    required this.id,
    required this.title,
    required this.organization,
    required this.organizationUrl,
    required this.jobUrl,
    required this.organizationLogo,
    required this.location,
    required this.salary,
    required this.employmentType,
    required this.source,
    required this.sourceDomain,
    required this.sourceType,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      organizationUrl: json['organization_url'] ?? '',
      jobUrl: json['url'] ?? '',
      organizationLogo: json['organization_logo'] ?? '',
      location: json['locations_raw'] ?? 'Not specified',
      salary: json['salary_raw'] ?? 'Not disclosed',
      employmentType: json['employment_type'] ?? 'Not specified',
      source: json['source'] ?? 'Unknown',
      sourceDomain: json['source_domain'] ?? 'Unknown',
      sourceType: json['source_type'] ?? 'Unknown',
    );
  }
}
