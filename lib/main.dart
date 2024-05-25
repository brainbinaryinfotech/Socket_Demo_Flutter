import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:socketdemo/socketIo.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(title: "jug")
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  // final _channel = WebSocketChannel.connect(
  //   Uri.parse('wss://trk.livemtr.com/graphql'),//wss://trk.livemtr.com/graphql
  // );
  //WebSocketChannel _channel = IOWebSocketChannel.connect("wss://trk.livemtr.com/graphql");
   ValueNotifier<GraphQLClient>? client;

var w  ='''
subscription{
  receiveLocation(IMEINumber:"865006046931904"){
    packetType,
    latitude,
    longitude
  }
}
''';
  StreamSubscription? _subscription;
  final _updateInterval = Duration(seconds: 3);

  @override
  void initState() {
    final WebSocketLink webSocketLink = WebSocketLink(
      'wss://tracking-api.testmbtrsas.com/graphql', // Replace with your server's WebSocket URL
      config: SocketClientConfig(
        autoReconnect: true,
        initialPayload: {"authToken": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtb2JpdHJhIiwiZXhwIjoxNzI1NTQyNjAxLCJpYXQiOjE2OTQwMDY2MDF9.ZpByIOAhtbw_iwCmukvIW8KdIa7T1uebmwpgY9kMtAE"},

        inactivityTimeout: Duration(seconds: 5),
      ),
    );

     HttpLink? httpLink = HttpLink(
      'https://tracking-api.testmbtrsas.com/graphql', // Replace with your server's HTTP URL
      defaultHeaders: <String, String>{
        'x-token': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtb2JpdHJhIiwiZXhwIjoxNzI1NTQyNjAxLCJpYXQiOjE2OTQwMDY2MDF9.ZpByIOAhtbw_iwCmukvIW8KdIa7T1uebmwpgY9kMtAE',
      },

    );

    final Link link = Link.split(
          (request) => request.isSubscription,
      webSocketLink,
      httpLink,
    );

    //var link =httpLink.concat(webSocketLink);

   client  = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      ),
    );

     //
     // _subscribeToDataUpdates();
    //
    // // Use a periodic timer to refresh data every 3 seconds.
    // Timer.periodic(_updateInterval, (Timer timer) {
    //   // Check if the subscription is still active before resubscribing.
    // //  if (_subscription?.isPaused == true) {
    //     _subscribeToDataUpdates();
    //   //}
    // });
    //_subscribeToDataUpdates();

    super.initState();
  }
var subscriptionStream;
var location ='';
var time ='';
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
     client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Send a message'),
                  ),
                ),
                const SizedBox(height: 24),
                // StreamBuilder(
                //   stream: _channel.stream,
                //   builder: (context, snapshot) {
                //     return Column(
                //       children: [
                //          Text(snapshot.hasData ? '${snapshot.data}' : 'no data'),
                //         Text(snapshot.connectionState.toString()),
                //         InkWell(
                //             onTap: (){
                //               if(snapshot.connectionState == ConnectionState.active){
                //                 Navigator.of(context).push(MaterialPageRoute(builder: (context){
                //                   return ScoketIo();
                //                 }));
                //               }
                //
                //             },
                //             child: Text("next")),
                //       ],
                //     );
                //   },
                // ),

                // StreamBuilder(
                //   builder: (context,snapshot) {
                //     return Query(
                //       options: QueryOptions(
                //        document: gql(w), // Replace with your subscription query
                //       ),
                //       builder: (QueryResult? result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                //         if (result!.hasException) {
                //           return Text(result!.exception.toString());
                //         }
                //
                //         if (result.isLoading) {
                //           return CircularProgressIndicator();
                //         }
                //
                //         // Handle the data from the subscription here
                //         // result.data will contain the subscription data
                //         print("data loaded");
                //         return Text(result.data.toString());
                //       },
                //     );
                //   }
                // )

                Subscription(
                  options: SubscriptionOptions(
                    document: gql(w),
                  ),
                  builder: (QueryResult result) {
                    if (result.hasException) {
                      // Handle subscription error
                      return Text('Error: ${result.exception.toString()}');
                    }

                    if (result.isLoading) {
                      // Handle loading state
                      return CircularProgressIndicator();
                    }

                    // Handle subscription data here
                    final subscriptionData = result.data;

                    // Update your UI with the new data
                    // ...
print("data load");
                    return Text('Updated Data: $subscriptionData');
                  },
                )

