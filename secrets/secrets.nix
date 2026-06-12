let
  ezemtsov = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjVq5J17bu+bJvdEaHoTYXjK+9zTOo0jqQVJte8ndun ezemtsov@ezemtsov";
  ezemtsovHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZJNVFMvMPl7T0NOuzodbQ9y7jOI31CGoIgGp/SNWwF root@nixos";
in
{
  "crowdstrike-cid.age".publicKeys = [
    ezemtsov
    ezemtsovHost
  ];
}
