# Pipeline
- Setup a git repo with your nix configuration
- Setup the machine to deploy to with NixOS
- Use ssh-keyscan to get public ssh key of the machine you set up
- Add that key to your git repo's secrets.nix file
- Encrypt or rekey your secrets to use the new SSH key
- Add the age module to your machine's nix configuration
- Redeploy nix configuration.
