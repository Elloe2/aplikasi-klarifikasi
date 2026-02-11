import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId;

  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPassController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password tidak cocok'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await context.read<AuthProvider>().changePassword(
        widget.userId,
        _oldPassController.text,
        _newPassController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AuthProvider>().error ?? 'Gagal ganti password',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Ganti Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Password Lama'),
              TextFormField(
                controller: _oldPassController,
                obscureText: _obscureOld,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Masukkan password lama',
                  _obscureOld,
                  () => setState(() => _obscureOld = !_obscureOld),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _buildLabel('Password Baru'),
              TextFormField(
                controller: _newPassController,
                obscureText: _obscureNew,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Bikin password baru',
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (value) =>
                    value!.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 24),
              _buildLabel('Konfirmasi Password Baru'),
              TextFormField(
                controller: _confirmPassController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Ulangi password baru',
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primarySeedColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Password',
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    bool isObscured,
    VoidCallback onToggle,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: AppTheme.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: Colors.white38,
        ),
        onPressed: onToggle,
      ),
    );
  }
}
