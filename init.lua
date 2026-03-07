vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- keep selection after indenting in visual modes
vim.keymap.set('x', '>', '>gv', { desc = 'Indent and keep selection' })
vim.keymap.set('x', '<', '<gv', { desc = 'Outdent and keep selection' })

-- optional tab style
vim.keymap.set('x', '<Tab>', '>gv', { desc = 'Indent and keep selection' })
vim.keymap.set('x', '<S-Tab>', '<gv', { desc = 'Outdent and keep selection' })

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Show diagnostic in float' })
vim.keymap.set('n', '<leader>td', function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config { virtual_text = not current }
end, { desc = '[T]oggle [D]iagnostics virtual text' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Delete current buffer
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })

-- Switch to previous buffer
vim.keymap.set('n', '<leader>`', '<C-^>', { desc = 'Switch to previous buffer' })

-- Git blame line
vim.keymap.set('n', '<leader>gb', function()
  require('snacks').picker.git_log_line()
end, { desc = '[G]it [B]lame line' })

vim.keymap.set('n', '<leader>gf', function()
  require('snacks').picker.git_log_file()
end, { desc = '[G]it [F]ile History' })

vim.keymap.set({ 'n', 'x' }, '<leader>gB', function()
  require('snacks').gitbrowse()
end, { desc = '[G]it [B]rowse (open)' })

vim.keymap.set('n', '<leader>gl', function()
  require('snacks').lazygit()
end, { desc = '[G]it [L]azygit' })

-- [[ Ginkgo Test Keybindings ]]
local last_test_cmd = nil
local last_test_cwd = nil

-- Find ginkgo binary
local function get_ginkgo_cmd()
  -- Try common locations
  local ginkgo_paths = {
    vim.fn.expand '$HOME/go/bin/ginkgo',
    vim.fn.expand '$GOPATH/bin/ginkgo',
    'ginkgo', -- fallback to PATH
  }

  for _, path in ipairs(ginkgo_paths) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  return 'ginkgo' -- fallback
end

-- Shared test terminal instance
local test_terminal = nil

vim.keymap.set('n', '<leader>ta', function()
  local ginkgo = get_ginkgo_cmd()
  last_test_cmd = ginkgo
  last_test_cwd = vim.fn.expand '%:p:h'
  if test_terminal then
    test_terminal:close()
  end
  test_terminal = require('snacks').terminal(last_test_cmd, {
    cwd = last_test_cwd,
    win = { position = 'bottom' },
    interactive = false,
  })
end, { desc = '[T]est [A]ll (ginkgo)' })

vim.keymap.set('n', '<leader>tf', function()
  local ginkgo = get_ginkgo_cmd()
  local file = vim.fn.expand '%:t'
  last_test_cmd = ginkgo .. ' --focus-file=' .. file
  last_test_cwd = vim.fn.expand '%:p:h'
  if test_terminal then
    test_terminal:close()
  end
  test_terminal = require('snacks').terminal(last_test_cmd, {
    cwd = last_test_cwd,
    win = { position = 'bottom' },
    interactive = false,
  })
end, { desc = '[T]est [F]ile (ginkgo)' })

vim.keymap.set('n', '<leader>tr', function()
  if last_test_cmd then
    if test_terminal then
      test_terminal:close()
    end
    test_terminal = require('snacks').terminal(last_test_cmd, {
      cwd = last_test_cwd or vim.fn.getcwd(),
      win = { position = 'bottom' },
      interactive = false,
    })
  else
    vim.notify('No previous test command', vim.log.levels.WARN)
  end
end, { desc = '[T]est [R]e-run last' })

vim.keymap.set('n', '<leader>tt', function()
  if test_terminal then
    test_terminal:toggle()
  else
    vim.notify('No test terminal to toggle. Run a test first.', vim.log.levels.WARN)
  end
end, { desc = '[T]est [T]oggle window' })

-- [[ Snacks Picker Keybindings ]]
local picker = function()
  return require('snacks').picker
end

-- File and search pickers
vim.keymap.set('n', '<leader>ff', function()
  picker().files()
end, { desc = '[ ] Find Files' })

vim.keymap.set('n', '<leader>sh', function()
  picker().help()
end, { desc = '[S]earch [H]elp' })

vim.keymap.set('n', '<leader>sk', function()
  picker().keymaps()
end, { desc = '[S]earch [K]eymaps' })

vim.keymap.set('n', '<leader>ss', function()
  picker().pickers()
end, { desc = '[S]earch [S]elect Picker' })

vim.keymap.set('n', '<leader>sw', function()
  picker().grep_word()
end, { desc = '[S]earch current [W]ord' })

