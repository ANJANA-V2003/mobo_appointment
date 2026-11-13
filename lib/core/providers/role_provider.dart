import 'package:flutter/material.dart';
import '../constants/user_role.dart';
import '../services/role_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class RoleProvider extends ChangeNotifier {
  final RoleService _roleService = RoleService();

  UserRole? _role;

  UserRole? get role => _role;

  bool get isManager => _role == UserRole.manager;

  bool get isStaff => _role == UserRole.staff;

  // bool get isCustomer => _role == UserRole.customer;

  bool get canSeeAllStaff => isManager;

  bool get canEditConfig => isManager;

  Future<void> detectRole(OdooClient client) async {
    if (await _roleService.isManager(client)) {
      _role = UserRole.manager;
    } else if (await _roleService.isStaff(client)) {
      _role = UserRole.staff;
    }
    // else
    //   {
    //   _role = UserRole.customer;
    // }

    notifyListeners();
  }

  void clearRole() {
    _role = null;
    notifyListeners();
  }
}
