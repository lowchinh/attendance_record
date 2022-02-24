import 'package:flutter/cupertino.dart';
import 'model_Contact.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

DateFormat dateformat = DateFormat("yyyy-MM-dd hh:mm:ss");

Widget convert_TimeAgo(detail_Datetime) {
  final ago_Datetime = dateformat.parse(detail_Datetime);
  return Text(timeago.format(ago_Datetime));
}

  void sort_DateTime(List<Contact> dt){
    late Contact temp;
    late int n;
    late DateTime min;
    for(int i =0;i<dt.length-1;i++){
      n = i;
      min = DateTime.parse(dt[n].dateTime);
      for(int j=i+1;j<dt.length;j++) {
        if (min.compareTo(DateTime.parse(dt[j].dateTime) ) == -1) {
          n = j;
          min = DateTime.parse(dt[n].dateTime);
        }
      }
      temp = dt[i];
      dt[i] = dt[n];
      dt[n] = temp;
    }
  }
