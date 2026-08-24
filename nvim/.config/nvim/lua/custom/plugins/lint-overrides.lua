-- Add the per-filetype linters that kickstart's lint.lua only configures for
-- markdown. Loaded after kickstart.plugins.lint, so we add keys to the clean
-- table it already set, rather than re-enabling nvim-lint's broken defaults
-- (the `or {}` pattern warned about in lint.lua).
local lint = require 'lint'
lint.linters_by_ft['sh'] = { 'shellcheck' }
lint.linters_by_ft['sql'] = { 'sqlfluff' }
lint.linters_by_ft['python'] = { 'ruff' }
lint.linters_by_ft['terraform'] = { 'tflint' }
--
-- sqlfluff reads stdin, which has no path, so config resolution falls back to
-- nvim's cwd and misses the per-directory .sqlfluff files. Tell it the real path.
lint.linters.sqlfluff.args = {
  'lint',
  '--format=json',
  '--stdin-filename',
  function()
    local name = vim.api.nvim_buf_get_name(0)
    return name ~= '' and name or vim.fn.getcwd() .. '/stdin.sql'
  end,
  '-',
}
