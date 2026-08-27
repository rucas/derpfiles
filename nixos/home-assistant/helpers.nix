_: {
  services.home-assistant.config = {
    input_boolean.dishwasher_needs_running = {
      name = "Dishwasher Needs Running";
      icon = "mdi:dishwasher";
    };

    # No `initial` — it would clobber the restored value on every restart.
    # Seeded on first boot by automations/dishwasher_reminder.nix.
    input_datetime.bedtime = {
      name = "Bedtime";
      icon = "mdi:bed-clock";
      has_date = false;
      has_time = true;
    };
  };
}
