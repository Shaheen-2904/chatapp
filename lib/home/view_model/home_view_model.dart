import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chatapp/shared/loading_view_model.dart';
import 'package:chatapp/utils/common_constants.dart' as constants;
import 'package:uuid/uuid.dart';
import '../../utils/app_state.dart';
import '../../utils/network_utils.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/util.dart';
import 'package:http/http.dart' as http;
import '../model/available_models.dart' as model;
import '../repo/home_repo.dart';

class HomeViewModel extends LoadingViewModel {
  HomeViewModel({
    required this.repo,
  });

  final HomeRepository repo;

  String selectedValue = '';
  String selectedLang = '';
  String selectedModel = '';
  String selectedMode = '';
  bool isFirstTime = true;
  String? sessionId;
  List<String> selectionList = ['Internal LLM', 'External LLM'];
  List<String> langList = [];

  // List<String> modeList = ['default', 'langchain', 'autogen', 'database' ,'unstructured' , 'user'];
  List<String> modeList = [
    'Data Interaction Chat',
    'Dashboard',
    'Hybrid Database'
  ];
  Map<String, String> modeNameMapping = {
    'Data Interaction Chat': 'data_interaction_chat',
    'Dashboard': 'dashboard',
    'Hybrid Database': 'hybrid_database'
  };
  List<String>? modelList = [];
  List<model.Response>? modelResponseList = [];
  Map<String, String> modelNameUuidMapping = {};
  Map<String, String> promptTemplateIntentMapping = {};

  void clearData() {
    promptTemplateIntentMapping.clear();
    modelNameUuidMapping.clear();
    modelResponseList = [];
    modelList?.clear();
    // langList.clear();
    selectedValue = '';
    selectedLang = '';
    selectedModel = '';
    sessionId = '';
    notifyListeners();
  }

  void updateSelectedModel(String value) {
    selectedModel = value;
    AppState.instance.modelName = value;
    AppState.instance.modelUUID = modelNameUuidMapping[value]!;
    notifyListeners();
  }

  void updateSelectedMode(String value) {
    selectedMode = value;
    AppState.instance.mode = modeNameMapping[value]!;
    notifyListeners();
  }

  void updateSelectedValue(String value) {
    selectedValue = value;
    notifyListeners();
  }

  void updateSelectedLanguage(String value) {
    selectedLang = value;
    AppState.instance.language = value;
    notifyListeners();
  }

  setLogoutSharedPreferences(BuildContext context) async {
    await SecuredStorageUtil.instance.deleteAllSecureData();
    AppState.instance.userName = '';
    AppState.instance.userData = '';
    AppState.instance.userId = '';
    AppState.instance.locType = '';
    AppState.instance.locUUID = '';
    AppState.instance.locName = '';
    AppState.instance.fcmToken = '';
    AppState.instance.language = '';
    notifyListeners();
  }

  Future<bool?> deleteToken(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        int? statusCode = await repo.deleteToken(context);

        if (statusCode != null) {
          if (statusCode == 200) {
            isLoading = false;
            notifyListeners();
            return true;
          } else {
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong,Please try later'),
            ));
          }
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Home View Model', 'Error :  $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }

  Future? getAvailableModels(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        model.AvailabeModelResponse availabeModelResponse =
            await repo.fetchModels(context);

        if (availabeModelResponse.statusCode == 200 &&
            availabeModelResponse.result == true) {
          if (availabeModelResponse.response != null &&
              availabeModelResponse.response?.length != 0) {
            for (int i = 0; i < availabeModelResponse.response!.length; i++) {
              modelNameUuidMapping.addAll({
                availabeModelResponse.response![i].modelName!:
                    availabeModelResponse.response![i].modelUuid!
              });
              if (!modelList!
                  .contains(availabeModelResponse.response![i].modelName)) {
                modelList!.add(availabeModelResponse.response![i].modelName!);
              }
            }
            isLoading = false;
            print("weweweww modelNameUuidMapping ${modelNameUuidMapping}");
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Home View Model', 'Error :  $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }

  Future<String?> createSession() async {
    try {
        String uuid = const Uuid().v4();
      sessionId = uuid;
      print("sessionId::$sessionId");
      isFirstTime = true;
      notifyListeners();
      return uuid;
      isLoading = true;
      String url = constants.genAiBaseUrl + constants.createSessionEndpoint;
      String data = AppState.instance.userData;
      print("data::${data}");
      /* Content data = login.Content(
        project_uuid: '6f86292b-dd9a-4987-bb8f-c3940263b349',
        username: "APWRIMS",
        userId: '44',
        firstName: 'APWRIMS',
        userDetailsJson: UserDetailsJson(
          data: login.Data(
            locType: 'mandal',
            location: login.Location(state: [
              login.State(
                  stateName: 'Andhra Pradesh',
                  stateUUID: "6f86292b-dd9a-4987-bb8f-c3940263b349",
                  district: [
                    login.District(
                        districtName: 'Srikakulam',
                        districtUUID: '00bb53a0-a27e-46c4-9016-fe9545766cb9',
                        mandal: [
                          login.Mandal(
                              mandalName: 'BURJA',
                              mndalUUID: '1437f9bf-207a-4d7e-bd9d-0af79b6ef8db')
                        ]),
                  ]),
            ]),
          ),
        ),
      );*/
      http.Response response = await http.post(
        Uri.parse(url),
        body: data,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        print("sessionId:: ${jsonDecode(response.body)["session_id"]}");
        sessionId = jsonDecode(response.body)["session_id"];
        isFirstTime = false;
        notifyListeners();
        isLoading = false;
        return sessionId;
      } else {
        Fluttertoast.showToast(msg: "Couldn't create Session");
      }
    } catch (error, stacktrace) {
      Fluttertoast.showToast(msg: "Couldn't create Session");
      print("Error Stacktrace $error $stacktrace");
    }
    isLoading = false;
    return null;
  }

  void updateFirstTimeValue() {
    isFirstTime = true;
    notifyListeners();
  }

  deleteData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "CHAT_BOT_ONDEMAND_QUERY_DATA/6f86292b-dd9a-4987-bb8f-c3940263b349/44/");
    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        for (var childSnapshot in snapshot.children) {
          await ref.child(childSnapshot.key!).remove();
        }
        print('All child nodes deleted successfully.');
      } else {
        print('No data found at the given path.');
      }
    } catch (e) {
      print('Failed to delete data: $e');
    }
    // await ref.remove();
    print("deleted 888");
  }
}
