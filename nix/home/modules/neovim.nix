{ pkgs, ... }:

let
  tsParsers = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.lua
    p.vim
    p.vimdoc
    p.bash
    p.go
    p.rust
    p.zig
    p.json
    p.yaml
    p.markdown
    p.nix
    p.sql
    p.rego
    p.dart
    p.javascript
    p.typescript
    p.tsx
    p.css
    p.html
    p.python
  ]);
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      which-key-nvim
      lualine-nvim
      nvim-web-devicons
      catppuccin-nvim
      gitsigns-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      friendly-snippets
      cmp_luasnip
      lazygit-nvim
      fzf-lua
      neo-tree-nvim
      nui-nvim
      tsParsers
      # Additional useful plugins for LazyVim-like experience
      vim-repeat
      vim-surround
      vim-commentary
      nvim-autopairs
      nvim-ts-autotag
      vim-illuminate
    ];

    extraLuaConfig = ''
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      -- Disable netrw in favour of neo-tree
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Basic options
      local opt = vim.opt
      opt.termguicolors = true
      opt.number = true
      opt.relativenumber = true
      opt.cursorline = true
      opt.signcolumn = "yes"
      opt.wrap = false
      opt.scrolloff = 5
      opt.splitright = true
      opt.splitbelow = true
      opt.mouse = "a"
      opt.clipboard = "unnamedplus"
      opt.tabstop = 2
      opt.shiftwidth = 2
      opt.expandtab = true
      opt.smartindent = true
      opt.hlsearch = true
      opt.incsearch = true
      opt.ignorecase = true
      opt.smartcase = true

      -- Colorscheme
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            base = "#000000",
            mantle = "#010101",
            crust = "#020202",
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")

      -- Status line
      require("lualine").setup({
        options = { theme = "catppuccin" },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })

      -- Git signs
      require("gitsigns").setup()

      -- Autopairs
      require("nvim-autopairs").setup({})

      -- Autotag
      require("nvim-ts-autotag").setup({})

      -- Illuminate (highlight word under cursor)
      require("illuminate").configure({
        providers = { 'lsp', 'treesitter', 'regex' },
        delay = 100,
        filetypes_denylist = { 'dirbuf', 'dirvish', 'fugitive' },
      })

      -- Neo-tree (replaces netrw)
      require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = true,
        default_component_configs = {
          indent = { with_markers = true },
          icon = { folder_closed = "▸", folder_open = "▾" },
          git_status = { symbols = { added = "✚", modified = "", deleted = "", renamed = "", untracked = "", ignored = "◌", unstaged = "", staged = "✓" } },
        },
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          group_empty_dirs = true,
          window = {
            position = "left",
            width = 35,
            mappings = {
              ["<C-v>"] = "open_vsplit",
              ["<C-s>"] = "open_split",
            },
          },
          commands = {},
        },
        window = {
          mappings = {
            ["h"] = "parent_or_close",
            ["l"] = "open",
            ["o"] = "open",
            ["<bs>"] = "parent_or_close",
            ["."] = "set_root",
            ["R"] = "refresh",
            ["/"] = "fuzzy_finder",
            ["P"] = { "toggle_preview", config = { use_float = true } },
          },
        },
      })

      -- Which-key
      require("which-key").setup({
        plugins = { presets = { operators = false } },
        win = { border = "rounded" },
      })

      -- Telescope with fzf-lua-like bindings
      require("telescope").setup{
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { width = 0.95, height = 0.85 },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-n>"] = "cycle_history_next",
              ["<C-p>"] = "cycle_history_prev",
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = {"rg", "--files", "--hidden", "--glob", "!**/.git/*"},
          },
          live_grep = {
            additional_args = {"--hidden"},
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      }
      pcall(require("telescope").load_extension, "fzf")

      -- LazyGit
      local function lazygit()
        vim.cmd("LazyGit")
      end

      -- Key mappings with more familiar bindings (similar to Zed/VSCode)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end

      -- File operations
      map("n", "<leader>e", function()
        if vim.bo.filetype == "neo-tree" then
          vim.cmd("Neotree close")
        else
          vim.cmd("Neotree focus")
        end
      end, "Toggle file explorer")
      map("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, "Find files")
      map("n", "<leader>fg", function() require("telescope.builtin").live_grep({ additional_args = {"--hidden"} }) end, "Live grep")
      map("n", "<leader>fb", require("telescope.builtin").buffers, "Buffers")
      map("n", "<leader>fh", require("telescope.builtin").help_tags, "Help")
      map("n", "<leader>fr", require("telescope.builtin").oldfiles, "Recent files")
      map("n", "<leader>fs", require("telescope.builtin").grep_string, "Find string")
      map("n", "<leader>fc", require("telescope.builtin").commands, "Commands")
      map("n", "<leader>fk", require("telescope.builtin").keymaps, "Keymaps")

      -- Git
      map("n", "<leader>gg", lazygit, "LazyGit")
      map("n", "<leader>gs", require("telescope.builtin").git_status, "Git status")
      map("n", "<leader>gc", require("telescope.builtin").git_commits, "Git commits")
      map("n", "<leader>gb", require("telescope.builtin").git_branches, "Git branches")

      -- Buffer management
      map("n", "<leader>bd", "<cmd>bdelete<cr>", "Delete buffer")
      map("n", "<leader>bD", "<cmd>bdelete!<cr>", "Force delete buffer")
      map("n", "<leader>bb", "<cmd>e #<cr>", "Switch to other buffer")
      map("n", "<leader>ba", "<cmd>%bd|e#|bd#<cr>", "Close all buffers but current")

      -- Window navigation (more intuitive)
      map("n", "<C-h>", "<C-w>h", "Move to left window")
      map("n", "<C-j>", "<C-w>j", "Move to down window")
      map("n", "<C-k>", "<C-w>k", "Move to up window")
      map("n", "<C-l>", "<C-w>l", "Move to right window")
      map("n", "<leader>wv", "<cmd>vsplit<cr>", "Split window vertically")
      map("n", "<leader>ws", "<cmd>split<cr>", "Split window horizontally")
      map("n", "<leader>wd", "<cmd>close<cr>", "Delete window")
      map("n", "<leader>ww", "<C-w>p", "Switch to previous window")
      map("n", "<leader>w=", "<C-w>=", "Make windows equal size")

      -- Tab management
      map("n", "<leader>tn", "<cmd>tabnew<cr>", "New tab")
      map("n", "<leader>tx", "<cmd>tabclose<cr>", "Close tab")
      map("n", "<leader>tm", "<cmd>tabmove<cr>", "Move tab")
      map("n", "<leader>t<leader>", "<cmd>tabnext<cr>", "Next tab")

      -- Increment/decrement
      map("n", "+", "<C-a>", "Increment number")
      map("n", "-", "<C-x>", "Decrement number")

      -- Delete single character without copying
      map("n", "x", '"_x', "Delete character without yank")

      -- Visual mode selections
      map("v", "<", "<gv", "Indent left")
      map("v", ">", ">gv", "Indent right")

      -- Stay in indent mode
      map("v", "<", "<gv", "")
      map("v", ">", ">gv", "")

      -- Move lines up/down
      map("n", "<A-j>", ":m .+1<cr>==", "Move line down")
      map("n", "<A-k>", ":m .-2<cr>==", "Move line up")
      map("i", "<A-j>", "<esc>:m .+1<cr>==gi", "Move line down")
      map("i", "<A-k>", "<esc>:m .-2<cr>==gi", "Move line up")
      map("v", "<A-j>", ":m '>+1<cr>gv=gv", "Move selection down")
      map("v", "<A-k>", ":m '<-2<cr>gv=gv", "Move selection up")

      -- Terminal escape
      map("t", "<Esc>", [[<C-\><C-n>]], "Exit terminal mode")

      -- LSP setup
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })

      -- LSP configurations
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      vim.lsp.config("*", { capabilities = capabilities })

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        ts_ls = {},
        gopls = {},
        rust_analyzer = {},
        zls = {},
        sqls = {},
        dockerls = {},
        dartls = {},
        pyright = {},
        nil_ls = {},
        nixd = {},
        html = {},
        cssls = {},
        jsonls = {},
        marksman = {},
        bashls = {},
        yamlls = {},
      }

      for server, opts in pairs(servers) do
        if opts and next(opts) ~= nil then
          vim.lsp.config(server, opts)
        end
        local ok, _ = pcall(vim.lsp.enable, server)
        if not ok then
          vim.notify("LSP " .. server .. " not available", vim.log.levels.INFO)
        end
      end

      -- LSP keymaps
      map("n", "gd", vim.lsp.buf.definition, "Goto definition")
      map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "gi", vim.lsp.buf.implementation, "Implementation")
      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
      map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
      map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
      map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, "List workspace folders")
      map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")

      -- Diagnostics
      vim.diagnostic.config({
        float = { border = "rounded" },
        virtual_text = {
          source = "always",
        },
        severity_sort = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })
      map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
      map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
      map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
      map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostic list")

      -- Codeium setup (free AI copilot alternative)
      if vim.fn.exists('*codeium#GetStatus') == 1 then
        vim.g.codeium_disable_bindings = 1
        map("i", "<C-g>", function() return vim.fn['codeium#Accept']() end, "Accept codeium suggestion")
        map("i", "<c-]>", function() return vim.fn['codeium#CycleCompletions'](1) end, "Next codeium suggestion")
        map("i", "<c-[>", function() return vim.fn['codeium#CycleCompletions'](-1) end, "Previous codeium suggestion")
        map("i", "<c-x>", function() return vim.fn['codeium#Clear']() end, "Clear codeium suggestion")
        map("i", "<c-\\>", function() return vim.fn['codeium#Complete']() end, "Trigger codeium completion")
      end
    '';
  };
}
