import 'dart:convert';

import 'package:http/http.dart';

import '../models/colections_model.dart';
import '../models/user_model.dart';

  class HttpServices {

    static bool isTester = true;

    static String SERVER_DEVELOPMENT = "api.unsplash.com";
    static String SERVER_PRODUCTION = "api.unsplash.com";
    static String API_COLLECTIONS = "/collections";


    static Map<String, String> getHeaders() {
      Map<String, String> headers = {
        'Accept-Version': 'v1',
        'Authorization': 'Client-ID ea376P2b3Z1sC__Iw86xYsVL9GugiotBqRQ24yIIUsk'
      };
      return headers;
    }

    static String getServer() {
      if (isTester) return SERVER_DEVELOPMENT;
      return SERVER_PRODUCTION;
    }

    static Future<String?> GET(String api, Map<String, dynamic> params) async {
      var uri = Uri.https(getServer(), api, params); // http or https
      Response response = await get(uri, headers: getHeaders());
      if (response.statusCode == 200) return response.body;
      return null;
    }


    /// HTTP APIS
    static String API_LIST = "/photos";
    static String API_SEARCH = "/search/photos";

    /// PARAMS




    static Map<String, dynamic> paramsEmpty() {
      Map<String, String> params = {};
      return params;
    }

    static Map<String, String> paramsSearch(int page, String category) {
      Map<String, String> params = {'page': '$page', 'query': category};
      return params;
    }
    static List<UsersModels> parseUserModelLIst(String response) {
      //var json = jsonDecode(response);
      var data = usersModelsFromJson(response);
      return data;
    }

    static List<UsersModels> pareseSearchModelsList(String response) {

      var json = jsonDecode(response);
      var data = usersModelsFromJson(jsonEncode(json['results']));
      return data;
    }

    static List<Collections> parseCollectionResponse(String response) {
      List json = jsonDecode(response);
      List<Collections> collections = List<Collections>.from(json.map((x) => Collections.fromJson(x)));
      return collections;
    }
  }





