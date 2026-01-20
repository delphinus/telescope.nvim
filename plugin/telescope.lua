if 1 ~= vim.fn.has "nvim-0.10.4" then
  error "Telescope.nvim requires at least nvim-0.10.4."
  return
end

if vim.g.loaded_telescope == 1 then
  return
end
vim.g.loaded_telescope = 1

local highlights = {
  -- Sets the highlight for selected items within the picker.
  TelescopeSelection = { default = true, link = "Visual" },
  TelescopeSelectionCaret = { default = true, link = "TelescopeSelection" },
  TelescopeMultiSelection = { default = true, link = "Type" },
  TelescopeMultiIcon = { default = true, link = "Identifier" },

  -- "Normal" in the floating windows created by telescope.
  TelescopeNormal = { default = true, link = "Normal" },
  TelescopePreviewNormal = { default = true, link = "TelescopeNormal" },
  TelescopePromptNormal = { default = true, link = "TelescopeNormal" },
  TelescopeResultsNormal = { default = true, link = "TelescopeNormal" },

  -- Border highlight groups.
  --   Use TelescopeBorder to override the default.
  --   Otherwise set them specifically
  TelescopeBorder = { default = true, link = "TelescopeNormal" },
  TelescopePromptBorder = { default = true, link = "TelescopeBorder" },
  TelescopeResultsBorder = { default = true, link = "TelescopeBorder" },
  TelescopePreviewBorder = { default = true, link = "TelescopeBorder" },

  -- Title highlight groups.
  --   Use TelescopeTitle to override the default.
  --   Otherwise set them specifically
  TelescopeTitle = { default = true, link = "TelescopeBorder" },
  TelescopePromptTitle = { default = true, link = "TelescopeTitle" },
  TelescopeResultsTitle = { default = true, link = "TelescopeTitle" },
  TelescopePreviewTitle = { default = true, link = "TelescopeTitle" },

  TelescopePromptCounter = { default = true, link = "NonText" },

  -- Used for highlighting characters that you match.
  TelescopeMatching = { default = true, link = "Special" },

  -- Used for the prompt prefix
  TelescopePromptPrefix = { default = true, link = "Identifier" },

  -- Used for highlighting the matched line inside Previewer. Works only for (vim_buffer_ previewer)
  TelescopePreviewLine = { default = true, link = "Visual" },
  TelescopePreviewMatch = { default = true, link = "Search" },

  TelescopePreviewPipe = { default = true, link = "Constant" },
  TelescopePreviewCharDev = { default = true, link = "Constant" },
  TelescopePreviewDirectory = { default = true, link = "Directory" },
  TelescopePreviewBlock = { default = true, link = "Constant" },
  TelescopePreviewLink = { default = true, link = "Special" },
  TelescopePreviewSocket = { default = true, link = "Statement" },
  TelescopePreviewRead = { default = true, link = "Constant" },
  TelescopePreviewWrite = { default = true, link = "Statement" },
  TelescopePreviewExecute = { default = true, link = "String" },
  TelescopePreviewHyphen = { default = true, link = "NonText" },
  TelescopePreviewSticky = { default = true, link = "Keyword" },
  TelescopePreviewSize = { default = true, link = "String" },
  TelescopePreviewUser = { default = true, link = "Constant" },
  TelescopePreviewGroup = { default = true, link = "Constant" },
  TelescopePreviewDate = { default = true, link = "Directory" },
  TelescopePreviewMessage = { default = true, link = "TelescopePreviewNormal" },
  TelescopePreviewMessageFillchar = { default = true, link = "TelescopePreviewMessage" },

  -- Used for Picker specific Results highlighting
  TelescopeResultsClass = { default = true, link = "Function" },
  TelescopeResultsConstant = { default = true, link = "Constant" },
  TelescopeResultsField = { default = true, link = "Function" },
  TelescopeResultsFunction = { default = true, link = "Function" },
  TelescopeResultsMethod = { default = true, link = "Method" },
  TelescopeResultsOperator = { default = true, link = "Operator" },
  TelescopeResultsStruct = { default = true, link = "Struct" },
  TelescopeResultsVariable = { default = true, link = "SpecialChar" },

  TelescopeResultsLineNr = { default = true, link = "LineNr" },
  TelescopeResultsIdentifier = { default = true, link = "Identifier" },
  TelescopeResultsNumber = { default = true, link = "Number" },
  TelescopeResultsComment = { default = true, link = "Comment" },
  TelescopeResultsSpecialComment = { default = true, link = "SpecialComment" },

  -- Used for git status Results highlighting
  TelescopeResultsDiffChange = { default = true, link = "DiffChange" },
  TelescopeResultsDiffAdd = { default = true, link = "DiffAdd" },
  TelescopeResultsDiffDelete = { default = true, link = "DiffDelete" },
  TelescopeResultsDiffUntracked = { default = true, link = "NonText" },
}

for k, v in pairs(highlights) do
  vim.api.nvim_set_hl(0, k, v)
end

