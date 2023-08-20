{ pkgs, lib, config, ... }:
{
  age.secrets.mosquitto = {
    file = ../secrets/mosquitto.age;
    owner = "mosquitto";
    group = "mosquitto";
    path = "/run/secrects/mosquitto";
    mode = "600";
  };

  services.mosquitto = {
    enable = true;

    listeners = [{
      port = 1883;
      address = "0.0.0.0";
      settings.allow_anonymous = true;
      omitPasswordAuth = false;
      acl = [ "topic readwrite #" ];

      users.kaptch = {
        acl = [
          "readwrite #"
        ];
        passwordFile = config.age.secrets.mosquitto.path;
      };
    }];
  };
}
