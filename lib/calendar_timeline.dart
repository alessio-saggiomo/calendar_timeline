import 'package:calendar_timeline/forecastModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

typedef OnDateSelected = void Function(DateTime);

class CalendarTimeline extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate selectableDayPredicate;
  final bool showWeekEnd;
  final OnDateSelected onDateSelected;
  final double leftMargin;
  final Color dayColor;
  final Color activeDayColor;
  final Color activeBackgroundDayColor;
  final Color monthColor;
  final Color dotsColor;
  final Color dayNameColor;
  final String locale;
  final List<ForecastModel> forecastModelList;

  CalendarTimeline({
    Key key,
    @required this.initialDate,
    @required this.firstDate,
    @required this.lastDate,
    @required this.onDateSelected,
    this.selectableDayPredicate,
    this.showWeekEnd = true,
    this.leftMargin = 0,
    this.dayColor,
    this.activeDayColor,
    this.activeBackgroundDayColor,
    this.monthColor,
    this.dotsColor,
    this.dayNameColor,
    this.locale,
    this.forecastModelList,
  })  : assert(initialDate != null),
        assert(firstDate != null),
        assert(lastDate != null),
        assert(
          initialDate.difference(firstDate).inDays >= 0,
          'initialDate must be on or after firstDate',
        ),
        assert(
          !initialDate.isAfter(lastDate),
          'initialDate must be on or before lastDate',
        ),
        assert(
          !firstDate.isAfter(lastDate),
          'lastDate must be on or after firstDate',
        ),
        assert(
          selectableDayPredicate == null || selectableDayPredicate(initialDate),
          'Provided initialDate must satisfy provided selectableDayPredicate',
        ),
        assert(
          locale == null || dateTimeSymbolMap().containsKey(locale),
          'Provided locale value doesn\'t exist',
        ),
        super(key: key);

  @override
  _CalendarTimelineState createState() => _CalendarTimelineState();
}

class _CalendarTimelineState extends State<CalendarTimeline> {
  final ItemScrollController _controllerDay = ItemScrollController();

  int _daySelectedIndex;
  double _scrollAlignment;

  List<DateTime> _days = [];
  DateTime _selectedDate;

  String get _locale =>
      widget.locale ?? Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    _initCalendar();
    _scrollAlignment = widget.leftMargin / 440;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initializeDateFormatting(_locale);
    });
  }

  @override
  void didUpdateWidget(CalendarTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _buildDayList();
  }

  SizedBox _buildDayList() {
    return SizedBox(
      height: 140,
      child: ScrollablePositionedList.builder(
        itemScrollController: _controllerDay,
        initialScrollIndex: _daySelectedIndex,
        initialAlignment: _scrollAlignment,
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        padding: EdgeInsets.only(left: widget.leftMargin),
        itemBuilder: (BuildContext context, int index) {
          final currentDay = _days[index];
          final shortName =
              DateFormat.E(_locale).format(currentDay).capitalize();
          final shortmonthName =
              DateFormat.MMM(_locale).format(currentDay).toUpperCase();
          return widget.showWeekEnd
              ? Row(
                  children: <Widget>[
                    _DayItem(
                      isSelected: _daySelectedIndex == index,
                      dayNumber: currentDay.day,
                      shortName: shortName.length > 3
                          ? shortName.substring(0, 3)
                          : shortName,
                      shortMonthName: shortmonthName,
                      onTap: () => _goToActualDay(index),
                      available: widget.selectableDayPredicate == null
                          ? true
                          : widget.selectableDayPredicate(currentDay),
                      dayColor: widget.dayColor,
                      activeDayColor: widget.activeDayColor,
                      activeDayBackgroundColor: widget.activeBackgroundDayColor,
                      dotsColor: widget.dotsColor,
                      dayNameColor: widget.dayNameColor,
                      forecastModel: index < widget.forecastModelList.length
                          ? widget.forecastModelList[index]
                          : null,
                    ),
                    if (index == _days.length - 1)
                      SizedBox(
                          width: MediaQuery.of(context).size.width -
                              widget.leftMargin -
                              65)
                  ],
                )
              : ((currentDay.weekday == DateTime.saturday ||
                      currentDay.weekday == DateTime.sunday)
                  ? null
                  : Row(
                      children: <Widget>[
                        _DayItem(
                          isSelected: _daySelectedIndex == index,
                          dayNumber: currentDay.day,
                          shortName: shortName.length > 3
                              ? shortName.substring(0, 3)
                              : shortName,
                          shortMonthName: shortmonthName,
                          onTap: () => _goToActualDay(index),
                          available: widget.selectableDayPredicate == null
                              ? true
                              : widget.selectableDayPredicate(currentDay),
                          dayColor: widget.dayColor,
                          activeDayColor: widget.activeDayColor,
                          activeDayBackgroundColor:
                              widget.activeBackgroundDayColor,
                          dotsColor: widget.dotsColor,
                          dayNameColor: widget.dayNameColor,
                          forecastModel: index < widget.forecastModelList.length
                              ? widget.forecastModelList[index]
                              : null,
                        ),
                      ],
                    ));
        },
      ),
    );
  }

  _generateDays(DateTime selectedMonth) {
    _days.clear();
    for (var i = 1;
        i <=
            (widget.lastDate.difference(DateTime.now()).inDays) +
                DateTime.now().day;
        i++) {
      final day = DateTime(selectedMonth.year, selectedMonth.month, i);
      if (day.difference(widget.firstDate).inDays < 0) continue;
      _days.add(day);
    }
  }

  _goToActualDay(int index) {
    _daySelectedIndex = index;
    _selectedDate = _days[index];
    widget.onDateSelected(_selectedDate);
    setState(() {});
  }

  _initCalendar() {
    _selectedDate = widget.initialDate;
    _generateDays(_selectedDate);
    _daySelectedIndex = _days.indexOf(
        _days.firstWhere((dayDate) => dayDate.day == widget.initialDate.day));
  }
}

