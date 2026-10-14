import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() =>
      _EmergencyContactScreenState();
}


class _EmergencyContactScreenState
    extends State<EmergencyContactScreen> {


  final nameController = TextEditingController();
  final phoneController = TextEditingController();


  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;


  // Add Contact
  Future<void> addContact() async {

    if(nameController.text.isEmpty ||
        phoneController.text.isEmpty){
      return;
    }


    await firestore.collection("emergency_contacts")
        .add({

      "name": nameController.text,
      "phone": phoneController.text,
      "createdAt": DateTime.now(),

    });


    nameController.clear();
    phoneController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
        const SnackBar(
            content: Text("Emergency Contact Added")
        )
    );

  }



  // Call Contact
  Future<void> makeCall(String number) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open your phone app to call $number')),
    );
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.black,


      appBar: AppBar(

        title:
        const Text(
          "Emergency Contacts",
          style: TextStyle(
              color: Colors.white
          ),
        ),

        backgroundColor: Colors.red,

      ),


      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          children: [


            TextField(

              controller: nameController,

              style:
              const TextStyle(color: Colors.white),

              decoration:
              const InputDecoration(

                labelText:
                "Contact Name",

                labelStyle:
                TextStyle(
                    color: Colors.white
                ),

              ),

            ),



            TextField(

              controller: phoneController,

              keyboardType:
              TextInputType.phone,

              style:
              const TextStyle(color: Colors.white),


              decoration:
              const InputDecoration(

                labelText:
                "Phone Number",

                labelStyle:
                TextStyle(
                    color: Colors.white
                ),

              ),

            ),



            const SizedBox(height:20),



            ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                Colors.red,

              ),


              onPressed:addContact,


              child:
              const Text(
                  "Add Emergency Contact"
              ),

            ),



            const SizedBox(height:20),



            Expanded(

              child:
              StreamBuilder(

                stream:
                firestore
                    .collection(
                    "emergency_contacts")
                    .snapshots(),


                builder:
                    (context,
                    AsyncSnapshot<QuerySnapshot> snapshot){


                  if(!snapshot.hasData){

                    return const CircularProgressIndicator();

                  }



                  return ListView(

                    children:

                    snapshot.data!.docs.map((doc){


                      return Card(

                        color:
                        Colors.grey[900],


                        child:
                        ListTile(


                          title:
                          Text(

                            doc["name"],

                            style:
                            const TextStyle(
                                color: Colors.white
                            ),

                          ),


                          subtitle:
                          Text(

                            doc["phone"],

                            style:
                            const TextStyle(
                                color: Colors.white70
                            ),

                          ),


                          trailing:
                          IconButton(

                            icon:
                            const Icon(
                              Icons.call,
                              color: Colors.green,
                            ),


                            onPressed:(){

                              makeCall(
                                  doc["phone"]
                              );

                            },

                          ),

                        ),

                      );


                    }).toList(),

                  );


                },

              ),

            )

          ],

        ),

      ),

    );

  }

}