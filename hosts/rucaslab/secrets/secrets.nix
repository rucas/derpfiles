let
  user =
    "ssh-ed25519 AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKCLdEAArRtMhdvIdXKbBE19qhS3R2pL4Ws79d0U3czlAAAAEHNzaDpydWNhc2xhYi5jb20=";
  system =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVJRnte7uoSXii9cPSpsvLqSwyzFu0hu5Rn3Mfm7W5d root@rucaslab";
in { "tailscale.age".publicKeys = [ user system ]; }
