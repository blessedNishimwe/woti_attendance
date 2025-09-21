import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/location_hierarchy_selector.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/error_display.dart';

class FacilityAssignmentScreen extends StatefulWidget {
  const FacilityAssignmentScreen({Key? key}) : super(key: key);

  @override
  _FacilityAssignmentScreenState createState() => _F