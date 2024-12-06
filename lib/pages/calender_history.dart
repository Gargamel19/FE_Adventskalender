import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/provider/calender_provider.dart';
import 'package:test_app/widgets/calender/create_calender_widget.dart';

class CalenderHistoryScreen extends StatefulWidget {
  final bool user;
  const CalenderHistoryScreen({super.key, context, this.user = false});

  @override
  CalenderHistoryScreenState createState() => CalenderHistoryScreenState();
}

class CalenderHistoryScreenState extends State<CalenderHistoryScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  bool _showScrollIcon = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchController.addListener(_searchListener);
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_pageListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refresh(context);
    });
  }

  _searchListener() {}

  _checkAndLoadUntilFull() async {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //refresh();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    bool shouldHideIcon = _scrollController.position.pixels > 50;
    if (_showScrollIcon != shouldHideIcon) {
      setState(() {
        _showScrollIcon = shouldHideIcon;
      });
    }
  }

  void _pageListener() async {}

  refresh(BuildContext context) async {
    CalenderProvider calenderProvider = Provider.of<CalenderProvider>(context, listen: false);
    await calenderProvider.fetchAllCalender(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calender History'),
      ),
      body: Consumer<CalenderProvider>(
          builder: (context, calenderProvider, child) {
        return ListView.builder(
            controller: _scrollController,
            itemCount: calenderProvider.calenderList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text(calenderProvider.calenderList[index].name),
                    subtitle: Text(calenderProvider.calenderList[index].owner.username),
                  )
                ),
              );
            });
      }),
      floatingActionButton: 
        FloatingActionButton(
          onPressed: () => {
            showModalBottomSheet<dynamic>(
                  useRootNavigator: false,
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return CreateCalenderWidget();
                  },
                ),
          },
          child: const Icon(Icons.add),
        ),
    
    );
  }
}
