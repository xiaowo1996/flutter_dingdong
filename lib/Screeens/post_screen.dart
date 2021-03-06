import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dingdong/model/myuser.dart';
import 'addtask_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'accept_screen.dart';

class PostScreen extends StatefulWidget {
  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<PostScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  final _auth = FirebaseAuth.instance;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  DocumentSnapshot searchmyUser(String email) {
    Firestore.instance
        .collection('myuser')
        .where("email", isEqualTo: email)
        .snapshots()
        .listen(
          (data) => data.documents.forEach(
            (doc) {
              ds6 = doc;
            },
          ),
        );
    return ds6;
  }

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot dsc = searchmyUser(loggedInUser.email);
    return Scaffold(
        appBar: AppBar(
          title: Text('任务详情'),
          centerTitle: true,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(flex: 1, child: _topSelect()),
            Expanded(flex: 20, child: _accepts(context)),
          ],
        ));
  }

  Widget _topSelect() {
    return Container(
      height: 40,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AcceptScreen()));
              },
              child: Text('发布的请求'),
            ),
          ),
          Expanded(
            flex: 1,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PostScreen()));
              },
              child: Text('接受的请求'),
            ),
          ),
          Expanded(
            flex: 1,
            child: RaisedButton(
              onPressed: () {},
              child: Text('评价'),
            ),
          ),
        ],
      ),
    );
  }

  /**/ Widget _accepts(context) {
    DocumentSnapshot dsc = searchmyUser(loggedInUser.email);

    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: dsc.reference.collection('accepts').snapshots(),
          builder: (context, snap) {
            if (snap.hasData) {
              List<Accept> accepts = snap.data.documents
                  .map((doc) => Accept.fromJson(doc.data))
                  .toList();
              return ListView.builder(
                  itemCount: accepts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(accepts[index].sender),
                      title: Text('任务内容:${accepts[index].content}'),
                      subtitle: Text('联系人电话:${accepts[index].senderphone}'),
                    );
                  });
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
