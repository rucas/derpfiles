{ lib, entities }:
rec {
  triggers = {
    time = at: {
      platform = "time";
      inherit at;
    };

    timeCron = cron: {
      platform = "time_pattern";
      inherit cron;
    };

    state = { entity_id, to ? null, from ? null, for_duration ? null }:
      {
        platform = "state";
        inherit entity_id;
      }
      // lib.optionalAttrs (to != null) { inherit to; }
      // lib.optionalAttrs (from != null) { inherit from; }
      // lib.optionalAttrs (for_duration != null) { for = for_duration; };

    homeAssistantStart = {
      platform = "homeassistant";
      event = "start";
    };

    sun = { event, offset ? null }:
      {
        platform = "sun";
        inherit event;
      }
      // lib.optionalAttrs (offset != null) { inherit offset; };

    webhook = id: {
      platform = "webhook";
      webhook_id = id;
    };

    zone = { entity_id, zone, event }: {
      platform = "zone";
      inherit entity_id zone event;
    };

    numericState = { entity_id, above ? null, below ? null }:
      {
        platform = "numeric_state";
        inherit entity_id;
      }
      // lib.optionalAttrs (above != null) { inherit above; }
      // lib.optionalAttrs (below != null) { inherit below; };
  };

  conditions = {
    state = { entity_id, state }: {
      condition = "state";
      inherit entity_id state;
    };

    numericState = { entity_id, above ? null, below ? null }:
      {
        condition = "numeric_state";
        inherit entity_id;
      }
      // lib.optionalAttrs (above != null) { inherit above; }
      // lib.optionalAttrs (below != null) { inherit below; };

    time = { after ? null, before ? null, weekday ? null }:
      {
        condition = "time";
      }
      // lib.optionalAttrs (after != null) { inherit after; }
      // lib.optionalAttrs (before != null) { inherit before; }
      // lib.optionalAttrs (weekday != null) { inherit weekday; };

    sun = { after_offset ? null, before_offset ? null }:
      {
        condition = "sun";
      }
      // lib.optionalAttrs (after_offset != null) { inherit after_offset; }
      // lib.optionalAttrs (before_offset != null) { inherit before_offset; };

    zone = { entity_id, zone }: {
      condition = "zone";
      inherit entity_id zone;
    };

    template = value_template: {
      condition = "template";
      inherit value_template;
    };

    and = conditions_list: {
      condition = "and";
      conditions = conditions_list;
    };

    or = conditions_list: {
      condition = "or";
      conditions = conditions_list;
    };
  };

  actions = {
    service = { service, entity_id ? null, data ? {} }:
      {
        inherit service;
      }
      // lib.optionalAttrs (entity_id != null) { inherit entity_id; }
      // lib.optionalAttrs (data != {}) { inherit data; };

    notify = { service, message, title ? null, data ? {} }:
      {
        service = "notify.${service}";
        data =
          { inherit message; }
          // lib.optionalAttrs (title != null) { inherit title; }
          // data;
      };

    notifyAllMobile = { message, title ? null, data ? {} }:
      actions.notify {
        service = "all_mobile";
        inherit message title data;
      };

    lightTurn = { entity_id, state, brightness ? null, color_temp ? null }:
      {
        service = if state == "on" then "light.turn_on" else "light.turn_off";
        inherit entity_id;
      }
      // lib.optionalAttrs (brightness != null && state == "on") {
        data =
          { inherit brightness; }
          // lib.optionalAttrs (color_temp != null) { inherit color_temp; };
      };

    switchTurn = { entity_id, state }: {
      service = if state == "on" then "switch.turn_on" else "switch.turn_off";
      inherit entity_id;
    };

    delay = seconds: {
      delay = { inherit seconds; };
    };

    waitForTrigger = { trigger, timeout ? null }:
      {
        wait_for_trigger = trigger;
      }
      // lib.optionalAttrs (timeout != null) { inherit timeout; };

    sceneActivate = scene: {
      service = "scene.turn_on";
      entity_id = "scene.${scene}";
    };

    backup = {
      service = "backup.create";
    };
  };

  sequence = actions_list: actions_list;

  parallel = actions_list: {
    parallel = actions_list;
  };

  choose = { conditions_list, actions_list, default_actions ? [] }:
    {
      choose = lib.zipListsWith
        (cond: act: {
          conditions = cond;
          sequence = act;
        })
        conditions_list
        actions_list;
    }
    // lib.optionalAttrs (default_actions != []) { default = default_actions; };
}
