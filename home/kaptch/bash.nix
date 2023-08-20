{
  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR = "emacsclient -c";
      COQPATH = "/home/kaptch/.nix-profile/lib/coq/8.16/user-contrib";
      SSH_AUTH_SOCK = "/run/user/$UID/gnupg/S.gpg-agent.ssh";
      LEDGER_FILE = "/home/kaptch/Finances/journal.ledger.gpg";
    };
    shellAliases = {
      ssh = "gpg-connect-agent updatestartuptty /bye > /dev/null; ssh";
      scp = "gpg-connect-agent updatestartuptty /bye > /dev/null; scp";
      eledger = "gpg --batch -d -q $LEDGER_FILE | ledger -f -";
    };
    bashrcExtra = "gpg-connect-agent updatestartuptty /bye > /dev/null\n";
  };
}
