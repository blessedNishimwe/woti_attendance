import 'package:flutter/material.dart';
import '../models/location_models.dart';

class LocationHierarchySelector extends StatefulWidget {
  final void Function(String? regionId, String? councilId, String? facilityId)? onSelectionChanged;
  final String? selectedRegionId;
  final String? selectedCouncilId;
  final String? selectedFacilityId;

  const LocationHierarchySelector({
    Key? key,
    this.onSelectionChanged,
    this.selectedRegionId,
    this.selectedCouncilId,
    this.selectedFacilityId,
  }) : super(key: key);

  @override
  State<LocationHierarchySelector> createState() => _LocationHierarchySelectorState();
}

class _LocationHierarchySelectorState extends State<LocationHierarchySelector> {
  String? _selectedRegionId;
  String? _selectedCouncilId;
  String? _selectedFacilityId;
  
  List<Region> _regions = [];
  List<Council> _councils = [];
  List<Facility> _facilities = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRegionId = widget.selectedRegionId;
    _selectedCouncilId = widget.selectedCouncilId;
    _selectedFacilityId = widget.selectedFacilityId;
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock data for now - in real app, load from LocationHierarchyService
      _regions = [
        Region(
          id: '1',
          name: 'Northern Region',
          createdAt: DateTime.now(),
        ),
        Region(
          id: '2',
          name: 'Southern Region',
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCouncils(String regionId) async {
    setState(() {
      _isLoading = true;
      _councils = [];
      _facilities = [];
      _selectedCouncilId = null;
      _selectedFacilityId = null;
    });

    try {
      // Mock data for now
      _councils = [
        Council(
          id: '1',
          regionId: regionId,
          name: 'Council A',
          createdAt: DateTime.now(),
        ),
        Council(
          id: '2',
          regionId: regionId,
          name: 'Council B',
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFacilities(String councilId) async {
    setState(() {
      _isLoading = true;
      _facilities = [];
      _selectedFacilityId = null;
    });

    try {
      // Mock data for now
      _facilities = [
        Facility(
          id: '1',
          councilId: councilId,
          name: 'Health Center A',
          latitude: -1.5,
          longitude: 30.0,
          radiusMeters: 100,
          isActive: true,
          createdAt: DateTime.now(),
        ),
        Facility(
          id: '2',
          councilId: councilId,
          name: 'Health Center B',
          latitude: -1.6,
          longitude: 30.1,
          radiusMeters: 100,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRegionChanged(String? regionId) {
    setState(() {
      _selectedRegionId = regionId;
      _selectedCouncilId = null;
      _selectedFacilityId = null;
    });

    if (regionId != null) {
      _loadCouncils(regionId);
    }

    widget.onSelectionChanged?.call(_selectedRegionId, _selectedCouncilId, _selectedFacilityId);
  }

  void _onCouncilChanged(String? councilId) {
    setState(() {
      _selectedCouncilId = councilId;
      _selectedFacilityId = null;
    });

    if (councilId != null) {
      _loadFacilities(councilId);
    }

    widget.onSelectionChanged?.call(_selectedRegionId, _selectedCouncilId, _selectedFacilityId);
  }

  void _onFacilityChanged(String? facilityId) {
    setState(() {
      _selectedFacilityId = facilityId;
    });

    widget.onSelectionChanged?.call(_selectedRegionId, _selectedCouncilId, _selectedFacilityId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Region Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Region',
            border: OutlineInputBorder(),
          ),
          value: _selectedRegionId,
          items: _regions.map((region) {
            return DropdownMenuItem<String>(
              value: region.id,
              child: Text(region.name),
            );
          }).toList(),
          onChanged: _isLoading ? null : _onRegionChanged,
        ),
        const SizedBox(height: 16),

        // Council Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Council',
            border: OutlineInputBorder(),
          ),
          value: _selectedCouncilId,
          items: _councils.map((council) {
            return DropdownMenuItem<String>(
              value: council.id,
              child: Text(council.name),
            );
          }).toList(),
          onChanged: _isLoading || _selectedRegionId == null ? null : _onCouncilChanged,
        ),
        const SizedBox(height: 16),

        // Facility Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Facility',
            border: OutlineInputBorder(),
          ),
          value: _selectedFacilityId,
          items: _facilities.map((facility) {
            return DropdownMenuItem<String>(
              value: facility.id,
              child: Text(facility.name),
            );
          }).toList(),
          onChanged: _isLoading || _selectedCouncilId == null ? null : _onFacilityChanged,
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}