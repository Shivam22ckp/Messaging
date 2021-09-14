import 'package:flutter/cupertino.dart';

class User {
  final String First_name; // To store first name
  final String Last_name; //To store last name
  final String email; // To store email
  final String ImageUrl; // To store image
  final String Phone;

  //Default constructor
  User({
    this.First_name,
    this.Last_name,
    this.ImageUrl,
    this.email,
    this.Phone,
    String Image,
  });
  Map<String, dynamic>
      get User_data // A map function that will return the complete data of a user
  {
    return {
      "First_name": First_name,
      "Last_name": Last_name,
      "Email": email,
      "ImageUrl": ImageUrl,
      "Phone": Phone,
    };
  }

// ignore: empty_constructor_bodies
}
