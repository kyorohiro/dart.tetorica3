part of hetimanet_http;

class HttpClientPlus {
  TetSocketBuilder socketBuilder;
  bool verbose = false;

  HttpClientPlus(this.socketBuilder,{this.verbose: false}){}
  Future<HttpClientResponse> get(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false, SocketOnBadCertificate onBadCertificate:null}) async {
      return await base(address, port, "GET", pathAndOption, null,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,
      onBadCertificate:onBadCertificate);
  }

  Future<HttpClientResponse> delete(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false, SocketOnBadCertificate onBadCertificate:null}) async {
      return await base(address, port, "DELETE", pathAndOption, null,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,
      onBadCertificate:onBadCertificate);
  }
  Future<HttpClientResponse> head(String address, int port, String pathAndOption,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false, SocketOnBadCertificate onBadCertificate:null}) async {
      return await base(address, port, "HEAD", pathAndOption, null,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,isLoadBody:false,
      onBadCertificate:onBadCertificate);
  }
  Future<HttpClientResponse> post(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false, SocketOnBadCertificate onBadCertificate:null}) async {
      return await base(address, port, "POST", pathAndOption, data,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,
      onBadCertificate:onBadCertificate);
  }

  Future<HttpClientResponse> put(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false,SocketOnBadCertificate onBadCertificate:null}) async {
      return await base(address, port, "PUT", pathAndOption, data,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,
      onBadCertificate:onBadCertificate);
  }

  Future<HttpClientResponse> patch(String address, int port, String pathAndOption, List<int> data,
    {List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
       Map<String, String> header, int redirect: 5,
       bool reuseQuery: true, bool useSecure:false,SocketOnBadCertificate onBadCertificate:null}) async {
      return await base(address, port, "PATCH", pathAndOption, data,
      redirectStatusCode: redirectStatusCode,
      header: header, redirect: redirect,
      reuseQuery: reuseQuery,
      useSecure:useSecure,
      onBadCertificate:onBadCertificate);
  }

  Future<HttpClientResponse> base(String address, int port, String action, String pathAndOption,
     List<int> data, {
        List<int> redirectStatusCode: const [301, 302, 303, 304, 305, 307, 308],
        Map<String, String> header,
        int redirect: 5,
        bool reuseQuery: true,
        bool useSecure:false,
        isLoadBody:true,
        SocketOnBadCertificate onBadCertificate:null}) async {
    log("address:${address}, port:${port}, actopn:${action}, path:${pathAndOption}");

    HttpClient client = new HttpClient(socketBuilder,verbose: verbose);

    await client.connect(address, port, useSecure:useSecure, onBadCertificate: onBadCertificate);

    HttpClientResponse res = await client.base(action,pathAndOption, data,
      header:header,
      isLoadBody:isLoadBody);

    client.close();

    //
    if (redirectStatusCode.contains(res.info.line.statusCode)) {
      HttpResponseHeaderField locationField = res.info.find("Location");
      String scheme;
      if(useSecure) {
        scheme = "https";
      } else {
        scheme = "http";
      }
      HttpUrl hurl = HttpUrlDecoder.decodeUrl(locationField.fieldValue, "${scheme}://${address}:${port}");
      int optionIndex = pathAndOption.indexOf("?");
      String option = "";
      if(optionIndex > 0) {
        option = pathAndOption.substring(optionIndex);
      }
      pathAndOption = "${hurl.path}${option}";
      log("Location:${locationField.fieldValue}");
      log("scheme:${hurl.scheme}, address:${hurl.host}, port:${hurl.port}, actopn:${action}, path:${pathAndOption}");
      useSecure = (hurl.scheme == "https"?true:false);
      return base(hurl.host, hurl.port, action, pathAndOption, data,
        redirectStatusCode: redirectStatusCode, header: header,
        redirect: (redirect - 1),
        reuseQuery: reuseQuery,useSecure:useSecure);
    } else {
      return res;
    }
  }

  void log(String message) {
    if (verbose) {
      print("++${message}");
    }
  }
}
