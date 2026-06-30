-- Add the per-filetype linters that kickstart's lint.lua only configures for
-- markdown. Loaded after kickstart.plugins.lint, so we add keys to the clean
-- table it already set, rather than re-enabling nvim-lint's broken defaults
-- (the `or {}` pattern warned about in lint.lua).
local lint = require 'lint'
lint.linters_by_ft['sh'] = { 'shellcheck' }
lint.linters_by_ft['sql'] = { 'sqlfluff' }
lint.linters_by_ft['python'] = { 'ruff' }
lint.linters_by_ft['terraform'] = { 'tflint' }
