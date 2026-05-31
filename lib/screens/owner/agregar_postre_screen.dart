import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dulceapp/providers/postre_provider.dart';
import 'package:dulceapp/models/postre.dart';
import 'package:dulceapp/theme/app_theme.dart';

class AgregarPostreScreen extends StatefulWidget {
  final String? postreId;
  const AgregarPostreScreen({super.key, this.postreId});

  @override
  State<AgregarPostreScreen> createState() => _AgregarPostreScreenState();
}

class _AgregarPostreScreenState extends State<AgregarPostreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  bool _cargando = false;
  bool _editando = false;
  String _imagenUrl = '';
  File? _imagenLocal;

  @override
  void initState() {
    super.initState();
    if (widget.postreId != null) {
      _editando = true;
      _cargarPostre();
    }
  }

  Future<void> _cargarPostre() async {
    final p = await context.read<PostreProvider>().obtenerPostre(widget.postreId!);
    if (p != null && mounted) {
      _nombreCtrl.text = p.nombre;
      _descripcionCtrl.text = p.descripcion;
      _precioCtrl.text = p.precio.toString();
      _imagenUrl = p.imagenUrl;
      setState(() {});
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 600,
    );
    if (picked != null) {
      setState(() => _imagenLocal = File(picked.path));
    }
  }

  Future<String> _imagenABase64() async {
    if (_imagenLocal == null) return _imagenUrl;
    final bytes = await _imagenLocal!.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final imagenFinal = await _imagenABase64();

    final postre = Postre(
      id: widget.postreId ?? '',
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      imagenUrl: imagenFinal,
      disponible: true,
      calificacionPromedio: 0,
      totalResenas: 0,
    );

    final provider = context.read<PostreProvider>();
    if (_editando) {
      await provider.actualizarPostre(postre);
    } else {
      await provider.agregarPostre(postre);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: Text(_editando ? 'Editar postre' : 'Agregar postre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.moradoSuave,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.morado, width: 2),
                  ),
                  child: _imagenLocal != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_imagenLocal!, fit: BoxFit.cover),
                        )
                      : _imagenUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _imagenUrl.startsWith('data:')
                                  ? Image.memory(
                                      base64Decode(_imagenUrl.split(',')[1]),
                                      fit: BoxFit.cover)
                                  : Image.network(_imagenUrl, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 48, color: AppColors.morado),
                                SizedBox(height: 8),
                                Text('Toca para agregar foto',
                                    style: TextStyle(color: AppColors.morado)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del postre',
                  prefixIcon: Icon(Icons.cake_outlined, color: AppColors.morado),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description_outlined, color: AppColors.morado),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa la descripción' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio (\$)',
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.morado),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el precio';
                  if (double.tryParse(v) == null) return 'Precio no válido';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  child: _cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(_editando ? 'Guardar cambios' : 'Agregar postre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}