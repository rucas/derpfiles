_: {
  services.home-assistant.config = {
    input_boolean.dishwasher_needs_running = {
      name = "Dishwasher Needs Running";
      icon = "mdi:dishwasher";
    };

    # No `initial` — it would clobber the restored value on every restart, and
    # an unseeded input_datetime reads as 00:00:00 rather than unknown, so a
    # "seed if unset" guard cannot tell the two apart. Nothing consumes this
    # yet; dishwasher_reminder.nix triggers on a literal 21:00:00 instead.
    input_datetime.bedtime = {
      name = "Bedtime";
      icon = "mdi:bed-clock";
      has_date = false;
      has_time = true;
    };
  };
}
