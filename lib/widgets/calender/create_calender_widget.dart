import 'package:flutter/material.dart';


class CreateCalenderWidget extends StatefulWidget {

  @override
  State<CreateCalenderWidget> createState() => _CreateCalenderWidgetState();

  const CreateCalenderWidget(
      {super.key});
}

class _CreateCalenderWidgetState extends State<CreateCalenderWidget> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String year = _yearController.text;
      final String name = _nameController.text;

      // Beispiel: Ausgabe der Eingaben in der Konsole
      print('Year: $year, Name: $name');

      // Zeigen Sie eine Snackbar mit den Eingabewerten an
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Year: $year, Name: $name')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Eingabe für YEAR
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Neuen Kalender erstellen", style: TextStyle(fontSize: 20),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a year';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              // Eingabe für NAME
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Schaltfläche zum Übermitteln
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    ),);
  }
}
