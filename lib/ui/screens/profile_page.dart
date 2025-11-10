import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recreapp/welcome_page.dart';
import 'package:recreapp/ui/screens/rewards.dart';
import 'package:recreapp/ui/screens/signin_page.dart';
import 'package:recreapp/ui/screens/widgets/my_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          // Datos del documento
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          String? apellido = data['apellido'];
          String? nombre = data['nombre'];
          String? profileImageUrl = data['profileImageUrl'];

          // Usuario autenticado
          User? user = FirebaseAuth.instance.currentUser;

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: size.height,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      backgroundImage: (profileImageUrl != null &&
                              profileImageUrl.isNotEmpty)
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child:
                          (profileImageUrl == null || profileImageUrl.isEmpty)
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.grey)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nombre completo
                  Text(
                    '$nombre $apellido',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Correo del usuario
                  Text(
                    user?.email ?? 'Correo Electrónico',
                    style: TextStyle(
                      color: Constants.blackColor.withOpacity(.3),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: size.height * .7,
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileWidget(
                          icon: Icons.person,
                          title: 'Mi perfil',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyProfilePage()),
                            );
                          },
                        ),
                        ProfileWidget(
                          icon: Icons.settings,
                          title: 'Configuraciones',
                          onTap: () {},
                        ),
                        ProfileWidget(
                          icon: Icons.card_giftcard,
                          title: 'Recompensas',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RewardsPage()),
                            );
                          },
                        ),
                        ProfileWidget(
                          icon: Icons.chat,
                          title: 'Preguntas frecuentes',
                          onTap: () {},
                        ),
                        ProfileWidget(
                          icon: Icons.share,
                          title: 'Compartir',
                          onTap: () {},
                        ),
                        ProfileWidget(
                          icon: Icons.logout,
                          title: 'Salir',
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignIn()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Constants.primaryColor),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Constants.primaryColor),
          ],
        ),
      ),
    );
  }
}
