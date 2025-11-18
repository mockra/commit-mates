local M = {}

-- Store co-authors for the current session
M.coauthors = {}

-- Fetch GitHub user info
local function fetch_github_user(handle)
  local gh_cmd = string.format('gh api /users/%s', handle)
  local result = vim.fn.system(gh_cmd)

  if vim.v.shell_error ~= 0 then
    return nil, "Failed to fetch user data"
  end

  local ok, user_data = pcall(vim.fn.json_decode, result)
  if not ok then
    return nil, "Failed to parse JSON response"
  end

  if user_data.message then
    return nil, user_data.message
  end

  return user_data, nil
end

-- Add a co-author by GitHub handle
local function add_single_coauthor(handle)
  -- Remove @ if present
  handle = handle:gsub("^@", "")

  vim.notify("Fetching GitHub user: " .. handle, vim.log.levels.INFO)

  local user_data, err = fetch_github_user(handle)

  if err then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return false
  end

  if not user_data.name then
    vim.notify("Error: User missing name", vim.log.levels.ERROR)
    return false
  end

  -- GitHub users may not have a public email, use noreply email
  local email = user_data.email
  if not email or email == vim.NIL or email == vim.null then
    -- Use ID-based noreply format (works for all accounts)
    email = string.format("%s+%s@users.noreply.github.com", user_data.id, handle)
  end

  -- Create co-author string
  local coauthor = {
    handle = handle,
    name = user_data.name,
    email = email,
    line = string.format("Co-authored-by: %s <%s>", user_data.name, email)
  }

  -- Add to list if not already present
  for _, existing in ipairs(M.coauthors) do
    if existing.handle == handle then
      vim.notify("Co-author already added: " .. coauthor.line, vim.log.levels.WARN)
      return false
    end
  end

  table.insert(M.coauthors, coauthor)
  vim.notify("Added co-author: " .. coauthor.line, vim.log.levels.INFO)
  return true
end

-- Add co-author(s) by GitHub handle(s) - supports comma-separated list
function M.add_coauthor(handles)
  -- Split by comma and trim whitespace
  local handle_list = {}
  for handle in handles:gmatch("[^,]+") do
    local trimmed = handle:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      table.insert(handle_list, trimmed)
    end
  end

  if #handle_list == 0 then
    vim.notify("No valid handles provided", vim.log.levels.WARN)
    return
  end

  -- Process each handle
  for _, handle in ipairs(handle_list) do
    add_single_coauthor(handle)
  end
end

-- Insert co-authors into current buffer (for commit message)
function M.insert_coauthors()
  if #M.coauthors == 0 then
    vim.notify("No co-authors to insert", vim.log.levels.WARN)
    return
  end

  local lines = {}

  -- Add all co-author lines
  for _, coauthor in ipairs(M.coauthors) do
    table.insert(lines, coauthor.line)
  end

  -- Insert at line below cursor
  local current_line = vim.fn.line('.')
  vim.fn.append(current_line, lines)

  vim.notify(string.format("Inserted %d co-author(s)", #M.coauthors), vim.log.levels.INFO)

  -- Clear the list after inserting
  M.coauthors = {}
end

-- Open floating window to add co-author
function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = 50
  local height = 1

  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Enter GitHub Handle(s) ',
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Start insert mode
  vim.cmd('startinsert')

  -- Set up keymaps
  vim.keymap.set('i', '<CR>', function()
    local handle = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    handle = handle:gsub('^[%%%s]*(.-)%s*$', '%1')  -- trim prompt % and whitespace
    
    vim.api.nvim_win_close(win, true)
    
    if handle ~= "" then
      M.add_coauthor(handle)
      vim.defer_fn(function()
        M.insert_coauthors()
      end, 100)
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set('i', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })
end

return M
