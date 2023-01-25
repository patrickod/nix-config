let
  prismo_patrickod =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnVbaP3o6F5ri9NMS+oAoZ6GlEq7h5XRAe9pgGJBnsg";
  users = [ prismo_patrickod ];

  prismo_host =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOySIKvmBCMcc2m2igWSALqppumHTDakZu2DTWFbYYB";
  hosts = [ prismo_host ];

in {
  "restic_backup_password.age".publicKeys = hosts ++ users;
  "github_oauth_token.age".publicKeys = hosts ++ users;
}
