{
  lib,
  entities,
  helpers,
}:
rec {
  mkAutomation =
    {
      id,
      alias,
      description ? null,
      trigger,
      condition ? [ ],
      action,
      mode ? "single",
    }:
    {
      inherit
        id
        alias
        trigger
        action
        ;
    }
    // lib.optionalAttrs (description != null) { inherit description; }
    // lib.optionalAttrs (condition != [ ]) { inherit condition; }
    // {
      inherit mode;
    };

  mkTimeAutomation =
    {
      id,
      alias,
      time,
      action,
      condition ? [ ],
      mode ? "single",
    }:
    mkAutomation {
      inherit
        id
        alias
        condition
        action
        mode
        ;
      trigger = helpers.triggers.time time;
    };

  mkStateAutomation =
    {
      id,
      alias,
      entity_id,
      to ? null,
      from ? null,
      for_duration ? null,
      action,
      condition ? [ ],
      mode ? "single",
    }:
    mkAutomation {
      inherit
        id
        alias
        condition
        action
        mode
        ;
      trigger = helpers.triggers.state {
        inherit
          entity_id
          to
          from
          for_duration
          ;
      };
    };

  mkZoneAutomation =
    {
      id,
      alias,
      person,
      zone,
      event,
      action,
      condition ? [ ],
      mode ? "single",
    }:
    mkAutomation {
      inherit
        id
        alias
        condition
        action
        mode
        ;
      trigger = helpers.triggers.zone {
        entity_id = entities.people.${person}.person;
        inherit zone event;
      };
    };

  mkSunAutomation =
    {
      id,
      alias,
      event,
      offset ? null,
      action,
      condition ? [ ],
      mode ? "single",
    }:
    mkAutomation {
      inherit
        id
        alias
        condition
        action
        mode
        ;
      trigger = helpers.triggers.sun { inherit event offset; };
    };

  mkMultiTriggerAutomation =
    {
      id,
      alias,
      triggers,
      action,
      condition ? [ ],
      mode ? "single",
      description ? null,
    }:
    mkAutomation {
      inherit
        id
        alias
        condition
        action
        mode
        ;
      trigger = triggers;
    }
    // lib.optionalAttrs (description != null) { inherit description; };

  mkScene =
    {
      name,
      id ? null,
      entities,
    }:
    {
      inherit name entities;
    }
    // lib.optionalAttrs (id != null) { inherit id; };

  mkNotifyGroup =
    {
      name,
      unique_id ? null,
      services,
    }:
    {
      inherit name;
      platform = "group";
      services = map (s: { service = s; }) services;
    }
    // lib.optionalAttrs (unique_id != null) { inherit unique_id; };

  mkBlueprintAutomation =
    {
      id,
      alias,
      blueprint_path,
      input ? { },
      description ? null,
    }:
    {
      inherit id alias;
      use_blueprint = {
        path = blueprint_path;
      }
      // lib.optionalAttrs (input != { }) { inherit input; };
    }
    // lib.optionalAttrs (description != null) { inherit description; };
}
