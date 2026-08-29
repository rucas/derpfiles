_: {
  services.home-assistant.config = {
    input_boolean.dishwasher_needs_running = {
      name = "Dishwasher Needs Running";
      icon = "mdi:dishwasher";
    };

    # Suppresses automations that only make sense with someone in the house.
    # Automations opt in by testing for "off" rather than the toggle switching
    # anything off itself, so flipping it never leaves a device stranded.
    input_boolean.vacation_mode = {
      name = "Vacation Mode";
      icon = "mdi:bag-suitcase";
    };

    # `initial` re-applies on every restart rather than restoring the previous
    # value. That is the point here: Nix owns the time, so a UI edit survives
    # only until the next restart. Wall-clock, interpreted in the host time
    # zone (`time.timeZone`), so it follows the PST/PDT shift on its own.
    # dishwasher_reminder.nix triggers on this entity instead of a literal,
    # which keeps this the single source of truth for the nag time.
    input_datetime.bedtime = {
      name = "Bedtime";
      icon = "mdi:bed-clock";
      has_date = false;
      has_time = true;
      initial = "21:00:00";
    };
  };
}
