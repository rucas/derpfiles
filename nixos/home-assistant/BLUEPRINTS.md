# Home Assistant Blueprints in Nix

This guide explains how to manage Home Assistant blueprints declaratively using Nix.

## Overview

Blueprints are reusable automation templates. The NixOS Home Assistant module provides built-in support for managing blueprints declaratively instead of importing them through the UI.

## Adding Blueprints

Edit `blueprints.nix` to add blueprints from GitHub, local files, or other sources:

```nix
{ pkgs, ... }:
{
  services.home-assistant.blueprints = {
    automation = [
      (pkgs.fetchurl {
        url = "https://github.com/home-assistant/core/raw/2025.1.4/homeassistant/components/automation/blueprints/motion_light.yaml";
        hash = "sha256-4HrDX65ycBMfEY2nZ7A25/d3ZnIHdpHZ+80Cblp+P5w=";
      })

      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/sbyx/HomeAssistant-Blueprints/main/low-battery-level-detection-notification-for-all-battery-sensors.yaml";
        hash = "sha256-...";
      })

      ./local-blueprint.yaml
    ];

    script = [
    ];

    template = [
      "${pkgs.home-assistant.src}/homeassistant/components/template/blueprints/inverted_binary_sensor.yaml"
    ];
  };
}
```

### Getting the Hash

Use `nix-prefetch-url` to get the hash:

```bash
nix-prefetch-url https://github.com/home-assistant/core/raw/2025.1.4/homeassistant/components/automation/blueprints/motion_light.yaml
```

Or use a fake hash and let Nix tell you the correct one:

```nix
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

Then rebuild and Nix will show the actual hash in the error.

## Using Blueprints in Automations

Once blueprints are added to `blueprints.nix`, use them in your automations:

```nix
{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "motion_light_bedroom";
      alias = "Motion Light - Bedroom";
      blueprint_path = "motion_light.yaml";
      input = {
        motion_entity = "binary_sensor.bedroom_motion";
        light_target.entity_id = entities.lights.bedroom.main;
        no_motion_wait = 120;
      };
    })
  ];
}
```

## Blueprint Path Format

The blueprint path is just the filename: `motion_light.yaml`

Blueprints are installed to:
- `<config_dir>/blueprints/automation/motion_light.yaml`
- `<config_dir>/blueprints/script/my_script.yaml`
- `<config_dir>/blueprints/template/my_template.yaml`

## Finding Blueprints

Popular sources:

1. **Home Assistant Official**:
   - URL: https://github.com/home-assistant/core/tree/dev/homeassistant/components/automation/blueprints
   - Use: Official blueprints maintained by Home Assistant

2. **Community Blueprints**:
   - Forum: https://community.home-assistant.io/c/blueprints-exchange
   - Browse community-created blueprints

3. **GitHub Repositories**:
   - Search: "home assistant blueprints"
   - Many users publish their blueprints on GitHub

## Complete Example

### 1. Add Blueprint to `blueprints.nix`

```nix
{ pkgs, ... }:
{
  services.home-assistant.blueprints.automation = [
    (pkgs.fetchurl {
      url = "https://github.com/home-assistant/core/raw/2025.1.4/homeassistant/components/automation/blueprints/motion_light.yaml";
      hash = "sha256-4HrDX65ycBMfEY2nZ7A25/d3ZnIHdpHZ+80Cblp+P5w=";
    })
  ];
}
```

### 2. Create Automation File `automations/motion_lights.nix`

```nix
{ lib, ... }:
let
  haLib = import ../lib { inherit lib; };
  inherit (haLib) entities mkBlueprintAutomation;
in
{
  services.home-assistant.config."automation manual" = [
    (mkBlueprintAutomation {
      id = "bedroom_motion_light";
      alias = "Bedroom Motion Light";
      blueprint_path = "motion_light.yaml";
      input = {
        motion_entity = "binary_sensor.bedroom_motion";
        light_target.entity_id = entities.lights.bedroom.main;
        no_motion_wait = 300;
      };
    })

    (mkBlueprintAutomation {
      id = "hallway_motion_light";
      alias = "Hallway Motion Light";
      blueprint_path = "motion_light.yaml";
      input = {
        motion_entity = "binary_sensor.hallway_motion";
        light_target.entity_id = "light.hallway";
        no_motion_wait = 120;
      };
    })
  ];
}
```

### 3. Import in `automations/default.nix`

```nix
{
  imports = [
    ./nightly_backup.nix
    ./motion_lights.nix
  ];
}
```

## Benefits

- **Declarative**: All blueprints defined in Nix configuration
- **Version Control**: Pin specific blueprint versions with hashes
- **Reproducible**: Same blueprints across all rebuilds
- **No Manual UI Import**: Blueprints automatically installed
- **Git Tracking**: Track changes to blueprints over time

## Blueprint Input Parameters

To find what input parameters a blueprint accepts:

1. **Download and inspect the YAML**:
   ```bash
   curl -o blueprint.yaml <blueprint-url>
   cat blueprint.yaml | grep -A 50 "input:"
   ```

2. **Check documentation**: Most blueprints on GitHub have a README

3. **Home Assistant UI**: After adding the blueprint, you can see available inputs in the UI

## Common Blueprint Examples

### Motion-Activated Light

```nix
services.home-assistant.blueprints.automation = [
  (pkgs.fetchurl {
    url = "https://github.com/home-assistant/core/raw/2025.1.4/homeassistant/components/automation/blueprints/motion_light.yaml";
    hash = "sha256-4HrDX65ycBMfEY2nZ7A25/d3ZnIHdpHZ+80Cblp+P5w=";
  })
];
```

### Low Battery Notifications

```nix
services.home-assistant.blueprints.automation = [
  (pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/sbyx/HomeAssistant-Blueprints/main/low-battery-level-detection-notification-for-all-battery-sensors.yaml";
    hash = "sha256-...";
  })
];
```

### Local Blueprint File

```nix
services.home-assistant.blueprints.automation = [
  ./blueprints/custom_automation.yaml
];
```

## Troubleshooting

### Blueprint Not Found

If Home Assistant can't find your blueprint:

1. Check the file exists: `ls /etc/home-assistant/blueprints/automation/`
2. Verify the blueprint_path matches the filename
3. Restart Home Assistant after adding new blueprints
4. Check Home Assistant logs for errors

### Invalid Blueprint

If the blueprint fails to load:

1. Validate the YAML syntax
2. Check blueprint schema compliance
3. Ensure all required blueprint keys are present
4. Review Home Assistant logs for specific errors
