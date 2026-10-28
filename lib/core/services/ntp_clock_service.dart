/// Provides UTC timestamps for audit logging.
/// Reference: AGENT.md Section 5 Rule 6.
class NtpClockService {
  int _clockOffsetMs = 0;

  /// Sets clock offset obtained from time server sync.
  void updateOffset(int offsetMs) {
    _clockOffsetMs = offsetMs;
  }

  /// Returns current NTP-corrected wall-clock time in UTC milliseconds.
  int nowUtcMs() {
    return DateTime.now().toUtc().millisecondsSinceEpoch + _clockOffsetMs;
  }
}