//                 StreamBuilder(
//                   stream: client!.value.subscribe(SubscriptionOptions(
//                     document: gql(w),
//                   )), // Replace with your GraphQL subscription stream
//                   builder: (BuildContext context, AsyncSnapshot<QueryResult> snapshot) {
//                     if (snapshot.hasData && !snapshot.hasError) {
// print('data loaded');
//                       final data = snapshot.data!.data;
//
//
//
//                       // Update your UI with the new data
//                       return Text( data.toString());
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error.toString()}');
//                     } else {
//                       return CircularProgressIndicator();
//                     }
//                   },
//                 )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _sendMessage,
          tooltip: 'Send message',
          child: const Icon(Icons.send),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

locationGet(var lat,var long)async{
  List<Placemark> placemarks =
      await placemarkFromCoordinates(  lat,   long);

  Placemark place = placemarks[0];
  location =  ("${place.name} ${place.subLocality} ${place.locality} ${place.postalCode} ${place.country}");
return location;
}
  // void _subscribeToDataUpdates() {
  //   final query = gql(w);
  //
  //   _subscription = client
  //       ?.value
  //       .subscribe(SubscriptionOptions(
  //     document: query,
  //   ))
  //       .listen((result) {
  //     if (result.hasException) {
  //       print('Error: ${result.exception.toString()}');
  //       // Handle the error as needed.
  //     } else if (result.data != null) {
  //       final data = result.data;
  //       // Update your UI with the new data.
  //       location = data?['lastLocation'][0]['latitude'].toString()??'';
  //       time = DateTime.now().toString();
  //       setState(() {
  //
  //       });
  //       print('Received Data: $data');
  //     }
  //   });
  // }
  void _subscribeToDataUpdates() {
    final subscriptionRequest = SubscriptionOptions(
      document: gql(w),
    );

    final graphQLClient = client; // Get the GraphQL client from your context

     subscriptionStream = graphQLClient!.value.subscribe(subscriptionRequest);

    subscriptionStream.listen((QueryResult result) {
      if (!result.hasException) {
        // Handle the new data, e.g., update a state variable or a stream
        final newData = result.data;

        // Update your state or stream with newData

      } else {
        print('Error in subscription: ${result.exception.toString()}');
      }
    });

    // Set up a timer to resubscribe every 3 seconds
    Timer.periodic(Duration(seconds: 3), (_) {
      //if (subscriptionStream.isClosed) {
        // Re-open the subscription stream
        subscriptionStream =
            graphQLClient!.value.subscribe(subscriptionRequest);

      //}
    });
  }
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      //_channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
   // _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
//
// void main() {
//   runApp(GraphQLSubscriptionDemo());
// }
//
// class GraphQLSubscriptionDemo extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final HttpLink httpLink = HttpLink(
//        'https://trk.livemtr.com/graphql',
//     );
//
//     final WebSocketLink websocketLink = WebSocketLink(
//       'wss://trk.livemtr.com/graphql',
//       config: SocketClientConfig(
//         autoReconnect: true,
//         inactivityTimeout: Duration(seconds: 30),
//       ),
//     );
//
//     ValueNotifier<GraphQLClient> client = ValueNotifier(
//       GraphQLClient(
//         cache: GraphQLCache(),
//         link: httpLink.concat(websocketLink),
//       ),
//     );
//
//     return GraphQLProvider(
//       client: client,
//       child: MaterialApp(
//         home: Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.green,
//             title: Text("Graphql Subscription Demo"),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   IncrementButton(),
//                   SizedBox(height: 3, child: Container(color: Colors.green)),
//                   Counter()
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class IncrementButton extends StatelessWidget {
//   static String incr = '''subscription{
//   receiveLocation(IMEINumber:"865006044966704"){
//     packetType
//   }
// }''';
//
//   @override
//   Widget build(BuildContext context) {
//     return Mutation(
//       options: MutationOptions(
//         document: gql(incr),
//       ),
//       builder: (
//           RunMutation? runMutation,
//           QueryResult? result,
//           ) {
//         return Center(
//           child: IconButton(
//             onPressed: () {
//               runMutation!({});
//             },
//             icon: Icon(Icons.plus_one),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class Counter extends StatelessWidget {
//   static String subscription = '''subscription{
//   receiveLocation(IMEINumber:"865006044966704"){
//     packetType
//   }
// }''';
//
//   @override
//   Widget build(BuildContext context) {
//     return Subscription(
//       options: SubscriptionOptions(
//         document: gql(subscription),
//       ),
//         builder: (result) {
//           if (result.hasException) {
//             print(result.exception.toString());
//             return Text(result.exception.toString());
//           }
//
//           if (result.isLoading) {
//             return Center(
//               child: const CircularProgressIndicator(),
//             );
//           }
//           // ResultAccumulator is a provided helper widget for collating subscription results.
//           // careful though! It is stateful and will discard your results if the state is disposed
//           return ResultAccumulator.appendUniqueEntries(
//             latest: result.data,
//             builder: (context, {results}) => Container()
//           );
//         }
//     );
//   }
// }