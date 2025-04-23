import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seddoapp/widgets/publieform2.dart';

class PubliePage extends StatefulWidget {
  const PubliePage({Key? key}) : super(key: key);

  @override
  State<PubliePage> createState() => _PubliePageState();
}

class _PubliePageState extends State<PubliePage> {
  int _currentStep = 1;
  int _activeTabIndex = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  List<String> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    _availabilityController.dispose();
    _priceController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Publications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTabIndex = 0;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _activeTabIndex == 0
                                ? Colors.black
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Publier',
                          style: TextStyle(
                            color:
                                _activeTabIndex == 0
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTabIndex = 1;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _activeTabIndex == 1
                                ? Colors.black
                                : const Color.fromARGB(251, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Historique',
                          style: TextStyle(
                            color:
                                _activeTabIndex == 1
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Step indicator - Only 2 steps
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
            child: Row(
              children: [
                // Step 1 circle
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _currentStep >= 1 ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: _currentStep >= 1 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Line
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    height: 2,
                    color: _currentStep >= 2 ? Colors.green : Colors.grey[300],
                  ),
                ),
                // Step 2 circle
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _currentStep >= 2 ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: _currentStep >= 2 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form content - changes based on current step
          Expanded(
            child:
                _activeTabIndex == 0
                    ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child:
                          _currentStep == 1
                              ? _buildStep1Form()
                              : _buildStep2Form(),
                    )
                    : const Center(child: Text('Historique des publications')),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),

            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            style: TextStyle(
              fontSize: 11,
            ), // ← Style appliqué à l'élément sélectionné
            decoration: InputDecoration(
              hintText: 'Sélectionnez la catégorie',
              hintStyle: TextStyle(fontSize: 11), // ← Style du hint
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            items:
                ['catégorie 1', 'catégorie 2', 'catégorie 3']
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 11,
                          ), // ← Style des items de la liste
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              setState(() {
                // _selectedSubCategory = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Sub-category Field
        Row(
          children: [
            const Text(
              'Sous-catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),

            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            style: TextStyle(
              fontSize: 11,
            ), // ← Style appliqué à l'élément sélectionné
            decoration: InputDecoration(
              hintText: 'Sélectionnez la sous-catégorie',
              hintStyle: TextStyle(fontSize: 11), // ← Style du hint
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            items:
                ['Sous-catégorie 1', 'Sous-catégorie 2', 'Sous-catégorie 3']
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 11,
                          ), // ← Style des items de la liste
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              setState(() {
                // _selectedSubCategory = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        // Title Field
        Row(
          children: [
            const Text(
              'Titre',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),

            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Entrez le titre de la publication',
              hintStyle: TextStyle(fontSize: 11),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Description Field
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Ecrivez quelque chose...',
              hintStyle: TextStyle(fontSize: 11),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Location Field
        Row(
          children: [
            const Text(
              'Lieu de récupération',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'Entrez le lieu de récupération',
              hintStyle: TextStyle(fontSize: 11),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Date and Time Field
        Row(
          children: [
            const Text(
              'Date et heure de récupération',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),

            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _dateTimeController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Entrez la date et heure de récupération',
              hintStyle: TextStyle(fontSize: 11),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final DateTime combinedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _dateTimeController.text = DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(combinedDateTime);
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Availability Field
        const Text(
          'Disponibilités',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _availabilityController,
            decoration: InputDecoration(
              hintText: 'Entrez vos disponibilités',
              hintStyle: TextStyle(fontSize: 11),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final DateTime combinedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _dateTimeController.text = DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(combinedDateTime);
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Price Field with Currency
        const Text(
          'Prix / Tarification',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Entrez le tarif',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Fcfa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Languages Field
        const Text(
          'Langues parlées',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _languagesController,
            decoration: const InputDecoration(
              hintText: 'Entrez la ou les langues parlée(s)',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Next button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                _currentStep = 2;
              });
            },
            child: const Text(
              'Suivant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Form() {
    return Step2Form(
      onBackPressed: () {
        setState(() {
          _currentStep = 1;
        });
      },
      onPublishPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication soumise avec succès!')),
        );
        Navigator.pop(context);
      },
      onAddImagesPressed: () {
        // Logique pour ajouter des images
      },
      onCameraPressed: () {
        // Logique pour la caméra
      },
    );
  }
}
