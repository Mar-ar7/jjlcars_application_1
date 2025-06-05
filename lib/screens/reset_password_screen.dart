import 'package:flutter/material.dart';
// Assuming ApiService exists and has a method for resetting password with token
// import '../services/api_service.dart';
import '../services/api_service.dart'; // Uncomment this line

class ResetPasswordScreen extends StatefulWidget {
  // final String? token; // Optional: Pass token from link if applicable - REMOVED

  const ResetPasswordScreen({super.key}); // Removed token parameter

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  // Removed _tokenController as token is no longer used
  final _usuarioController = TextEditingController(); // Add controller for usuario
  final _nombreController = TextEditingController(); // Add controller for nombre
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService(); // Uncomment this line

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Removed token pre-fill logic
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

     if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Las contraseñas no coinciden';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    // Use the actual API call:
    try {
      final response = await _apiService.resetPassword(
        // Removed token parameter
        usuario: _usuarioController.text, // Pass usuario
        nombre: _nombreController.text, // Pass nombre
        newPassword: _passwordController.text,
      );

      if (response['success']) {
        setState(() {
          _message = response['message'] ?? 'Contraseña restablecida con éxito.';
          _isError = false;
        });
        // Navigate to login screen after successful reset
         if (!mounted) return; // Check if widget is still mounted
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña restablecida con éxito. Por favor inicia sesión')),
        );
        // Assuming you have a login route named '/login'
        // Navigator.pushReplacementNamed(context, '/login'); // Commented out for now, decide on navigation flow

      } else {
        setState(() {
          _message = response['message'] ?? 'Error al restablecer la contraseña.';
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
        title: const Text('Restablecer Contraseña'), // Updated title
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
                        'Restablecer Contraseña',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 24),
                       TextFormField(
                        controller: _usuarioController, // Use usuario controller
                        decoration: InputDecoration(
                          labelText: 'Usuario', // Updated label
                          prefixIcon: const Icon(Icons.person_outline),
                           border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu usuario';
                          }
                          return null;
                        },
                      ),
                       const SizedBox(height: 16),
                       TextFormField(
                        controller: _nombreController, // Use nombre controller
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo', // Updated label
                          prefixIcon: const Icon(Icons.person),
                           border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Nueva Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                           suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una nueva contraseña';
                          }
                           if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Nueva Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                           suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirma tu nueva contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Restablecer Contraseña',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
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
    // Removed _tokenController dispose
    _usuarioController.dispose(); // Dispose usuario controller
    _nombreController.dispose(); // Dispose nombre controller
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
} 