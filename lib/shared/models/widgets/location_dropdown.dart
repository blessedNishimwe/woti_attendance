import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../location_models.dart';

class LocationHierarchySelector extends StatelessWidget {
  final bool isRequired;
  final String? Function(Facility?)? validator;

  const LocationHierarchySelector({
    Key? key,
    this.isRequired = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Region Selector
            _buildDropdown<Region>(
              context: context,
              label: 'Region',
              value: authProvider.selectedRegion,
              items: authProvider.regions,
              onChanged: (region) {
                if (region != null) {
                  authProvider.selectRegion(region);
                }
              },
              itemBuilder: (region) => region.name,
              isRequired: isRequired,
            ),
            const SizedBox(height: 16),

            // Council Selector
            _buildDropdown<Council>(
              context: context,
              label: 'Council',
              value: authProvider.selectedCouncil,
              items: authProvider.councils,
              onChanged: (council) {
                if (council != null) {
                  authProvider.selectCouncil(council);
                }
              },
              itemBuilder: (council) => council.name,
              enabled: authProvider.selectedRegion != null,
              isRequired: isRequired,
            ),
            const SizedBox(height: 16),

            // Facility Selector
            _buildDropdown<Facility>(
              context: context,
              label: 'Facility / Work Site',
              value: authProvider.selectedFacility,
              items: authProvider.facilities,
              onChanged: (facility) {
                if (facility != null) {
                  authProvider.selectFacility(facility);
                }
              },
              itemBuilder: (facility) => facility.name,
              enabled: authProvider.selectedCouncil != null,
              isRequired: isRequired,
              validator: validator,
            ),

            // Location Path Display
            if (authProvider.selectedFacility != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.selectedFacility!.fullLocationName,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemBuilder,
    bool enabled = true,
    bool isRequired = false,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      items: enabled
          ? items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemBuilder(item)),
              );
            }).toList()
          : null,
      onChanged: enabled ? onChanged : null,
      validator: validator ??
          (isRequired
              ? (value) => value == null ? 'Please select a $label' : null
              : null),
      hint: Text('Select $label'),
    );
  }
}