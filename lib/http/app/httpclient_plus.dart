part of hetimanet_http;

class HttpClientPlus {
  TetSocketBuilder socketBuilder;
  bool _verbose = false;

  HttpClientPlus(this.socketBuilder,{bool verbose: false}){}
  Future<HttpClientResponse> get(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false}) async {
      return await base(address, port, "GET", pathAndOption, null,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure);
  }

  Future<HttpClientResponse> delete(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false}) async {
      return await base(address, port, "DELETE", pathAndOption, null,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure);
  }
  Future<HttpClientResponse> head(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false}) async {
      return await base(address, port, "HEAD", pathAndOption, null,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,isLoadBody:false);
  }
  Future<HttpClientResponse> post(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false}) async {
      return await base(address, port, "POST", pathAndOption, data,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure);
  }

  Future<HttpClientResponse> put(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false}) async {
      return await base(address, port, "PUT", pathAndOption, data,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure);
  }

  Future<HttpClientResponse> patch(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false}) async {
      return await base(address, port, "PATCH", pathAndOption, data,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure);
  }

  Future<HttpClientResponse> base(String address, int port, String action, String pathAndOption,
     List<int> data, {
      List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
      Map<String, String> header, int redirect: 5, bool reuseQuery: true,
      bool useSecure:false, isLoadBody:true}) async {
    log("address:${address}, port:${port}, actopn:${action}, path:${pathAndOption}");
    HttpClient client = new HttpClient(socketBuilder,verbose: _verbose);
    await client.connect(address, port, useSecure:useSecure);
    HttpClientResponse res = await client.base(action,pathAndOption, data,
      header:header,
      isLoadBody:isLoadBody);
    client.close();
    //
    if (redirectStatusCode.contains(res.info.line.statusCode)) {
      HttpResponseHeaderField locationField = res.info.find("Location");
      HttpUrl hurl = HttpUrlDecoder.decodeUrl(locationField.fieldValue, "http://${address}:${port}");
      int optionIndex = pathAndOption.indexOf("?");
      String option = "";
      if(optionIndex > 0) {
        option = pathAndOption.substring(optionIndex);
      }
      pathAndOption = "${hurl.path}${option}";
      log("scheme:${hurl.scheme}, address:${hurl.host}, port:${hurl.port}, actopn:${action}, path:${pathAndOption}");

      return base(hurl.host, hurl.port, action, pathAndOption, data,
        redirectStatusCode: redirectStatusCode, header: header,
        redirect: (redirect - 1),
        reuseQuery: reuseQuery,useSecure:useSecure);
    } else {
      return res;
    }
  }

  void log(String message) {
    if (_verbose) {
      print("++${message}");
    }
  }
}
