{ lib }:
rec {
  people = {
    lucas = {
      mobile = "mobile_app_lucas_iphone";
      person = "person.lucas";
    };
    kelsey = {
      mobile = "mobile_app_kelsey_s_iphone";
      person = "person.kelsey";
    };
  };

  mediaPlayers = {
    living_room = {
      sonos_move = "media_player.sonos_move";
    };
  };

  lights = {
    living_room = {
      main = "light.living_room_main";
      accent = "light.living_room_accent";
    };
    bedroom = {
      main = "light.bedroom_main";
    };
  };

  switches = {
    bedroom = {
      fan = "switch.bedroom_fan";
    };
  };

  sensors = {
    temperature = {
      living_room = "sensor.living_room_temperature";
    };
  };

  alarm = {
    main = "alarm_control_panel.alarmo";
  };

  doorbell = {
    chime = "select.doorbell_chime";
  };

  allMobileDevices = lib.attrValues (lib.mapAttrs (name: person: person.mobile) people);

  roomLights = room: lib.attrValues lights.${room} or [ ];

  allLights = lib.flatten (lib.mapAttrsToList (_: room: lib.attrValues room) lights);
}
