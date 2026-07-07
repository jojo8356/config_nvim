local M = {}

local root_markers = { "pom.xml", "mvnw", ".git" }

function M.root(bufnr)
  return vim.fs.root(bufnr or 0, root_markers)
end

function M.is_maven_project(bufnr)
  local root = M.root(bufnr)
  return root ~= nil and vim.uv.fs_stat(root .. "/pom.xml") ~= nil
end

function M.executable(root)
  local wrapper = root .. "/mvnw"
  if vim.fn.executable(wrapper) == 1 then
    return "./mvnw"
  end

  return "mvn"
end

local function shell_join(parts)
  return table.concat(vim.tbl_map(vim.fn.shellescape, parts), " ")
end

function M.term(args, opts)
  opts = opts or {}
  local root = M.root(0) or vim.fn.getcwd()
  local cmd = vim.list_extend({ M.executable(root) }, args or {})

  vim.cmd(opts.tab == false and "botright split" or "tabnew")
  vim.cmd("lcd " .. vim.fn.fnameescape(root))
  vim.fn.termopen(shell_join(cmd), {
    cwd = root,
    env = opts.env,
  })
  vim.cmd "startinsert"
end

function M.run_goal(goal)
  local args = vim.split(goal, "%s+", { trimempty = true })
  if #args == 0 then
    vim.notify("Maven: objectif vide", vim.log.levels.WARN)
    return
  end

  M.term(args)
end

function M.exec_main()
  M.term { "compile", "exec:exec" }
end

function M.setup_commands()
  local commands = {
    MavenClean = "clean",
    MavenCompile = "compile",
    MavenTest = "test",
    MavenPackage = "package",
    MavenVerify = "verify",
    MavenInstall = "install",
    MavenDependencyTree = "dependency:tree",
  }

  for name, goal in pairs(commands) do
    vim.api.nvim_create_user_command(name, function()
      M.run_goal(goal)
    end, { desc = "Run `mvn " .. goal .. "` in the project root", force = true })
  end

  vim.api.nvim_create_user_command("MavenRun", M.exec_main, {
    desc = "Run `mvn compile exec:exec` in the project root",
    force = true,
  })

  vim.api.nvim_create_user_command("MavenGoal", function(ctx)
    M.run_goal(ctx.args)
  end, {
    nargs = "+",
    complete = function()
      return {
        "clean",
        "compile",
        "test",
        "package",
        "verify",
        "install",
        "spring-boot:run",
        "exec:java",
        "dependency:tree",
      }
    end,
    desc = "Run an arbitrary Maven goal in the project root",
    force = true,
  })
end

return M
