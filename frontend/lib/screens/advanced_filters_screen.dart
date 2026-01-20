import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AdvancedFiltersScreen extends StatefulWidget {
  const AdvancedFiltersScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen> {
  RangeValues _heightRange = const RangeValues(150, 200);
  String? _education;
  String? _religion;
  String? _drinking;
  String? _smoking;
  String? _children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Advanced Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _heightRange = const RangeValues(150, 200);
                          _education = null;
                          _religion = null;
                          _drinking = null;
                          _smoking = null;
                          _children = null;
                        });
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFff6b9d),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filters
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Height filter
                      FadeInUp(
                        child: _buildFilterSection(
                          'Height',
                          Column(
                            children: [
                              RangeSlider(
                                values: _heightRange,
                                min: 120,
                                max: 220,
                                divisions: 100,
                                activeColor: const Color(0xFFff6b9d),
                                inactiveColor: Colors.white.withOpacity(0.2),
                                labels: RangeLabels(
                                  '${_heightRange.start.round()} cm',
                                  '${_heightRange.end.round()} cm',
                                ),
                                onChanged: (values) {
                                  setState(() => _heightRange = values);
                                },
                              ),
                              Text(
                                '${_heightRange.start.round()} cm - ${_heightRange.end.round()} cm',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Education filter
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildDropdownFilter(
                          'Education',
                          _education,
                          ['High School', 'Bachelor\'s', 'Master\'s', 'PhD', 'Other'],
                          (value) => setState(() => _education = value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Religion filter
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildDropdownFilter(
                          'Religion',
                          _religion,
                          ['Christianity', 'Islam', 'Hinduism', 'Buddhism', 'Judaism', 'Atheist', 'Agnostic', 'Other'],
                          (value) => setState(() => _religion = value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Drinking filter
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildDropdownFilter(
                          'Drinking',
                          _drinking,
                          ['Never', 'Socially', 'Regularly', 'Prefer not to say'],
                          (value) => setState(() => _drinking = value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Smoking filter
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildDropdownFilter(
                          'Smoking',
                          _smoking,
                          ['Never', 'Socially', 'Regularly', 'Prefer not to say'],
                          (value) => setState(() => _smoking = value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Children filter
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: _buildDropdownFilter(
                          'Children',
                          _children,
                          ['Don\'t have', 'Have kids', 'Want kids', 'Don\'t want kids'],
                          (value) => setState(() => _children = value),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Apply button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'heightRange': _heightRange,
                        'education': _education,
                        'religion': _religion,
                        'drinking': _drinking,
                        'smoking': _smoking,
                        'children': _children,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff6b9d),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String title,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: value,
            dropdownColor: const Color(0xFF1a1a2e),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFff6b9d)),
              ),
            ),
            hint: Text(
              'Select $title',
              style: GoogleFonts.poppins(color: Colors.white38),
            ),
            style: GoogleFonts.poppins(color: Colors.white),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
