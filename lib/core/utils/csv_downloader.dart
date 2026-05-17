/// Platform-agnostic CSV download entry point.
///
/// On web: uses dart:html to trigger a browser file download.
/// On mobile/desktop: no-op stub (this feature is web-only).
export 'csv_downloader_stub.dart'
    if (dart.library.html) 'csv_downloader_web.dart';
