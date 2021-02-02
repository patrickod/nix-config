{
  networking.wireguard.interfaces = {
    strangeparts = {
      ips = [ "10.0.20.2/32" ];
      listenPort = 51820;
      privateKeyFile = "/private/strangeparts-wg";
      peers = [{
        publicKey = "qj15EcNyNbVWO2F1HyeldwyAkp3J7Nfy/FGpDoFJ1RA=";
        endpoint = "marionette.strangeparts.com:51820";
        allowedIPs = [ "10.0.20.1" ];
      }];
    };
  };
}
