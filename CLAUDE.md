# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration repository that supports both Python and iOS (Swift) development with full LSP integration, formatters, and linters.

## Architecture

### Single-File Configuration
The entire configuration is in `init.lua` with the following structure:
1. Basic Vim settings (lines 1-25)
2. lazy.nvim bootstrap (lines 27-39)
3. Plugin declarations (lines 42-146)
4. LSP configuration (lines 148-235)
5. Plugin-specific configurations (lines 237-333)
6. Key mappings (lines 335-377)

### LSP Setup Pattern
This config uses the new Neovim 0.11+ `vim.lsp.config.*` pattern instead of lspconfig's `require('lspconfig').*.setup()`. Each LSP is configured with:
- `cmd`: Server command
- `filetypes`: Supported file types
- `root_markers`: Project root detection
- `capabilities`: nvim-cmp capabilities
- Auto-enabled via `FileType` autocmds (lines 206-218)

### Key LSP Servers
- **Python**: Pyright (type checking) + Ruff (linting)
- **Swift**: SourceKit-LSP for iOS/macOS development
- **Swift/Xcode**: xcodebuild.nvim integration for Xcode project support

## Development Commands

### Testing Configuration Changes
```bash
nvim --headless "+Lazy! sync" +qa  # Install/update plugins without opening
nvim test.py                        # Test Python LSP
nvim test.swift                     # Test Swift LSP
```

### Debugging LSP
```vim
:LspInfo                           # Check LSP status
:Lazy                              # Manage plugins
:Mason                             # Manage LSP servers
:checkhealth                       # Full health check
```

### Key Mappings Reference
- LSP: `gd` (definition), `K` (hover), `<leader>rn` (rename), `<leader>ca` (code action), `gr` (references), `<leader>f` (format)
- Xcode: `<leader>xb` (build), `<leader>xr` (run), `<leader>xs` (scheme picker), `<leader>xd` (device), `<leader>xc` (coverage)
- File navigation: `<leader>e` (tree), `<leader>ff` (find files), `<leader>fg` (grep)

## Important Implementation Details

### Python Environment Detection
Pyright automatically detects virtual environments and project roots via `root_markers`. No manual configuration needed for `.venv`, `venv`, or `pyproject.toml` projects.

### iOS/Xcode Integration
- **xcode-build-server**: Must be installed via `brew install xcode-build-server`
- **xcodebuild.nvim**: Provides `:XcodebuildPicker` to configure workspace/scheme
- **SourceKit**: Requires 2-second delay (line 199) for Xcode project indexing

### Format on Save
Conform.nvim runs formatters on save:
- Python: black + isort
- Swift: swiftformat
- Fallback to LSP formatting if formatter unavailable

## Plugin Dependencies

Critical plugin relationships:
- **nvim-cmp** requires: cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip
- **xcodebuild.nvim** requires: telescope.nvim, nui.nvim
- **LSP** requires: mason.nvim, mason-lspconfig.nvim, fidget.nvim

## Setup for New Users

1. Open nvim - lazy.nvim auto-installs on first run
2. Wait for plugin installation to complete
3. For Python: `pip install black isort ruff`
4. For iOS: `brew install xcode-build-server swiftformat`
5. Restart nvim to activate LSP servers

## File Organization

- `init.lua` - Single configuration file
- `README.md` - Screenshots only
- `PYTHON_SETUP.md` - Python development guide
- `IOS_SETUP.md` - iOS development guide
