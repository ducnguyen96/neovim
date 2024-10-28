{
  imports = [
    # settings
    ./keymaps.nix
    ./opts.nix

    ./plugins/colorscheme/catppuccin.nix
    ./plugins/coding
    ./plugins/editor
    ./plugins/formatting
    ./plugins/linting
    ./plugins/lsp
    ./plugins/treesitter
    ./plugins/ui
    ./plugins/util
  ];

  config = {
    globals.mapleader = " ";
  };
}
