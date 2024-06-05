import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FetchDetails {
  static Future<String?> fetchUserName() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doc = await db.collection('employeeDetails')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('username')) {
          return data['username'] as String?;
        }
      }
    }
    return "No User found";
  }

  static Future<String?> fetchEmail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doc = await db.collection('employeeDetails')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('email')) {
          return data['email'] as String?;
        }
      }
    }
    return "No Email found";
  }

  static Future<String?> fetchPhoneNumber() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doc = await db.collection('employeeDetails')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('phoneNumber')) {
          return data['phoneNumber'] as String?;
        }
      }
    }
    return "No Phone Number found";
  }


  static Future<String?> fetchCircle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String uid = user.uid;
      try {
        DocumentSnapshot doc = await db.collection('employeeDetails')
            .doc(uid)
            .get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('Circle')) {
            return data['Circle'] as String?;
          }
        }
      } catch (e) {
        print("Error fetching Circle field: $e");
      }
    }

    return null;
  }

  static Future<List<String>?> fetchCircleList() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
      try {
        QuerySnapshot querySnapshot = await db.collection('Circle').get();
        List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
        print(documentIds);
        return documentIds;
      } catch (e) {
        print("Error fetching Circle collection: $e");
        return null;
      }
  }


  static Future<bool?> fetchGoeFencing() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doc = await db.collection('employeeDetails')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('geoFencing')) {
          return data['geoFencing'] as bool?;
        }
      }
    }
    return false;
  }

  static Future<bool?> fetchEnrollment() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doc = await db.collection('employeeDetails')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('isEnrolled')) {
          return data['isEnrolled'] as bool?;
        }
      }
    }
    return false;
  }

  static Future<dynamic> fetchDeletePermission() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doc = await db.collection('employeeDetails')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('deletePermission')) {
          return data['deletePermission'];
        }
      }
    }
    return null;
  }
}