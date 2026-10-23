_: {
  services.changedetection-io = {
    enable = true;
    behindProxy = true;
    baseURL = "https://changedetection.rucaslab.com";
  };

  systemd.services.changedetection-io.environment = {
    # NOTE: DEBUG is the default and logged ~12 lines/sec across three watches
    LOGGER_LEVEL = "WARNING";
    # NOTE: Global floor, ANDed with the per-watch threshold in the ticker thread
    # (flask_app.py:1190), so it wins whenever it is the larger of the two. The
    # datastore is set to 3s and Settings will keep displaying that while this
    # clamps the real interval — lower this too before any watch can run faster.
    MINIMUM_SECONDS_RECHECK_TIME = "60";
  };
}
