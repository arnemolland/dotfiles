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
      cheatsheet-nvim
      lualine-nvim
      nvim-web-devicons
      catppuccin-nvim
      gitsigns-nvim
      comment-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      friendly-snippets
      cmp_luasnip
      tsParsers
    ];

    extraLuaConfig = ''
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

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

      require("lualine").setup({ options = { theme = "catppuccin" } })
      require("gitsigns").setup()
      require("Comment").setup()

      require("which-key").setup({
        plugins = { presets = { operators = false } },
        window = { border = "rounded" },
      })

      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = { width = 0.9, height = 0.9 },
          mappings = { i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" } },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      pcall(require("telescope").load_extension, "fzf")

      require("cheatsheet").setup({
        bundled_cheatsheets = true,
        bundled_plugin_cheatsheets = true,
        include_only_installed_plugins = true,
      })

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end

      -- Telescope
      map("n", "<leader>ff", require("telescope.builtin").find_files, "Find files")
      map("n", "<leader>fg", require("telescope.builtin").live_grep, "Live grep")
      map("n", "<leader>fb", require("telescope.builtin").buffers, "Buffers")
      map("n", "<leader>fh", require("telescope.builtin").help_tags, "Help")

      -- Cheatsheet
      map("n", "<leader>?", require("cheatsheet").show_cheatsheet, "Cheatsheet")

      -- Better window navigation
      map("n", "<C-h>", "<C-w>h", "Window left")
      map("n", "<C-j>", "<C-w>j", "Window down")
      map("n", "<C-k>", "<C-w>k", "Window up")
      map("n", "<C-l>", "<C-w>l", "Window right")

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
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

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

      map("n", "gd", vim.lsp.buf.definition, "Goto definition")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")

      vim.diagnostic.config({
        float = { border = "rounded" },
        virtual_text = false,
        severity_sort = true,
      })
      map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
      map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
      map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    '';
  };
}
