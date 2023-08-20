{ pkgs, ... }:
{
  config = ''
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

let g:mapleader=','
let g:maplocalleader = '\\'

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
let g:ale_linters = {'rust': ['analyzer'], 'ocaml': ['merlin']}
let g:ale_fixers = {
\   'ocaml':      ['ocamlformat'],
\   '*':          ['remove_trailing_lines', 'trim_whitespace'],
\}
let g:ale_linters_explicit            = 1
let g:ale_lint_on_text_changed        = 'never'
let g:ale_lint_on_enter               = 0
let g:ale_lint_on_save                = 1
let g:ale_fix_on_save                 = 1

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

lua << EOF
local wk = require("which-key")
wk.register(mappings, opts)

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
   vim.lsp.diagnostic.on_publish_diagnostics, {
      underline = false,
      update_in_insert = false,
      virtual_text = { spacing = 4, prefix = "●" },
      severity_sort = true,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
   vim.lsp.handlers.hover,
   {border = "rounded"}
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
   vim.lsp.handlers.signature_help,
   {border = "rounded"}
)

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
      highlight! link FloatBorder Normal
      highlight! link NormalFloat Normal
      ]])

vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true}
vim.api.nvim_set_option('updatetime', 300)

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

local sign = function(opts)
   vim.fn.sign_define(opts.name, {
			 texthl = opts.name,
			 text = opts.text,
			 numhl = '''
   })
end

sign({name = 'DiagnosticSignError', text = '⌽'})
sign({name = 'DiagnosticSignWarn', text = ''})
sign({name = 'DiagnosticSignHint', text = ''})
sign({name = 'DiagnosticSignInfo', text = '⍟'})

require("luasnip/loaders/from_vscode").lazy_load()

local cmp = require'cmp'
cmp.setup({
      snippet = {
	 expand = function(args)
	    require'luasnip'.lsp_expand(args.body)
	 end,
      },
      mapping = {
	 ['<C-p>'] = cmp.mapping.select_prev_item(),
	 ['<C-n>'] = cmp.mapping.select_next_item(),
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
	 { name = 'path' },
	 { name = 'nvim_lsp', keyword_length = 3 },
	 { name = 'nvim_lsp_signature_help'},
	 { name = 'nvim_lua', keyword_length = 2},
	 { name = 'buffer', keyword_length = 2 },
	 { name = 'luasnip', option = { use_show_condition = false } },
	 { name = 'calc'},
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
	       luasnip = '⋗',
	       buffer = 'Ω',
	       path = '⨓',
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

local lsp = require("lspconfig")
lsp.ltex.setup{
   on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, bufopts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "gf", vim.lsp.buf.formatting, bufopts)
      vim.keymap.set("n", "gdo", vim.diagnostic.open_float, bufopts)
      vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, bufopts)
      vim.keymap.set("n", "g]", vim.diagnostic.goto_next, bufopts)
   end,
   capabilities = require("cmp_nvim_lsp").default_capabilities(c)
}
lsp.pylsp.setup{
   on_attach = function(client, bufnr)
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, bufopts)
      vim.keymap.set("n", "<C-space>", vim.lsp.buf.hover, bufopts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "gf", vim.lsp.buf.formatting, bufopts)
      vim.keymap.set("n", "gdo", vim.diagnostic.open_float, bufopts)
      vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, bufopts)
      vim.keymap.set("n", "g]", vim.diagnostic.goto_next, bufopts)
   end,
   capabilities = require("cmp_nvim_lsp").default_capabilities(c)
}
lsp.ocamllsp.setup({
      cmd = { "ocamllsp" },
      filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
      root_dir = lsp.util.root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace"),
      on_attach = function(client, bufnr)
	 local bufopts = { noremap=true, silent=true, buffer=bufnr }
	 vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, bufopts)
	 vim.keymap.set("n", "<C-space>", vim.lsp.buf.hover, bufopts)
	 vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	 vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	 vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	 vim.keymap.set("n", "gf", vim.lsp.buf.formatting, bufopts)
	 vim.keymap.set("n", "gdo", vim.diagnostic.open_float, bufopts)
	 vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, bufopts)
	 vim.keymap.set("n", "g]", vim.diagnostic.goto_next, bufopts)

	 if client.server_capabilities.documentFormattingProvider then
	    vim.api.nvim_create_autocmd("BufWritePre", {
					   group = vim.api.nvim_create_augroup("Format", { clear = true }),
					   buffer = bufnr,
					   callback = function() vim.lsp.buf.formatting_seq_sync() end
	    })
	 end

	 if client.server_capabilities.code_lens then
	    local codelens = vim.api.nvim_create_augroup(
	       'LSPCodeLens',
	       { clear = true }
	    )
	    vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'CursorHold' }, {
		  group = codelens,
		  callback = function()
		     vim.lsp.codelens.refresh()
		  end,
		  buffer = bufnr,
	    })
	 end
      end,
      capabilities = require("cmp_nvim_lsp").default_capabilities(c)
})

local rt = require("rust-tools")
rt.setup({
   tools = {
	 debuggables = {
	    use_telescope = true
	 },
   },
   server = {
	 on_attach = function(client, bufnr)
	    local bufopts = { noremap=true, silent=true, buffer=bufnr }
	    vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, bufopts)
	    vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, bufopts)
	    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	    vim.keymap.set("n", "gf", vim.lsp.buf.formatting, bufopts)
	    vim.keymap.set("n", "gdo", vim.diagnostic.open_float, bufopts)
	    vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, bufopts)
	    vim.keymap.set("n", "g]", vim.diagnostic.goto_next, bufopts)

	    if client.server_capabilities.documentFormattingProvider then
	       vim.api.nvim_create_autocmd("BufWritePre", {
					      group = vim.api.nvim_create_augroup("Format", { clear = true }),
					      buffer = bufnr,
					      callback = function() vim.lsp.buf.formatting_seq_sync() end
	       })
	    end

	    if client.server_capabilities.code_lens then
	       local codelens = vim.api.nvim_create_augroup(
		  'LSPCodeLens',
		  { clear = true }
	       )
	       vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'CursorHold' }, {
		     group = codelens,
		     callback = function()
			vim.lsp.codelens.refresh()
		     end,
		     buffer = bufnr,
	       })
	    end
	 end,
	 settings = {
	    ["rust-analyzer"] = {
	       checkOnSave = {
	          command = "clippy"
	       },
	    },
	 }
   },
})

local dap = require('dap')
dap.adapters.lldb = {
  type = 'server',
  port = "13000",
  executable = {
    command = "${pkgs.lldb_13}/share/vscode/extensions/llvm-org.lldb-vscode-0.1.0",
    args = {"--port", "13000"},
  }
}

dap.configurations.rust = {
  {
     type = 'lldb',
     showDisassembly = "never",
     request = 'launch',
     program = function()
       return vim.fn.input('Path to executable: ', vim.fn.getcwd()..'/target/debug/', 'file')
     end,
     cwd = "''${workspaceFolder}",
     terminal = 'integrated',
     sourceLanguages = { 'rust' },
     stopOnEntry = true
   }
}

local dapui = require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set("n", "<leader>dk", function() dap.continue() end)
vim.keymap.set("n", "<leader>dl", function() dap.run_last() end)
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end)
EOF
'';
}