class MonthName extends StatelessWidget {
  final String name;
  final Function onTap;
  final bool isSelected;
  final Color color;

  MonthName({this.name, this.onTap, this.isSelected, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Text(
        this.name.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          color: color ?? Colors.black87,
          fontWeight: this.isSelected ? FontWeight.bold : FontWeight.w300,
        ),
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final int dayNumber;
  final String shortName;
  final String shortMonthName;
  final bool isSelected;
  final Function onTap;
  final Color dayColor;
  final Color activeDayColor;
  final Color activeDayBackgroundColor;
  final bool available;
  final Color dotsColor;
  final Color dayNameColor;
  final ForecastModel forecastModel;

  const _DayItem({
    Key key,
    @required this.dayNumber,
    @required this.shortName,
    @required this.shortMonthName,
    @required this.isSelected,
    @required this.onTap,
    this.dayColor,
    this.activeDayColor,
    this.activeDayBackgroundColor,
    this.available = true,
    this.dotsColor,
    this.dayNameColor,
    this.forecastModel,
  }) : super(key: key);

  final double height = 150.0;
  final double width = 82.0;

  _buildActiveDay(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: activeDayBackgroundColor ?? Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: height,
      width: width,
      child: Column(
        children: <Widget>[
          SizedBox(height: 7),
          Text(
            shortMonthName,
            style: TextStyle(
              color: dayNameColor ?? activeDayColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Text(
            dayNumber.toString(),
            style: TextStyle(
              color: activeDayColor ?? Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 0.8,
            ),
          ),
          Text(
            shortName,
            style: TextStyle(
              color: dayNameColor ?? activeDayColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          forecastModel != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              child: Image.network(
                            forecastModel.forecastImgPath,
                            height: 40,
                            width: 40,
                            fit: BoxFit.fill,
                          )),
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Iconic.umbrella,
                                  color: Colors.blue,
                                  size: 14,
                                ),
                              ),
                              Text(
                                forecastModel.rainChance + '%',
                                style: TextStyle(
                                  color: dayNameColor ??
                                      activeDayColor ??
                                      Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            FontAwesome5.temperature_low,
                            color: Colors.blue,
                            size: 14,
                          ),
                          Text(
                            forecastModel.t_min.toString(),
                            style: TextStyle(
                              color: dayNameColor ??
                                  activeDayColor ??
                                  Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          Icon(
                            FontAwesome5.temperature_high,
                            color: Colors.red,
                            size: 14,
                          ),
                          Text(
                            forecastModel.t_max.toString(),
                            style: TextStyle(
                              color: dayNameColor ??
                                  activeDayColor ??
                                  Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          )

                        ],
                      )
                    ],
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }

  _buildDay(BuildContext context) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(horizontal: 4),
        height: height,
        width: width,
        child: Column(
          children: <Widget>[
            SizedBox(height: 14),
            Text(
              shortMonthName,
              style: TextStyle(
                color: dayNameColor ?? activeDayColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              dayNumber.toString(),
              style: TextStyle(
                  color: available
                      ? dayColor ?? Theme.of(context).accentColor
                      : dayColor?.withOpacity(0.5) ??
                          Theme.of(context).accentColor.withOpacity(0.5),
                  fontSize: 32,
                  fontWeight: FontWeight.normal),
            ),
            Text(
              shortName,
              style: TextStyle(
                color: dayNameColor ?? activeDayColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            forecastModel != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                child: Image.network(
                              forecastModel.forecastImgPath,
                              height: 40,
                              width: 40,
                              fit: BoxFit.fill,
                            )),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Iconic.umbrella,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                ),
                                Text(
                                  forecastModel.rainChance + '%',
                                  style: TextStyle(
                                    color: dayNameColor ??
                                        activeDayColor ??
                                        Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            FontAwesome5.temperature_low,
                            color: Colors.blue,
                            size: 14,
                          ),
                          Text(
                            forecastModel.t_min.toString(),
                            style: TextStyle(
                              color: dayNameColor ??
                                  activeDayColor ??
                                  Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          Icon(
                            FontAwesome5.temperature_high,
                            color: Colors.red,
                            size: 14,
                          ),
                          Text(
                            forecastModel.t_max.toString(),
                            style: TextStyle(
                              color: dayNameColor ??
                                  activeDayColor ??
                                  Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          )

                        ],
                      )
                      ],
                    ),
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isSelected ? _buildActiveDay(context) : _buildDay(context);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + this.substring(1);
  }
}
