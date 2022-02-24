import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async' show Future;
import 'model_Contact.dart';

Future<String> _loadJson() async {
  //1. read json file
  return await rootBundle.loadString("asset/contacts.json");
}

Future<List<Contact>> loadContactModel() async {
  String jsonString = await _loadJson();
  // 2. decode
  final jsonResult = json.decode(jsonString);
  // 3. convert
  List<Contact> contacts = [];
  for(var value in jsonResult){
    contacts.add( Contact.fromJson(value) );
  }
  print("contactsIsEmpty:${contacts.isEmpty}");
  return contacts;
}


  /*
  Contact.withMap(Map<String,dynamic> parseMap) {
    this.user = parseMap["user"];
    this.phone = parseMap["phone"];
    this.dateTime = parseMap["check-in"];
  }


  Future<List> getContacts() async {
    //1. read json file
    String jsonString = await rootBundle.loadString("asset/contacts.json");

    //2.convert to list or map
    final jsonResult = json.decode(jsonString);

    //遍历List，并且转成Anchor对象放到另一个List中
    List<Contact> contacts = [];
    for(Map<String,dynamic> map in jsonResult) {
      data?.add(Contact.withMap(map));
    }

    return contacts;
  }

  /*
  void setContacts(){
    Future<List> _temp = getContacts(); // as Future<List> ;
    // List contacts = [];
    for(Map<String,dynamic> map in _temp) {
      data?.add(Contact.withMap(map));
    }
  }*/


  @override
  String toString() {
    return "$user - $phone : $dateTime";
  }
}
*/

