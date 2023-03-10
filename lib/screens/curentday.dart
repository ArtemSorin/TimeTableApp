import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:timetable/models/subjects.dart';

class CurrentDay extends StatelessWidget {
  const CurrentDay(
      {super.key,
      required this.title,
      required this.day,
      required this.week,
      required this.index,
      required this.name});

  final String title;
  final String name;
  final int day;
  final int week;
  final int index;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: title,
        day: day,
        week: week,
        index: index,
        name: name,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.day,
      required this.week,
      required this.index,
      required this.name});

  final String title;
  final String name;
  final int day;
  final int week;
  final int index;

  @override
  State<MyHomePage> createState() =>
      // ignore: no_logic_in_create_state
      _MyHomePageState(title, day, week, index, name);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this.title, this.day, this.week, this.index, this.name);

  final String title;
  final String name;
  final int day;
  final int week;
  final int index;

  List<Subjects> timetablelist = [];
  List<Subjects> timetablelistcurrent = [];

  void initstate() {
    super.initState();

    getWebsiteData();
  }

  Future getWebsiteData() async {
    final url = Uri.parse('https://ictis.ru/$index.html/$week');
    final responce = await http.get(url);
    dom.Document html = dom.Document.html(responce.body);

    final titlesNumber = html
        .querySelectorAll(
            'body > div.container > div > table > tbody > tr.day-0 > td')
        .map((e) => e.innerHtml.trim())
        .toList();

    final titlesTime = html
        .querySelectorAll(
            'body > div.container > div > table > tbody > tr.day-1 > td')
        .map((e) => e.innerHtml.trim())
        .toList();

    final titlesSubject = html
            .querySelectorAll(
                'body > div.container > div > table > tbody > tr.day-$day > td')
            .map((e) => e.innerHtml.trim())
            .toList() +
        html
            .querySelectorAll(
                'body > div.container > div > table > tbody > tr.current-day > td')
            .map((e) => e.innerHtml.trim())
            .toList();

    final titlesSubjectCurrent = html
        .querySelectorAll(
            'body > div.container > div > table > tbody > tr.current-day > td')
        .map((e) => e.innerHtml.trim())
        .toList();

    if (!mounted) return;

    setState(() {
      timetablelist = List.generate(
          titlesNumber.length,
          (day) => Subjects(
              number: titlesNumber[day],
              time: titlesTime[day],
              name: '',
              subject: titlesSubject.isNotEmpty ? titlesSubject[day] : ''));
      timetablelistcurrent = List.generate(
          titlesNumber.length,
          (day) => Subjects(
              number: titlesNumber[day],
              time: titlesTime[day],
              name: '',
              subject: titlesSubjectCurrent.isNotEmpty
                  ? titlesSubjectCurrent[day]
                  : ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    String str =
        '<span class="table-ext-icon" title="?????????????????????????? ????????">????</span>';
    getWebsiteData();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          color: const Color.fromARGB(255, 91, 117, 240),
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('?? ????????????????????'),
                  content: const Text(
                      '?????? ???????????????????? ?????? ?????????????????? ???????????????????? ?????????????????? ?????????? ?????????????? ?????? ??????. \n\n'
                      '?????? ???????????????? ???????????????????? ?????????????? ???????????? ???????????????? ????????????.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text(
                        'Cancel',
                        style:
                            TextStyle(color: Color.fromARGB(255, 91, 117, 240)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text(
                        'OK',
                        style:
                            TextStyle(color: Color.fromARGB(255, 91, 117, 240)),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.question_mark),
            color: const Color.fromARGB(255, 91, 117, 240),
          )
        ],
        title: Text(
          '$name, $title',
          style: const TextStyle(color: Color.fromARGB(255, 91, 117, 240)),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: timetablelist.length,
        itemBuilder: (context, day) {
          final timetable = timetablelist[day];
          return Card(
              child: ListTile(
            leading: Text(
              timetable.time == '??????????' ? '???' : timetable.time,
              style: TextStyle(
                  color: timetable.time == '??????????'
                      ? Colors.black
                      : const Color.fromARGB(255, 91, 117, 240),
                  fontWeight: FontWeight.bold),
            ),
            title: Text(
              timetable.subject.replaceAll(str, '').trim(),
              style: const TextStyle(color: Colors.black),
            ),
          ));
        },
      ),
    );
  }
}
