-- 기본 설정
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 옵션
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.cursorline = true

-- lazy.nvim 부트스트랩
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- 플러그인 설정
require("lazy").setup({
    -- 컬러 스킴
    {
        "rebelot/kanagawa.nvim",
        name = "kanagawa",
        priority = 1000,
        config = function()
            -- Kanagawa 설정
            require('kanagawa').setup({
                compile = false,
                undercurl = true,
                commentStyle = { italic = true },
                functionStyle = {},
                keywordStyle = { italic = true},
                statementStyle = { bold = true },
                typeStyle = {},
                transparent = true,
                dimInactive = true,
                terminalColors = true,
                theme = "wave", -- "wave", "dragon", "lotus"
            })
            vim.cmd.colorscheme("kanagawa")
        end,
    },

    -- Treesitter (구문 강조)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "lua", "vim", "vimdoc", "swift" },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- LSP 설정
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
        },
    },

    -- 자동완성
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
    },

    -- Formatter & Linter
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
    },

    -- 파일 탐색기
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- 퍼지 파인더
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make"
            }
        },
    },

    -- 상태바
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- Git 통합
    { "lewis6991/gitsigns.nvim" },

    -- 주석
    { "numToStr/Comment.nvim" },

    -- 자동 페어
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },

    -- 인덴트 가이드
    { "lukas-reineke/indent-blankline.nvim", main = "ibl" },

    -- xcode-build-server (iOS/Xcode 프로젝트 지원)
    {
        "wojciech-kulik/xcodebuild.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("xcodebuild").setup({
                -- xcode-build-server 자동 실행
                code_coverage = {
                    enabled = true,
                },
            })
        end,
    },
})

-- Mason 설정 (LSP 서버 관리)
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "ruff" },
    automatic_installation = true,
})

-- LSP 설정
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Pyright (Python LSP)
vim.lsp.config.pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json" },
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
            },
        },
    },
}

-- Ruff (Python Linter)
vim.lsp.config.ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "ruff.toml" },
    capabilities = capabilities,
}

-- SourceKit (Swift LSP)
vim.lsp.config.sourcekit = {
    cmd = { "sourcekit-lsp" },
    filetypes = { "swift", "objc", "objcpp" },
    root_markers = { "Package.swift", ".git", "*.xcodeproj", "*.xcworkspace" },
    capabilities = capabilities,
    settings = {
        sourcekit = {
            -- Xcode 프로젝트 지원 강화
            indexing = {
                enabled = true,
            },
        },
    },
    on_attach = function(client, bufnr)
        -- iOS 프로젝트의 경우 인덱싱이 완료될 때까지 대기
        vim.defer_fn(function()
            vim.notify("SourceKit LSP ready for " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
        end, 2000)
    end,
}

-- LSP 자동 시작
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.lsp.enable({ "pyright", "ruff" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "swift", "objc", "objcpp" },
    callback = function()
        vim.lsp.enable("sourcekit")
    end,
})

-- LSP 키 매핑
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
    end,
})

-- nvim-cmp 자동완성 설정
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    },
})

-- Conform (Formatter) 설정
require("conform").setup({
    formatters_by_ft = {
        python = { "black", "isort" },
        swift = { "swiftformat", "swiftlint" },
    },
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
    formatters = {
        swiftlint = {
            command = "swiftlint",
            args = { "lint", "--fix", "--quiet", "$FILENAME" },
            stdin = false,
        },
    },
})

-- nvim-tree 설정
require("nvim-tree").setup({
    view = {
        width = 30,
    },
    update_focused_file = {
        enable = true,      -- 파일 변경 시 자동으로 트리에서 해당 파일 위치로 이동
        update_cwd = false, -- 작업 디렉토리는 변경하지 않음
    },
})

-- Telescope 설정
local telescope = require("telescope")
telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
            },
        },
    },
})

-- fzf 확장 로드
pcall(require("telescope").load_extension, "fzf")

-- Lualine 설정
require("lualine").setup({
    options = {
        theme = "kanagawa",
        component_separators = "|",
        section_separators = "",
    },
})

-- Gitsigns 설정
require("gitsigns").setup()

-- Comment 설정
require("Comment").setup()

-- Autopairs 설정
require("nvim-autopairs").setup()

-- Indent-blankline 설정
require("ibl").setup()

-- Fidget 설정 (LSP 진행 상태)
require("fidget").setup()

-- 키 매핑
local keymap = vim.keymap.set

-- 파일 탐색기
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>ef", ":NvimTreeFindFile<CR>", { desc = "Find current file in explorer" })
keymap("n", "<leader>ec", ":NvimTreeCollapse<CR>", { desc = "Collapse all folders in explorer" })

-- Telescope
keymap("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
keymap("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
keymap("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
keymap("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })

-- 버퍼 네비게이션
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Diagnostics
pcall(vim.keymap.del, "n", "<leader>d")
keymap("n", "<leader>d", function()
    vim.diagnostic.open_float(nil, { focus = false, border = "rounded", scope = "line" })
end, { desc = "Show diagnostic message" })

-- 윈도우 네비게이션
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- 윈도우 크기 조절
keymap("n", "<A-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<A-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<A-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<A-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- 비주얼 모드에서 인덴트 유지
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- 터미널
keymap("n", "<leader>t", ":split | terminal<CR>", { desc = "Open terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Xcode 프로젝트 명령어
keymap("n", "<leader>xb", ":XcodebuildBuild<CR>", { desc = "Xcode Build" })
keymap("n", "<leader>xr", ":XcodebuildRun<CR>", { desc = "Xcode Run" })
keymap("n", "<leader>xs", ":XcodebuildPicker<CR>", { desc = "Xcode Picker" })
keymap("n", "<leader>xd", ":XcodebuildSelectDevice<CR>", { desc = "Xcode Select Device" })
keymap("n", "<leader>xc", ":XcodebuildToggleCodeCoverage<CR>", { desc = "Xcode Toggle Coverage" })

-- Swift 파일 저장 시 자동 인덱스 업데이트 (비활성화)
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*.swift",
--   callback = function()
--     -- buildServer.json이 있는 경우에만 실행 (Xcode 프로젝트)
--     if vim.fn.filereadable("buildServer.json") == 1 then
--       -- 비동기로 빌드 실행 (UI 블로킹 방지)
--       vim.defer_fn(function()
--         vim.cmd("silent! XcodebuildBuild")
--       end, 100)
--     end
--   end,
--   desc = "Auto-update Xcode index on Swift file save"
-- })