vim.keymap.set('n', '<leader>sd', function()
  picker().diagnostics {
    layout = {
      preset = 'ivy',
      preview = false,
    },
  }
end, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set('n', '<leader>sr', function()
  picker().resume()
end, { desc = '[S]earch [R]esume' })

vim.keymap.set('n', '<leader>s.', function()
  picker().recent()
end, { desc = '[S]earch Recent Files ("." for repeat)' })

vim.keymap.set('n', '<leader>sc', function()
  picker().colorschemes()
end, { desc = '[S]earch [C]olorschemes' })

-- JetBrains-style buffer switcher with Tab cycling
vim.keymap.set('n', '<leader><Tab>', function()
  picker().buffers { current = false }
end, { desc = 'Switch buffers' })

vim.keymap.set('n', '<leader>sg', function()
  picker().grep()
end, { desc = '[S]earch by [G]rep' })

vim.keymap.set('x', '<leader>sg', function()
  picker().grep_word()
end, { desc = '[S]earch by [G]rep' })

vim.keymap.set('n', '<leader>/', function()
  picker().lines()
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  picker().grep { open_files_only = true }
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>sn', function()
  picker().files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

vim.keymap.set('n', '<leader>e', function()
  require('snacks').picker.explorer {
    layout = { preset = 'ivy', preview = true },
    auto_close = true,
    matcher = { fuzzy = false },
  }
end, { desc = '[E]xplorer' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.o.foldenable = true
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false -- keep real tabs, recommended for Go
  end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  pattern = { '*' },
  command = 'silent! wall',
  nested = true,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt', { desc = 'Go to tab ' .. i })
end
vim.keymap.set('n', '<leader>0', '0gt', { desc = 'Go to last tab' })

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup({
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      -- this will download prebuild binary or try to use existing rustup toolchain to build from source
      -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
      require("fff.download").download_or_build_binary()
    end,
    -- if you are using nixos
    -- build = "nix run .#release",
    opts = { -- (optional)
      debug = {
        enabled = true,     -- we expect your collaboration at least during the beta
        show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
      },
    },
    -- No need to lazy-load with lazy.nvim.
    -- This plugin initializes itself lazily.
    lazy = false,
    keys = {
        {
          "ff", -- try it if you didn't it is a banger keybinding for a picker
          function() require('fff').find_files() end,
          desc = 'FFFind files',
        },
        {
          "fg",
          function() require('fff').live_grep() end,
          desc = 'LiFFFe grep',
        },
        {
          "fz",
          function() require('fff').live_grep({
            grep = {
              modes = { 'fuzzy', 'plain' }
            }
          }) end,
          desc = 'Live fffuzy grep',
        }
      },
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {},
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = {
        enabled = true,
        layout = {
          preset = 'ivy',
        },
        win = {
          input = {
            keys = {
              ['<Tab>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<S-Tab>'] = { 'select_and_next', mode = { 'i', 'n' } },
              ['<C-d>'] = { 'edit_vsplit', mode = { 'i', 'n' } },
            },
          },
        },
        sources = {
          buffers = {
            sort_mru = true,
          },
        },
      },
      terminal = {
        enabled = true,
        win = {
          position = 'bottom',
          height = 0.3,
        },
      },
      lazygit = {
        enabled = true,
        win = {
          position = 'float',
          width = 0.9,
          height = 0.9,
        },
      },
      styles = {
        terminal = {
          keys = {
            q = 'hide',
          },
        },
      },
    },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      require('catppuccin').setup {
        flavour = 'latte', -- other options: latte, mocha, frappe, macchiato
        integrations = { neotree = true },
        custom_highlights = function(C)
          return {
            NeoTreeCursorLine = { bg = C.surface0 }, -- pick a darker shade (try C.mantle/surface0/surface1)
            CursorLine = { bg = C.surface0 },
            CursorColumn = { bg = C.surface0 },
          }
        end,
      }
    end,
  },
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      preset = 'helix',
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]est/Toggle' },
        { '<leader>r', group = 'Su[r]round' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>d', group = '[D]ebug' },
      },
    },
  },
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    opts = {
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('gn', vim.lsp.buf.rename, 'Re[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('gr', function()
            require('snacks').picker.lsp_references()
          end, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', function()
            require('snacks').picker.lsp_implementations()
          end, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', function()
            require('snacks').picker.lsp_definitions()
          end, '[G]oto [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', function()
            require('snacks').picker.lsp_symbols()
          end, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', function()
            require('snacks').picker.lsp_workspace_symbols()
          end, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('gy', function()
            require('snacks').picker.lsp_type_definitions()
          end, '[G]oto [T]ype Definition')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- LSP server configurations
      -- These servers are expected to be installed via Nix (e.g., gopls, lua-language-server, stylua)
      --
      -- Using vim.lsp.config (Neovim 0.11+) instead of deprecated lspconfig
      -- See :help lspconfig-nvim-0.11 for more information

      -- Configure gopls
      vim.lsp.config.gopls = {
        capabilities = capabilities,
        settings = {
          gopls = {
            completeUnimported = true,
            importShortcut = 'Both',
            analyses = {
              undeclaredname = true,
            },
          },
        },
      }

      -- Configure lua_ls
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      }

      -- Enable the configured LSP servers
      vim.lsp.enable { 'gopls', 'lua_ls' }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[C]ode [F]ormat',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'gopls' },
        rust = { 'rustfmt' },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<C-,>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<Tab>'] = {},
        ['<S-Tab>'] = {},
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        menu = {
          draw = {
            components = {
              label_description = {
                width = { max = 80 },
                text = function(ctx)
                  return ctx.label_description ~= '' and ctx.label_description or ctx.item.detail
                end,
              },
            },
            columns = {
              { 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
              { 'source_name' },
            },
          },
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

  {
    'folke/tokyonight.nvim',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }
    end,
  },

  {
    'morhetz/gruvbox',
    priority = 1000,
    config = function()
      vim.g.gruvbox_contrast_dark = 'hard'
      vim.g.gruvbox_contrast_light = 'hard'
      vim.o.background = 'dark'

      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- Flash.nvim for enhanced navigation and selection
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },

  -- GitHub Copilot
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = false,
        },
        panel = { enabled = false },
        filetypes = {
          ['*'] = true,
        },
      }
    end,
  },
  {
    'giuxtaposition/blink-cmp-copilot',
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - <leader>raiw) - Surround [A]dd [I]nner [W]ord [)]Paren
      -- - <leader>rd'   - Surround [D]elete [']quotes
      -- - <leader>rr)'  - Surround [R]eplace [)] [']
      require('mini.surround').setup {
        mappings = {
          add = '<leader>ra', -- Add surrounding in Normal and Visual modes
          delete = '<leader>rd', -- Delete surrounding
          find = '<leader>rf', -- Find surrounding (to the right)
          find_left = '<leader>rF', -- Find surrounding (to the left)
          highlight = '<leader>rh', -- Highlight surrounding
          replace = '<leader>rr', -- Replace surrounding
          update_n_lines = '<leader>rn', -- Update `n_lines`
        },
      }

      -- Auto pairs - automatically insert closing brackets, quotes, etc.
      -- When you press <CR> between {} it will expand with proper indentation
      require('mini.pairs').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  -- Smear cursor for smooth cursor trails
  {
    'sphamba/smear-cursor.nvim',
    opts = {
      -- Smear cursor when switching buffers or windows
      smear_between_buffers = true,
      -- Smear cursor when moving in insert mode
      smear_between_neighbor_lines = true,
      -- Set to `true` if you want to use transparent background
      legacy_computing_symbols_support = false,
    },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      folds = { enable = true },
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'go', 'rust', 'toml' },
      -- Autoinstall languages that are not installed
      auto_install = false,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- Rust support (lazy-loaded only for Rust files)
  -- Must be loaded before nvim-lspconfig to prevent duplicate rust-analyzer
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    ft = { 'rust' },
    init = function()
      -- Prevent lspconfig from setting up rust_analyzer
      -- rustaceanvim will handle it automatically
      vim.g.rustaceanvim = {
        server = {
          standalone = true, -- Tell rustaceanvim to use standalone mode
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
              },
              procMacro = {
                enable = true,
              },
              check = {
                command = 'clippy',
              },
              rustc = {
                source = 'discover',
              },
            },
          },
          on_attach = function(_, bufnr)
            -- Rust-specific keymaps
            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, { buffer = bufnr, desc = '[C]ode [A]ction' })
            vim.keymap.set('n', '<leader>dr', function()
              vim.cmd.RustLsp 'debuggables'
            end, { buffer = bufnr, desc = '[D]ebug [R]unnables' })
          end,
        },
      }
    end,
  },

  -- Rust crate management (lazy-loaded only for Cargo.toml)
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    config = function()
      require('crates').setup {
        completion = {
          cmp = {
            enabled = false,
          },
        },
      }
    end,
  },

  -- Debug Adapter Protocol
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug [B]reakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = '[D]ebug conditional [B]reakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug [C]ontinue' },
      { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug step [I]nto' },
      { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug step [O]ver' },
      { '<leader>dO', function() require('dap').step_out() end, desc = '[D]ebug step [O]ut' },
      { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug [U]I toggle' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },

  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true

      vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
        require('opencode').ask('@this: ', { submit = true })
      end, { desc = '[O]pencode [A]sk' })

      vim.keymap.set({ 'n', 'x' }, '<leader>os', function()
        require('opencode').select()
      end, { desc = '[O]pencode [S]elect action' })

      vim.keymap.set({ 'n', 'x' }, '<leader>or', function()
        return require('opencode').operator '@this '
      end, { desc = '[O]pencode add [R]ange', expr = true })
    end,
  },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
