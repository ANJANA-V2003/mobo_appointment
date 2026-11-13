
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Check whether biometric authentication is available.
  Future<bool> isBiometricAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;

    if (!canCheck) return false;

    final biometrics = await _auth.getAvailableBiometrics();

    return biometrics.isNotEmpty;
  }

  // Authenticate the user.
  Future<bool> authenticate() async {
    return await _auth.authenticate(
      localizedReason: 'Authenticate to access Mobo Appointments',
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
  }
}
