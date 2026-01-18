import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/address_model.dart';

/// Écran d'ajout/modification d'adresse
class AddEditAddressScreen extends ConsumerStatefulWidget {
  final String? addressId;
  
  const AddEditAddressScreen({
    super.key,
    this.addressId,
  });
  
  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.addressId != null) {
      _loadAddress();
    }
  }
  
  Future<void> _loadAddress() async {
    final addresses = await ref.read(userAddressesProvider.future);
    if (addresses.isEmpty) return;
    
    final address = addresses.firstWhere(
      (a) => a.id == widget.addressId,
    );
    
    if (mounted) {
      _cityController.text = address.city;
      _addressLineController.text = address.addressLine;
      _zipController.text = address.zip;
      _isDefault = address.isDefault;
    }
  }
  
  @override
  void dispose() {
    _cityController.dispose();
    _addressLineController.dispose();
    _zipController.dispose();
    super.dispose();
  }
  
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;
      
      if (user == null) {
        if (mounted) {
          context.pop();
        }
        return;
      }
      
      final repo = ref.read(addressRepositoryProvider);
      
      if (widget.addressId != null) {
        // Mise à jour
        final address = AddressModel(
          id: widget.addressId!,
          userId: user.id,
          city: _cityController.text.trim(),
          addressLine: _addressLineController.text.trim(),
          zip: _zipController.text.trim(),
          isDefault: _isDefault,
        );
        await repo.updateAddress(address);
      } else {
        // Création
        await repo.createAddress(
          userId: user.id,
          city: _cityController.text.trim(),
          addressLine: _addressLineController.text.trim(),
          zip: _zipController.text.trim(),
          isDefault: _isDefault,
        );
      }
      
      if (mounted) {
        ref.invalidate(userAddressesProvider);
        ref.invalidate(defaultAddressProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addressId == null ? 'Nouvelle adresse' : 'Modifier l\'adresse'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une ville';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressLineController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zipController,
                decoration: const InputDecoration(
                  labelText: 'Code postal',
                  prefixIcon: Icon(Icons.markunread_mailbox),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un code postal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                title: const Text('Définir comme adresse par défaut'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.addressId == null ? 'Enregistrer' : 'Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
