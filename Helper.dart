// ignore_for_file: camel_case_types, file_names, avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, prefer_const_declarations, prefer_interpolation_to_compose_strings, depend_on_referenced_packages

// import 'package:mongo_dart/mongo_dart.dart'; // Add the MongoDB package
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//  All the Global Variables are declared here
dynamic User_Position;
dynamic Message_Sent_Status;
dynamic message;
dynamic lattitude;
dynamic longitude;
dynamic Time_of_user_Location;
dynamic toPhoneNumber;
dynamic fromPhoneNumber;
dynamic isMessageSent = true;
dynamic userId = "yash";
dynamic DeviceToken;

String random = DateTime.now().microsecondsSinceEpoch.toString();


class Helper {
// Permission Grantting from user
  static Future<void> requestPermissions() async {
    // print("Requesting Permissions");
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.locationWhenInUse.request();
    await Permission.storage.request();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("Permission Granted for Notifications");
    } else {
      log("Permission Denied for Notifications");
    }
    // SaveDeviceTokenIntoDatabase(DeviceToken);
  }

  // Device token handing function
  static Future<void> SaveDeviceTokenIntoDatabase(dynamic token) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      DeviceToken = token;
      log("Device Token is : $DeviceToken");
    });
    await FirebaseFirestore.instance.collection("UserTokens").doc(random).set({
      "User Device Token is ": DeviceToken,
      "User Name is ": "$random",
    });
  }

//  Location Fetching Function
  static Future<void> locationfetch() async {
    Position _currentPosition;
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(" \n Location fetched: $_currentPosition");

    // sendmessage();
    // Time_of_user_Location = " ${_currentPosition.timestamp} ";
    lattitude = _currentPosition.latitude;
    longitude = _currentPosition.longitude;

    User_Position =
        "User Position : Lattitude - $lattitude , Longitude -  $longitude";

    message = " I need your help this is my current position : $User_Position ";
    log("User Position : $User_Position");
    SendNotification(User_Position, message, toPhoneNumber);
  }

//  Message Sending Function

  static Future<void> SendNotification(
      dynamic userposition, dynamic messageBody, dynamic toPhoneNumber) async {
    log("Message sent to $toPhoneNumber: $messageBody");
    DataStoreinCloud(userposition, isMessageSent, message, userId);
  }

//  Save Data into a Firebase Database

  static Future<void> DataStoreinCloud(
    dynamic userPosition,
    dynamic isMessageSent,
    dynamic message,
    dynamic userId, // Assuming you have userId to identify the user
  ) async {
    if (isMessageSent) {
      try {
        // Initialize Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Create a new entry in the 'messages' collection
        await firestore.collection('messages').doc(random).set({
          'userPosition': userPosition.toString(),
          'message': message,
          'timestamp':
              FieldValue.serverTimestamp(), // Automatically sets server time
        });

        log("Data saved successfully to Firestore");
        // DataStoreLocally(userPosition, message);
      } catch (e) {
        log("Failed to save into the Cloud Database: $e");
      }
    } else {
      // If the message was not sent, retry sending it
      SendNotification(userPosition, message, toPhoneNumber);
    }
  }

// Save Data into a user local Database
  static Future<void> DataStoreLocally(
    dynamic userPosition,
    dynamic message,
  ) async {
    final Database db = await LocalDatabaseHelper.database;

    try {
      await db.insert(
        'messages',
        {
          'userPosition': userPosition,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      log("Data saved successfully to local database");
    } catch (e) {
      log("Failed to save data: $e");
    }
  }
}

//  Local Database Helper
class LocalDatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'local_data.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, userPosition TEXT, message TEXT, timestamp TEXT)",
        );
      },
      version: 1,
    );
  }
}
