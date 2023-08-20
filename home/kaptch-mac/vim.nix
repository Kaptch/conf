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

      coq-lsp
      Coqtail

      rust-tools-nvim

      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          ocaml
          rust
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
      cmp-vsnip
      nvim-cmp
      vim-vsnip

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
    extraConfig = ''
      set number
      set cursorline
      set expandtab
      set tabstop=4
      set hlsearch
      set foldlevel=99
      set nocompatible
      filetype on
      filetype plugin on
      filetype indent on
      syntax on
      set splitright
      set splitbelow
      set termguicolors
      set clipboard+=unnamedplus

      let g:mapleader=';'
      let g:maplocalleader = ','
      inoremap ;; <Esc>

      colorscheme nord
      let g:airline_theme='violet'

      nnoremap <silent> <Space> :NERDTreeToggle<CR>
      nnoremap <C-T> :terminal<CR>
      nnoremap <C-U> :UndotreeToggle<CR>
      nnoremap <M-;> :Commentary<CR>
      nnoremap <C-J> <C-W><C-J>
      nnoremap <C-K> <C-W><C-K>
      nnoremap <C-L> <C-W><C-L>
      nnoremap <C-H> <C-W><C-H>
      nnoremap <C-Q> :bdel<CR>
      nnoremap <Space>o :only<CR>

      let g:LanguageClient_serverCommands = {
      \ 'rust': ['rust-analyzer'],
      \ 'ocaml': ['ocamllsp'],
      \ }
      let g:ale_linters = {'rust': ['analyzer'], 'ocaml': ['ocamllsp']}

      let g:vimtex_quickfix_open_on_warning = 0
      let g:vimtex_compiler_latexmk = {
        \ 'executable' : 'latexmk',
        \ 'options' : [
        \   '-xelatex',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}
      let g:vimtex_view_method = 'zathura'

      let g:loaded_coqtail = 1
      let g:coqtail#supported = 0

      lua << EOF
        local wk = require("which-key")
        wk.register(mappings, opts)

        local coqlsp = require("coq-lsp")
        coqlsp.setup({
          coq_lsp_nvim = {
          },
          lsp = {
            on_attach = function(client, bufnr)
              vim.keymap.set("n", "<Leader>v", coqlsp.panels, { buffer = bufnr })
              vim.keymap.set("n", "<Leader>s", coqlsp.stop, { buffer = bufnr })
            end,
            init_options = {
              show_notices_as_diagnostics = true,
            },
          },
        })

        local status, lsp = pcall(require, "lspconfig")
        if (not status) then return end

        local c = vim.lsp.protocol.make_client_capabilities()
        c.textDocument.completion.completionItem.snippetSupport = true
        c.textDocument.completion.completionItem.resolveSupport = {
            properties = {
                'documentation',
                'detail',
                'additionalTextEdits',
            },
        }

        local border = {
          {"🭽", "FloatBorder"},
          {"▔", "FloatBorder"},
          {"🭾", "FloatBorder"},
          {"▕", "FloatBorder"},
          {"🭿", "FloatBorder"},
          {"▁", "FloatBorder"},
          {"🭼", "FloatBorder"},
          {"▏", "FloatBorder"},
        }
        lsp.ocamllsp.setup({
          cmd = { "ocamllsp" },
          filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
          root_dir = lsp.util.root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace"),
          on_attach = function(client, bufnr)
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
            vim.keymap.set("n", "<C-Space>", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
            vim.keymap.set("n", "fm", vim.lsp.buf.formatting, bufopts)
          end,

          capabilities = require("cmp_nvim_lsp").default_capabilities(c),
          handlers = {
            ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border}),
            ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border }),
          }
        })

        local rt = require("rust-tools")
        rt.setup({
          tools = {
            debuggables = {
              use_telescope = true
            },
          },
          server = {
            on_attach = function(_, bufnr)
              vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
              vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
              vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
            end,
          },
        })


      local sign = function(opts)
        vim.fn.sign_define(opts.name, {
          texthl = opts.name,
          text = opts.text,
          numhl = '''
        })
      end

      sign({name = 'DiagnosticSignError', text = ''})
      sign({name = 'DiagnosticSignWarn', text = ''})
      sign({name = 'DiagnosticSignHint', text = ''})
      sign({name = 'DiagnosticSignInfo', text = ''})

      vim.diagnostic.config({
          virtual_text = false,
          signs = true,
          update_in_insert = true,
          underline = true,
          severity_sort = false,
          float = {
              border = 'rounded',
              source = 'always',
              header = ''',
              prefix = ''',
          },
      })

      vim.cmd([[
      set signcolumn=yes
      autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
      ]])

      vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, keymap_opts)
      vim.keymap.set("n", "g]", vim.diagnostic.goto_next, keymap_opts)

      -- menuone: popup even when there's only one match
      -- noinsert: Do not insert text until a selection is made
      -- noselect: Do not select, force to select one from the menu
      -- shortness: avoid showing extra messages when using completion
      -- updatetime: set updatetime for CursorHold
      vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
      vim.opt.shortmess = vim.opt.shortmess + { c = true}
      vim.api.nvim_set_option('updatetime', 300)

      vim.cmd([[
      set signcolumn=yes
      autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
      ]])

      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
              vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = {
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Add tab support
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          })
        },
        sources = {
          { name = 'path' },                              -- file paths
          { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
          { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
          { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
          { name = 'buffer', keyword_length = 2 },        -- source current buffer
          { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip
          { name = 'calc'},                               -- source for math calculation
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        formatting = {
            fields = {'menu', 'abbr', 'kind'},
            format = function(entry, item)
                local menu_icon ={
                    nvim_lsp = 'λ',
                    vsnip = '⋗',
                    buffer = 'Ω',
                    path = '🖫',
                }
                item.menu = menu_icon[entry.source.name]
                return item
            end,
        },
      })

      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting=false,
        },
        ident = { enable = true },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        }
      }

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

      local format_sync_grp = vim.api.nvim_create_augroup("Format", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.rs",
        callback = function()
          vim.lsp.buf.format({ timeout_ms = 200 })
        end,
        group = format_sync_grp,
      })
      EOF
    '';
  };
}
