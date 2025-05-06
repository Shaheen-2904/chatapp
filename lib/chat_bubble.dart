import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chatapp/utils/app_state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chatapp/utils/common_constants.dart' as constants;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class ChatBubble extends StatefulWidget {
  ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    required this.isMapView,
    this.timestamp,
    this.logMessage,
    this.imageUrl,
    this.tableColumnData,
    this.tableRowData,
    this.errorLog,
    this.hasErrorLog,
    this.timestampMapping,
    this.sessionId,
    this.chainOfThoughts,
    this.followUpQuestions,
    this.token,
    this.expandChainOfThought,
    this.sessionExpired,
  }) : super(key: key);

  final String text;
  final bool isUser;
  final bool isMapView;
  final String? timestamp;
  final String? imageUrl;
  final List<dynamic>? tableColumnData;
  final List<dynamic>? tableRowData;
  final String? logMessage;
  final String? errorLog;
  final bool? hasErrorLog;
  final Map<String, String>? timestampMapping;
  final String? sessionId;
  final Map<String, String>? chainOfThoughts;
  late List<String>? followUpQuestions;
  final String? token;
  late bool? expandChainOfThought;
  late bool? sessionExpired;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  // bool isExpanded = false;
  ValueNotifier<bool> show = ValueNotifier<bool>(true);
  Map<String, bool> _expanded = {};
  LatLng mapCenter = LatLng(17.40086, 78.34050);
  List<Color> colors = [
    const Color(0xFFCFE2FF).withOpacity(0.5), //blue
    const Color(0xFFFFF3CD).withOpacity(0.5), //yellow
    const Color(0xFFf8d7da).withOpacity(0.5), //pink
    const Color(0xFFcff4fc).withOpacity(0.5), //skyblue
  ];

  @override
  void initState() {
    super.initState();
    show.value = widget.expandChainOfThought!;
    _expanded = {};
    if (widget.chainOfThoughts != null) {
      for (String key in widget.chainOfThoughts!.keys) {
        _expanded[key] = false;
      }
    }
    _sessionExpiry();
  }

  _sessionExpiry() {
    // print("session expiry--${widget.sessionExpired}");
    if (widget.sessionExpired != null && widget.sessionExpired == true) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasContent = widget.text.isNotEmpty ||
        (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ||
        (widget.followUpQuestions != null &&
            widget.followUpQuestions!.isNotEmpty);

    bool hasChainOfThoughts =
        widget.chainOfThoughts != null && widget.chainOfThoughts!.isNotEmpty;

    return (hasContent)
        ? Padding(
            padding: EdgeInsets.fromLTRB(
              widget.isUser ? 64.0 : 16.0,
              4,
              widget.isUser ? 16.0 : 8.0,
              4,
            ),
            child: Align(
              alignment:
                  widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                children: [
                  if (widget.isUser && hasChainOfThoughts)
                    ValueListenableBuilder(
                      builder: (context, value, _) {
                        return (show.value &&
                                widget.chainOfThoughts != null &&
                                widget.chainOfThoughts!.isNotEmpty)
                            ? showChainOfThoughts()
                            : const SizedBox();
                      },
                      valueListenable: show,
                    ),
                  Row(
                    mainAxisAlignment: widget.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isUser)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: SizedBox(
                            height: 36,
                            width: 36,
                            child: CircleAvatar(
                              radius: 50,
                              // backgroundImage: AssetImage('assets/images/male_bot.jfif'),
                              backgroundImage:
                                  AssetImage('assets/images/male_bot.jfif'),
                            ),
                          ),
                        ),
                      const SizedBox(
                        width: 8,
                      ),
                      if (hasContent)
                        Flexible(
                          child: Column(
                              crossAxisAlignment: widget.isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (hasContent)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: widget.isUser
                                          ? const Color(0xffE2E3E4)
                                              .withOpacity(0.6)
                                          : const Color(0xFFcff4fc)
                                              .withOpacity(0.5),
                                      // : Colors.green[500],
                                      borderRadius: widget.isUser
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            )
                                          : const BorderRadius.only(
                                              topRight: Radius.circular(16),
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.imageUrl != null &&
                                              widget.imageUrl!.isNotEmpty)
                                            _imageView(),
                                          if (widget.tableColumnData != null &&
                                              widget.tableColumnData!
                                                  .isNotEmpty &&
                                              widget.tableRowData != null &&
                                              widget.tableRowData!.isNotEmpty)
                                            _tableView(),
                                          const SizedBox(height: 10),
                                          if (widget.text.isNotEmpty)
                                            _formattedTextView(),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (widget.timestamp != null &&
                                    widget.timestamp!.isNotEmpty)
                                  Text(
                                    _formatTimestamp(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ]),
                        ),
                      if (widget.isUser) _userProfileView(),
                    ],
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }

  List<Widget> chainOfThoughts() {
    List<Widget> widgets = [];
    if (show.value &&
        widget.chainOfThoughts != null &&
        widget.chainOfThoughts!.isNotEmpty) {
      widgets.add(const Text(
        'Chain of Thoughts',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ));
      widgets.add(const SizedBox(height: 8));
      int colorCount = 0;
      widget.chainOfThoughts!.forEach((key, value) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_expanded[key] == null) {
                  _expanded[key] = false;
                }
                _expanded[key] = !_expanded[key]!;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(constants.xSmallPadding),
              decoration: BoxDecoration(
                color: colors[colorCount % 4],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key.trim(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (_expanded[key] != null && _expanded[key] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        value.trim(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
        colorCount++;
      });
    }
    return widgets;
  }

  Color randomCotColor(List<Color> colors) {
    colors.shuffle(Random());
    return colors.first;
  }

  _infoView() {
    return GestureDetector(
      onTap: () {
        showInformation(widget.logMessage!);
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Icon(
          Icons.info,
          color: Colors.grey,
        ),
      ),
    );
  }

  _userProfileView() {
    return SizedBox(
      // height: 40,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: SizedBox(
              height: 32,
              width: 32,
              child: CircleAvatar(
                radius: 0,
                backgroundImage: AssetImage('assets/images/vani.png'),
              ),
            ),
          ),
          /*        (widget.chainOfThoughts != null && widget.chainOfThoughts!.isNotEmpty)
              ? ValueListenableBuilder(
                  builder: (context, value, _) {
                    return IconButton(
                        onPressed: () {
                          show.value = !show.value;
                        },
                        icon: value
                            ? const Icon(Icons.keyboard_arrow_up)
                            : const Icon(Icons.keyboard_arrow_down));
                  },
                  valueListenable: show,
                )
              : const SizedBox(),*/
        ],
      ),
    );
  }

  void showInformation(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info'),
        content: SingleChildScrollView(child: Text(message!)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(
          imageUrl,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  List<DataColumn> generateColumns(List<dynamic> row) {
    return List.generate(
      row.length,
      (index) => DataColumn(
        label: SizedBox(
          // Distribute width evenly for each column
          child: Text(row[index].toString()),
        ),
      ),
    );
  }

  _tableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Tabular Data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              // columnSpacing: 12,
              dataRowHeight: 40,
              columns: generateColumns(widget.tableColumnData!),
              rows: List.generate(
                widget.tableRowData!.length,
                (index) => DataRow(
                  cells: List.generate(
                    widget.tableRowData![index]!.length,
                    (cellIndex) => DataCell(
                      SizedBox(
                        child: Text(
                            widget.tableRowData![index][cellIndex].toString()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _imageView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            showImage(widget.imageUrl!);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            // child: Image.asset(widget.imageUrl ?? ''),
            child: Image.network(
              widget.imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  _formattedTextView() {
    // Trim the text and handle single quotes
    String trimmedText = widget.text.trim().replaceAll("'", "");
    if (trimmedText.startsWith("'")) {
      trimmedText = trimmedText.substring(1);
    }
    if (trimmedText.endsWith("'")) {
      trimmedText = trimmedText.substring(0, trimmedText.length - 1);
    }
    if (trimmedText.endsWith('"')) {
      trimmedText = trimmedText.substring(0, trimmedText.length - 1);
    }

    trimmedText.replaceAll('\u200c', '');
    // Split the text by line breaks (\\n)
    List<String> lines = trimmedText.split('\\n');

    // Process each line to apply bold formatting and replace '*' with '•'
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Apply bold formatting first
        final boldTextLine = _parseText(line);

        // Replace '*' with '•' in the bold formatted text
        final bulletPointText = boldTextLine.map((span) {
          String text = span.text ?? '';
          return TextSpan(
            text: text.replaceAll('*', ''),
            style: span.style,
          );
        }).toList();

        return RichText(
          text: TextSpan(
            children: bulletPointText,
            style: const TextStyle(
              color: Color(0xff1E1E1E),
              fontSize: 14.0, // adjust as needed
            ),
          ),
        );
      }).toList(),
    );
  }

  _textView() {
    return SelectableText(
      widget.text.trim(),
      style: const TextStyle(
        // color: !widget.isUser ? const Color(0xffFFFFFF) : const Color(0xff1E1E1E),
        color: Color(0xff1E1E1E),
      ),
    );
  }

  List<TextSpan> _parseText(String text) {
    text.replaceAll('\u200c', '');
    // Split text by new lines
    final lines = text.split('\n');

    return lines.map((line) {
      if (line.trim().startsWith('*')) {
        // If line starts with '*', make it bold
        return TextSpan(
          text: '${line.trim()}\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      } else {
        // Regular text
        return TextSpan(
          text: '${line.trim()}\n',
          style: const TextStyle(fontWeight: FontWeight.normal),
        );
      }
    }).toList();
  }

  Future _pushFollowUpQuestionInFirebase(String data) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${AppState.instance.sessionId}");

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    print(
        "wewewew data:: ${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");

    await ref.child(timeStamp).set({
      "is_user": true,
      "message": data,
      "image_url": '',
      "language": AppState.instance.language.toLowerCase(),
      "model_uuid": AppState.instance.modelUUID,
      "mode": '',
      "token": AppState.instance.token,
      "sm_enabled": true,
    });
    setState(() {});
  }

  _followUpQuestionsView() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        color: Colors.greenAccent.withOpacity(0.1),
        // elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppState.instance.language.toLowerCase() == 'english'
                    ? 'What else would you like to know?'
                    : '"आप और क्या जानना चाहेंगे?"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.followUpQuestions!.map((question) {
                  return GestureDetector(
                    onTap: () async {
                      await _pushFollowUpQuestionInFirebase(question);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void validateToken(bool isUser, bool? isValidToken, bool? isLimitExceeded) {
    if (!isUser && (isLimitExceeded! || !isValidToken!)) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Session Expired");
    }
  }

  Widget showChainOfThoughts() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.black.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chain of Thoughts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...widget.chainOfThoughts!.entries.map((entry) {
                    int colorIndex = widget.chainOfThoughts!.keys
                            .toList()
                            .indexOf(entry.key) %
                        4;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _expanded[entry.key] =
                                !(_expanded[entry.key] ?? false);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: colors[colorIndex],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key.trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              if (_expanded[entry.key] == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    entry.value.trim(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapView() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: FlutterMap(
        options: MapOptions(
          center: mapCenter,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                  builder: (context) => const Icon(Icons.location_pin,
                      color: Colors.red, size: 40),
                  width: 40.0,
                  height: 40.0,
                  point: mapCenter),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp() {
    // Remove " UTC" and parse the DateTime
    String rawTimestamp =
        widget.timestamp!.replaceAll(" UTC", "Z"); // "Z" denotes UTC in ISO8601
    final dateTime = DateTime.parse(rawTimestamp)
        .toLocal(); // toLocal() if you want local time
    return DateFormat('MMM dd yyyy - h:mm:ss').format(dateTime);
  }
}
