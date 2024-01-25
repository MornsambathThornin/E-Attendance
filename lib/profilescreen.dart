import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'model/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  String birth = "Date of birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Color primary = const Color(0xffff0000);

  void pickUploadProfilePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('${User.employeeId.toLowerCase()}_profilepic.jpg');

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
        User.profilePhotoLink = value;
      });

      await FirebaseFirestore.instance
          .collection("Employee")
          .doc(User.id)
          .update({
        'profilePic': value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                pickUploadProfilePhoto();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 30, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePhotoLink == " "
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(User.profilePhotoLink),
                        ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Employee : ${User.employeeId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            User.canEdit
                ? textField("First Name", "First name", firstNameController)
                : filed("First Name", User.firstName),
            User.canEdit
                ? textField("Last Name", "Last name", lastNameController)
                : filed("Last Name", User.lastName),
            User.canEdit
                ? GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                  primary: primary,
                                  secondary: primary,
                                  onSecondary: Colors.white),
                              // textButtonTheme: TextButtonThemeData(
                              //   style: TextButton.styleFrom(primary: primary),
                              // ),
                              textTheme: const TextTheme(
                                  headline2: TextStyle(fontFamily: "NexaBold"),
                                  overline: TextStyle(fontFamily: "NexaBold"),
                                  button: TextStyle(fontFamily: "NexaBold")),
                            ),
                            child: child!,
                          );
                        },
                      ).then((value) {
                        setState(() {
                          birth = DateFormat("MM/dd/yyyy").format(value!);
                        });
                      });
                    },
                    child: filed("Date of Birth", birth))
                : filed("Date of Birth", User.birthDate),
            User.canEdit
                ? textField("Address", "Address", addressController)
                : filed("Address", User.address),
            User.canEdit
                ? GestureDetector(
                    onTap: () async {
                      String fitstName = firstNameController.text;
                      String lastName = lastNameController.text;
                      String birthDate = birth;
                      String address = addressController.text;

                      if (User.canEdit) {
                        if (fitstName.isEmpty) {
                          showSnackBar("Please enter your First Name!");
                        } else if (lastName.isEmpty) {
                          showSnackBar("Please enter your last Name!");
                        } else if (birthDate.isEmpty) {
                          showSnackBar("Please enter your Date of birth!");
                        } else if (address.isEmpty) {
                          showSnackBar("Please enter your address!");
                        } else {
                          await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(User.id)
                              .update({
                            'firstName': fitstName,
                            'lastName': lastName,
                            'birthDate': birthDate,
                            'address': address,
                            'canEdit': false,
                          }).then((value) {
                            setState(() {
                              User.canEdit = false;
                              User.firstName = fitstName;
                              User.lastName = lastName;
                              User.birthDate = birthDate;
                              User.address = address;
                            });
                          });
                        }
                      } else {
                        showSnackBar(
                            "You can't edit anymore, please contect support team!");
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: kToolbarHeight,
                      width: screenWidth,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: primary),
                      child: const Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "NexaBold",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget filed(String title, String text) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 12),
          height: kToolbarHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black54),
          ),
          child: Align(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black54,
                  fontFamily: "NexaBold",
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget TextField reuse

  Widget textField(
      String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Colors.black54, fontFamily: "NexaBold"),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        ),
      ),
    );
  }
}
