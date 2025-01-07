import 'package:flutter/material.dart';

class JobPreferenceForm extends StatefulWidget {
  @override
  _JobPreferenceFormState createState() => _JobPreferenceFormState();
}

class _JobPreferenceFormState extends State<JobPreferenceForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedDomain = 'Web Development';
  String selectedRole = '';
  String selectedPackage = '';
  String selectedLocation = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Preference Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Select Job Domain:'),
              DropdownButton<String>(
                value: selectedDomain,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDomain = newValue!;
                  });
                },
                items: <String>['Web Development', 'App Development', 'AI/ML', 'DevOps']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Preferred Role'),
                onSaved: (value) => selectedRole = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Preferred Package'),
                onSaved: (value) => selectedPackage = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (value) => selectedLocation = value!,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // Send the data to the next screen or API
                      Navigator.pushNamed(context, '/job-list', arguments: {
                        'domain': selectedDomain,
                        'role': selectedRole,
                        'package': selectedPackage,
                        'location': selectedLocation,
                      });
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
