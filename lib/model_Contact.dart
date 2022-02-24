class Contact{
  String user;
  String phone;
  String dateTime;

  Contact({
    required this.user,
    required this.phone,
    required this.dateTime
  });

  factory Contact.fromJson(Map<String,dynamic>parsedJson){
    return Contact(
        user:parsedJson['user'],
        phone:parsedJson["phone"],
        dateTime:parsedJson['check-in']
    );
  }
}
