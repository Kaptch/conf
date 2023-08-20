{ pkgs, ... }:
let
  Coqtail-coq-lsp = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "Coqtail";
    version = "47846d5e59c6b810bd3126543a430e09362bb5e7";
    src = pkgs.fetchFromGitHub {
      owner = "whonore";
      repo = "Coqtail";
      rev = "47846d5e59c6b810bd3126543a430e09362bb5e7";
      sha256 = "sha256-6Lj2mKyWgeFfd6NgGkOnBl+oMwzhbOkSVyadK3kH6AM=";
    };
  };
  coq-lsp = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "coq-lsp";
    version = "b387455d3f2801b0cf59dd10ddd891318a1a0126";
    src = pkgs.fetchFromGitHub {
      owner = "tomtomjhj";
      repo = "coq-lsp.nvim";
      rev = "b387455d3f2801b0cf59dd10ddd891318a1a0126";
      sha256 = "sha256-y28nOR7WSThcPi1X//JQRQuAhpMXe3VeBswx6dUW7+g=";
    };
  };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      ale

      vim-lsp
      nvim-lspconfig
      nvim-lsputils

      friendly-snippets
      Coqtail

      rust-tools-nvim

      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          rust
          ocaml
          toml
        ]
      ))

      vim-nix

      vimtex

      direnv-vim

      nerdtree

      telescope-dap-nvim
      nvim-dap
      plenary-nvim
      nvim-dap-ui

      cmp-buffer
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lua
      cmp-path
      luasnip
      cmp_luasnip
      nvim-cmp

      vim-airline
      vim-airline-themes
      nord-nvim

      which-key-nvim

      vim-bufferline

      vim-commentary

      vim-fugitive

      vim-gitgutter

      undotree
    ];
    extraConfig = (import ./vim-conf.nix { pkgs = pkgs; }).config;
  };
}
