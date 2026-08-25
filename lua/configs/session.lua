local M = {}

local function collect_open_tree_dirs(node, dirs)
  if not node or type(node) ~= "table" then
    return
  end

  if node.type == "directory" and node.open and node.absolute_path then
    table.insert(dirs, node.absolute_path)
  end

  for _, child in ipairs(node.nodes or {}) do
    collect_open_tree_dirs(child, dirs)
  end
end

local function restore_tree_dirs(dirs)
  local ok_api, api = pcall(require, "nvim-tree.api")
  local ok_core, core = pcall(require, "nvim-tree.core")
  if not ok_api or not ok_core then
    return
  end

  api.tree.open()

  vim.schedule(function()
    local explorer = core.get_explorer()
    if not explorer then
      return
    end

    table.sort(dirs, function(a, b)
      return #a < #b
    end)

    for _, dir in ipairs(dirs) do
      if vim.fn.isdirectory(dir) == 1 then
        api.tree.find_file { buf = dir, open = true }
        local node = explorer:get_node_from_path(dir)
        if node and node.type == "directory" then
          explorer:expand_node(node)
        end
      end
    end

    api.tree.reload()
  end)
end

function M.save_extra_data()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok or not api.tree.is_visible { any_tabpage = true } then
    return
  end

  local tree = api.tree.get_nodes()
  local dirs = {}
  collect_open_tree_dirs(tree, dirs)

  if vim.tbl_isempty(dirs) then
    return
  end

  return vim.fn.json_encode {
    nvim_tree = {
      open = true,
      dirs = dirs,
    },
  }
end

function M.restore_extra_data(_, extra_data)
  if not extra_data or extra_data == "" then
    return
  end

  local ok, data = pcall(vim.fn.json_decode, extra_data)
  if not ok or type(data) ~= "table" then
    return
  end

  local tree = data.nvim_tree
  if type(tree) == "table" and tree.open and type(tree.dirs) == "table" then
    restore_tree_dirs(tree.dirs)
  end
end

return M
