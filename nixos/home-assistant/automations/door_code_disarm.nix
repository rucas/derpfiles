{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib)
    entities
    triggers
    conditions
    actions
    mkAutomation
    ;

  # The Lock Code Manager config entry title, which is also the windmill
  # door_code_sync job's `lcm_entry`. Renaming the entry in the Home Assistant
  # UI silently stops both.
  lcmEntry = "Door Codes";

  # Lock Code Manager announces who used a credential, never the credential, so
  # the PIN has to be read back out of that user's slot to hand Alarmo the code
  # it attributes the disarm to. Slot numbers are not stable — a slot is
  # whichever one was free when the sync adopted the lldap user — so the name
  # entity is matched first and its `code_slot` carries over to the PIN.
  resolvePin = ''
    {%- set slots = states.text
         | selectattr('attributes.slot_field', 'defined')
         | selectattr('attributes.code_slot', 'defined') | list -%}
    {%- set slot = slots
         | selectattr('attributes.slot_field', 'eq', 'name')
         | selectattr('state', 'eq', trigger.event.data.name)
         | map(attribute='attributes.code_slot') | first | default(-1) -%}
    {%- set pin = slots
         | selectattr('attributes.slot_field', 'eq', 'pin')
         | selectattr('attributes.code_slot', 'eq', slot)
         | map(attribute='state') | first | default("") -%}
  '';
in
{
  services.home-assistant.config."automation manual" = [
    (mkAutomation {
      id = "door_code_disarm";
      alias = "Door Code Disarms The Alarm";
      description = "Disarm Alarmo when someone unlocks the door with their own keypad code. The code comes from whichever Lock Code Manager slot lldap put them in, so adding, removing or rotating a door code in lldap needs no change here.";

      # Lock Code Manager's own bus event rather than `zwave_js_notification`:
      # it names the user instead of a slot number, so one trigger covers every
      # code, and it survives the lock being re-paired or moved to another
      # provider. `operation` is the direction the lock reported — locking up
      # behind yourself with a code must not disarm the house.
      trigger = triggers.event {
        event_type = "lock_code_manager_credential_used";
        event_data = {
          config_entry_title = lcmEntry;
          credential_type = "pin";
          operation = "unlock";
        };
      };

      condition = [
        {
          condition = "not";
          conditions = [
            (conditions.state {
              entity_id = entities.alarm.main;
              state = "disarmed";
            })
          ];
        }

        # A slot whose name entity is disabled or still restoring reads back no
        # PIN. Disarming with an empty code spends an Alarmo failed-attempt
        # against the lockout counter, so stop instead.
        (conditions.template "${resolvePin}{{ pin | length >= 4 }}")
      ];

      action = [
        (actions.service {
          service = "alarm_control_panel.alarm_disarm";
          entity_id = entities.alarm.main;
          data.code = "${resolvePin}{{ pin }}";
        })
      ];

      # Two people through the door in quick succession are two uses to
      # attribute, not one to drop; the second re-tests the conditions and
      # stops on the already-disarmed guard.
      mode = "queued";
    })
  ];
}
