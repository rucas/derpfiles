{ ... }: {
  services.home-assistant.config = {
    "scene manual" = [
      {
        name = "TV";
        entities = { };
      }
      {
        name = "Arrive";
        entities = { };
      }
      {
        name = "Leave";
        entities = { };
      }
    ];
  };
}
