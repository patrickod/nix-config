let
  prismo_patrickod =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnVbaP3o6F5ri9NMS+oAoZ6GlEq7h5XRAe9pgGJBnsg";
  users = [ prismo_patrickod ];

  prismo_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3+/7F278cdAX/i0Cz8aUDXyF3mywk1gmgj3bFC0qD2";
  hosts = [ prismo_host ];

in
{
  "restic_backup_password.age".publicKeys = hosts ++ users;
  "github_oauth_token.age".publicKeys = hosts ++ users;
  "prismo_r2_access_key_id.age".publicKeys = hosts ++ users;
  "prismo_r2_secret_access_key.age".publicKeys = hosts ++ users;
  "prismo_restic_r2_environment.age".publicKeys = hosts ++ users;
}
