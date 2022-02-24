import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'contactsManager.dart';
import 'model_Contact.dart';
import 'processDateTime.dart'show convert_TimeAgo,sort_DateTime;
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget{

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController = RefreshController(
      initialRefresh: false);
  // save dataset from contacts.json
  List<Contact> _items = [];
  // show on listView
  List<Contact> _newItems = [];
  // if true:show detail of time;else,show time ago.
  late bool _detailDateFormat = true;
  late Future<bool> _futureDateFormat;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // 15 set contacts per page, total 2 pages
  int page = 0;

  //
  @override
  void initState() {
    // get data from json
    _getData();
    // loading list
    _loadMoreContact();
    super.initState();
    // _getDateFormat();
    // standard time format as default when it's initialized for the first time
    _futureDateFormat = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('value') ?? true;
    });
    // convert future to datetime
    _convertDateFormat();
  }

  @override
  Widget build(BuildContext context) {
    print("items:${_items.runtimeType}");
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vimigo Attendance Record"),
        actions: [
          IconButton(
            // button for switch the format of the time
            onPressed: () =>
                setState(() {
                  _detailDateFormat = !_detailDateFormat;
                  _getDateFormat();
                  print("Switch date format");
                }), //switchDateFormat(),
            icon: const Icon(Icons.swap_horiz,),
          ),
        ],
      ),
      body: _listContacts(),
    );
  }

  void _getData() async {
    _items = await loadContactModel();
    print("itemsIsEmpty:${_newItems.isEmpty}");
  }

  // show list of contacts
  Widget _listContacts() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: _generateFive,
      onLoading: _loadMoreContact,
      controller: _refreshController,
      header: const WaterDropMaterialHeader(),
      footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body = const Text("Vimigo", textScaleFactor: 1.5,);
            if (mode == LoadStatus.idle &&
                _items.length > _newItems.length) {
              body = const Text('Pull Up to Load More', textScaleFactor: 1.5,);
            } else if (mode == LoadStatus.loading) {
              body = const CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = const Text(
                "Loading Error!Please Try Again!", textScaleFactor: 1.5,);
            } else if (mode == LoadStatus.loading) {
              body = const Text("Release to Load More", textScaleFactor: 1.5,);
            } else if (_newItems.length >= _items.length) {
              body = const Text(
                "You have reached end of the list!", textScaleFactor: 1.5,);
            }
            return Center(
              child: body,
            );
          }
      ),
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _newItems.length,
          itemBuilder: (c, i) {
            return Card(
              // color: Colors.white70,
              margin: const EdgeInsets.all(5),
              child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Hero(
                        tag: "profile-circle",
                        child: _avatar(
                            'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png'),
                      ),
                      onTap: () => _gotoDetailsPage(context,i),
                      title: Text(_newItems[i].user),
                      subtitle: Text(_newItems[i].phone),
                      trailing: _detailDateFormat ?
                      Text(_newItems[i].dateTime) :
                      convert_TimeAgo(_newItems[i].dateTime),
                    ),
                  ]
              ),
            );
          }
      ),
    );
  }

  // show avatar in contact card
  Widget _avatar(String url) {
    // make the shape of avatar round
    return ClipOval(
      child: Image.network(url),
    );
  }

  // show detail page ,that also has a button for sharing
  void _gotoDetailsPage(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          Scaffold(
            appBar: AppBar(
              title: const Text('detail'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Hero(
                    tag: 'profile-circle',
                    child: _avatar(
                        'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png'),
                  ),
                  Card(
                    margin : EdgeInsets.all(10),
                    child:Text(_newItems[index].user,style: const TextStyle(fontSize:30)),
                  ),
                  Card(
                    margin : EdgeInsets.all(10),
                    child:Text(_newItems[index].phone,style: const TextStyle(fontSize:30),),
                  ),
                  IconButton(icon: const Icon(Icons.share,size: 30,),onPressed: (){_share(context, index);}
                  ),
                ],
              ),
            ),
          ),
    ));
  }

  void _convertDateFormat() async {
    _detailDateFormat = await _futureDateFormat;
  }

  // set and remember detailDataFormat's value
  Future<void> _getDateFormat() async {
    final SharedPreferences prefs = await _prefs;
    var value = (prefs.getBool('value') ?? false);
    print("detailDateFormat:$_detailDateFormat");
    print("value:$value");
    value = _detailDateFormat;
    setState(() {
      _futureDateFormat = prefs.setBool('value', value).then((bool success) {
        return value;
      });
    });
  }

  // Loading Contacts
  _loadMoreContact() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
    sort_DateTime(_items);
    if (page < 2 && page >= 0) {
      if (page > 0) {
        int i = _newItems.length;
        while (i < _items.length) {
          _newItems.add(_items[i]);
          i++;
        }
      } else {
        int i = 0;
        while (i < _items.length / 2) {
          _newItems.add(_items[i]);
          i++;
        }        page++;
        print("page:$page");
      }
    }
    setState(() {
      _newItems;
      sort_DateTime(_newItems);
    });
    _refreshController.loadComplete();
  }

  // pull down to generate 5 random member
  _generateFive() async {
    int randomnum;
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      // Generate 5 random number and add on the new list
      var rng = Random();
      for (var i = 0; i < 5; i++) {
        randomnum = rng.nextInt(_items.length);
        _newItems.insert(0, _items[randomnum]);
      }
    });
    _refreshController.refreshCompleted();
  }

  // the function of share  contact
  _share(BuildContext context, int index) {
    Share.share("${_newItems[index].user} - ${_newItems[index].phone}",
        subject: 'Contact');
  }

  @override
  void dispose() {
    //移除监听，防止内存泄漏
    _getDateFormat();
    super.dispose();
  }

}