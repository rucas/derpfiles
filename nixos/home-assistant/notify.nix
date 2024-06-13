{ ... }: {
  services.home-assistant.config = {
    notify = [{
      name = "all_mobile";
      unique_id = "all_mobile";
      platform = "group";
      services = [
        { service = "mobile_app_lucas_iphone"; }
        { service = "mobile_app_kelsey_iphone"; }
      ];
    }];
  };
}
