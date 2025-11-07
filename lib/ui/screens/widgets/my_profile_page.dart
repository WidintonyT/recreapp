import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recreapp/constants.dart';
import 'package:recreapp/ui/screens/widgets/custom_textfield.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController cellphoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  File? _imageFile;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          fullNameController.text = data['nombre'] ?? '';
          lastnameController.text = data['apellido'] ?? '';
          cellphoneController.text = data['telefono'] ?? '';
          addressController.text = data['direccion'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    }
  }

  /// Actualiza los datos del usuario en Firestore
  Future<void> _updateUserData() async {
    if (cellphoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El número de teléfono debe contener 10 dígitos.'),
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? imageUrl = _profileImageUrl;

      // Si se eligió una nueva imagen, súbela y obtén la URL
      if (_imageFile != null) {
        imageUrl = await _uploadProfileImage(_imageFile!);
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
        'nombre': fullNameController.text,
        'apellido': lastnameController.text,
        'telefono': cellphoneController.text,
        'direccion': addressController.text,
        'profileImageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados exitosamente.'),
        ),
      );

      // Refresca los datos en la pantalla
      _loadUserData();
    }
  }

  /// Permite elegir una imagen desde la galería
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Sube la imagen seleccionada a Firebase Storage y retorna su URL
  Future<String> _uploadProfileImage(File image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
    storage.ref().child('usuarios').child('${user.uid}_profile.jpg');

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar información del perfil',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              Stack(
                children: [
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Constants.primaryColor.withOpacity(.5),
                        width: 5.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profileImageUrl != null &&
                          _profileImageUrl!.isNotEmpty)
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: (_imageFile == null &&
                          (_profileImageUrl == null ||
                              _profileImageUrl!.isEmpty))
                          ? const Icon(Icons.person,
                          size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Constants.primaryColor,
                      ),
                      child: IconButton(
                        iconSize: 22,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Campos de texto
              CustomTextfield(
                controller: fullNameController,
                obscureText: false,
                hintText: 'Ingrese nombre',
                icon: Icons.person,
              ),
              CustomTextfield(
                controller: lastnameController,
                obscureText: false,
                hintText: 'Ingrese apellido',
                icon: Icons.person_outline,
              ),
              CustomTextfield(
                controller: cellphoneController,
                obscureText: false,
                hintText: 'Ingrese teléfono',
                icon: Icons.call,
              ),
              CustomTextfield(
                controller: addressController,
                obscureText: false,
                hintText: 'Ingrese dirección',
                icon: Icons.location_on,
              ),

              const SizedBox(height: 30),

              // Botón guardar
              GestureDetector(
                onTap: _updateUserData,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                  child: const Center(
                    child: Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
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
}