-- This is like "<C-R>" in your terminal.
--     To use it, do `cmap <C-R> <Plug>(TelescopeFuzzyCommandSearch)
vim.keymap.set(
  "c",
  "<Plug>(TelescopeFuzzyCommandSearch)",
  "<C-\\>e \"lua require('telescope.builtin').command_history "
    .. '{ default_text = [=[" . escape(getcmdline(), \'"\') . "]=] }"<CR><CR>',
  { silent = true, noremap = true }
)

vim.api.nvim_create_user_command("Telescope", function(opts)
  require("telescope.command").load_command(unpack(opts.fargs))
end, {
  nargs = "*",
  complete = function(_, line)
    local builtin_list = vim.tbl_keys(require "telescope.builtin")
    local extensions_list = vim.tbl_keys(require("telescope._extensions").manager)

    local l = vim.split(line, "%s+")
    local n = #l - 2

    if n == 0 then
      local commands = { builtin_list, extensions_list }
      commands = vim.iter(commands):flatten():totable()
      table.sort(commands)

      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[2])
      end, commands)
    end

    if n == 1 then
      local is_extension = vim.tbl_filter(function(val)
        return val == l[2]
      end, extensions_list)

      if #is_extension > 0 then
        local extensions_subcommand_dict = require("telescope.command").get_extensions_subcommand()
        local commands = extensions_subcommand_dict[l[2]]
        table.sort(commands)

        return vim.tbl_filter(function(val)
          return vim.startswith(val, l[3])
        end, commands)
      end
    end

    -- オプション補完
    local last_arg = l[#l]

    -- `key=value`形式の場合、値の部分でパス補完
    if last_arg:find("=") then
      local eq_pos = last_arg:find("=")
      local key = last_arg:sub(1, eq_pos - 1)
      local value = last_arg:sub(eq_pos + 1)

      -- パスを受け取るオプションのリスト
      local path_options = {
        ctags_file = true,
        cwd = true,
        gitdir = true,
        root_dir = true,
        search_dirs = true,
        search_file = true,
        symbol_path = true,
        toplevel = true,
      }

      if path_options[key] then
        local path_completions = vim.fn.getcompletion(value, "file")
        return vim.tbl_map(function(path)
          return key .. "=" .. path
        end, path_completions)
      end

      -- パス以外のオプションの場合、空リストを返す
      return {}
    end

    -- オプションキーの補完
    -- telescope.config.valuesのグローバルオプション + picker固有オプション
    local global_options = vim.tbl_keys(require("telescope.config").values)

    -- pickers.lua と全builtin pickerから抽出した全オプション
    local picker_options = {
      "__hide_previewer", "__inverted", "__locations_input", "__matches",
      "_cache_picker", "_completion_callbacks", "_multi",
      "additional_args", "attach_mappings",
      "border", "borderchars", "bufnr", "bufnr_width",
      "cache_index", "cache_picker", "colors", "column_len",
      "create_layout", "ctags_file", "curr_filepath", "current_file",
      "current_line", "current_previewer_index", "cwd", "cwd_only",
      "cycle_layout_list",
      "debounce", "default_selection_index", "default_text",
      "enable_preview", "entry_maker", "entry_prefix", "env", "expand_dir",
      "fallback", "file_encoding", "file_ignore_patterns", "filter", "filter_fn",
      "find_command", "finder", "fix_preview_title", "follow", "from",
      "get_selection_window", "get_status_text", "get_window_options",
      "git_command", "gitdir", "glob_pattern", "grep_open_files",
      "hidden",
      "id", "ignore_builtins", "ignore_current_buffer", "ignore_filename",
      "include_current_line", "include_current_session", "include_declaration",
      "include_extensions", "initial_mode", "is_bare",
      "jump_type",
      "lang", "layout_config", "layout_strategy", "lhs_filter",
      "line_highlights", "line_width",
      "make_entry", "man_cmd", "manager", "mark_type", "max_results",
      "modes", "multi", "multi_icon",
      "namespace", "new_prefix", "no_ignore", "no_ignore_parent",
      "no_unlisted", "nr",
      "on_complete", "on_input_filter_cb", "only_buf", "only_cwd",
      "operator", "operator_callback",
      "path_display", "pattern", "prefix_hl_group", "preview",
      "preview_title", "previewer", "prompt", "prompt_prefix", "prompt_title",
      "push_cursor_on_edit", "push_tagstack_on_edit",
      "query",
      "recurse_submodules", "reset_prompt", "results", "results_title",
      "results_ts_highlight", "resumed_picker", "reuse_win", "root_dir",
      "scroll_strategy", "search", "search_dirs", "search_file", "sections",
      "select_current", "selection_caret", "selection_strategy",
      "severity", "severity_bound", "severity_limit",
      "show_all_buffers", "show_branch", "show_buf_command", "show_line",
      "show_moon", "show_plug", "show_pluto", "show_remote_tracking_branches",
      "show_untracked",
      "sort_buffers", "sort_by", "sort_lastused", "sort_mru",
      "sorter", "sorting_strategy", "sources", "symbol_path",
      "temp__scrolling_limit", "tiebreak", "to", "toplevel", "track",
      "type_filter",
      "use_default_opts", "use_file_path", "use_git_root", "use_regex",
      "vimgrep_arguments",
      "width_lhs", "winblend", "window", "winnr", "word_match", "wrap_results",
    }

    -- 両方をマージして重複を削除
    local all_options = vim.list_extend(vim.deepcopy(global_options), picker_options)
    all_options = vim.fn.uniq(vim.fn.sort(all_options))

    return vim.tbl_filter(function(val)
      return vim.startswith(val, last_arg)
    end, all_options)
  end,
})
