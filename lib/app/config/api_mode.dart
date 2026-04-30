/// How the client chooses between in-process REST mocks and real HTTP.
///
/// [ApiMode.auto]: mock when [AppConfig.apiBaseUrl] contains `example.com`
/// (legacy demo default), else live.
enum ApiMode { auto, mock, live }
