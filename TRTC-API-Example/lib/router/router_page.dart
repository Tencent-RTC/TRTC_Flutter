import 'package:flutter/material.dart';
import 'package:api_example/router/router_info.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({Key? key}) : super(key: key);

  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  bool _isBasicRoomsExpanded = true;
  bool _isAdvancedAVExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Router Page'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: _isBasicRoomsExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isBasicRoomsExpanded = expanded;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Basic Rooms',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  children: [
                    ...basicRoomList.map((room) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            child: room.icon,
                          ),
                          title: Text(
                            room.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => room.page),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: _isAdvancedAVExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isAdvancedAVExpanded = expanded;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Advanced AV',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  children: [
                    ...advanceAvList.map((room) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            child: room.icon,
                          ),
                          title: Text(
                            room.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => room.page),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: _isAdvancedAVExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isAdvancedAVExpanded = expanded;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Advanced Other',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  children: [
                    ...advanceOtherList.map((room) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: room.icon,
                      ),
                      title: Text(
                        room.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => room.page),
                        );
                      },
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}