import 'package:flutter/material.dart';
// Assuming ApiService exists and has a method for password reset requests
// import '../services/api_service.dart';
import '../services/api_service.dart'; // Uncomment this line

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final ApiService _apiService = ApiService(); // Uncomment this line

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  void _requestReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    // TODO: Implement the API call to request password reset
    // Example (assuming ApiService and requestPasswordReset method):
    /*
    try {
      final response = await _apiService.requestPasswordReset(
        usuario: _usuarioController.text,
      );

      if (response['success']) {
        setState(() {
          _message = response['message'] ?? 'Instrucciones enviadas. Revisa tu correo.';
          _isError = false;
        });
      } else {
        setState(() {
          _message = response['message'] ?? 'Error al solicitar restablecimiento.';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de conexión: $e';
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    */

    // --- Placeholder for demonstration ---
   // await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
   // setState(() {
   //    _isLoading = false;
   //    _message = 'Si el usuario existe, se enviarán instrucciones.';
   //    _isError = false;
   // });
    // --------------------------------------

    // Use the actual API call:
    try {
      final response = await _apiService.requestPasswordReset(
        usuario: _usuarioController.text,
      );

      if (response['success']) {
        setState(() {
          // Use the message from the backend, which is more informative
          _message = response['message'] ?? 'Si el usuario existe, se enviarán instrucciones.';
          _isError = false;
        });
      } else {
        setState(() {
          _message = response['message'] ?? 'Error desconocido al solicitar restablecimiento.';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de conexión: ${e.toString()}';
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usuarioController,
                        decoration: InputDecoration(
                          labelText: 'Usuario o Correo Electrónico',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu usuario o correo';
                          }
                          // Basic validation for email format can be added here
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _requestReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Enviar Instrucciones',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isError ? Colors.red : Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    super.dispose();
  }
} 