import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:calendar_timeline/forecastModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es'),
        const Locale('en'),
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now().add(Duration(days: 5));
  }

  @override
  Widget build(BuildContext context) {
    List<ForecastModel> forecastModelList = new List<ForecastModel>();
    ForecastModel forecastModel = new ForecastModel();
    forecastModel.rainChance = 10.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/pioggia_30.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 20.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/pioggia_30.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 30.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/pioggia_30.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 40.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/pioggia_30.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 50.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/poco_nuvoloso.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 60.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/poco_nuvoloso.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 70.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/poco_nuvoloso.png';
    forecastModelList.add(forecastModel);
    forecastModel = new ForecastModel();
    forecastModel.rainChance = 80.toString();
    forecastModel.forecastImgPath =
        'https://cdn4.3bmeteo.com/images/icone/loc_small/poco_nuvoloso.png';
    forecastModelList.add(forecastModel);

    return Scaffold(
      backgroundColor: Color(0xFF333A47),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Calendar Timeline',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.tealAccent[100]),
              ),
            ),
            CalendarTimeline(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 60)),
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              monthColor: Colors.blueGrey,
              dayColor: Colors.teal[200],
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.redAccent[100],
              dotsColor: Color(0xFF333A47),
              showWeekEnd: false,
              forecastModelList: forecastModelList,
              locale: 'it',
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: FlatButton(
                color: Colors.teal[200],
                child:
                    Text('RESET', style: TextStyle(color: Color(0xFF333A47))),
                onPressed: () => setState(() => _resetSelectedDate()),
              ),
            ),
            SizedBox(height: 20),
            Center(
                child: Text('Selected date is $_selectedDate',
                    style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
