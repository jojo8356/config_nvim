local jdtls = require "jdtls"
local maven = require "configs.maven"

-- Chemins Mason
local mason_path = vim.fn.expand "~/.local/share/nvim/mason"
local jdtls_path = mason_path .. "/packages/jdtls"
local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir = jdtls_path .. "/config_linux"
local jdtls_java = "/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
if vim.fn.executable(jdtls_java) ~= 1 then
  jdtls_java = "java"
end

-- Dossier de données par projet (workspace)
local root_dir = maven.root(0)
  or require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" }
  or vim.fn.getcwd()
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.expand "~/.cache/jdtls/workspace/" .. project_name

-- Debug adapters (si installés via Mason)
local bundles = {}

local java_debug_path = mason_path .. "/packages/java-debug-adapter"
local java_debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
if java_debug_jar ~= "" then
  table.insert(bundles, java_debug_jar)
end

local java_test_path = mason_path .. "/packages/java-test"
local java_test_jars = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
for _, jar in ipairs(java_test_jars) do
  if
    jar ~= ""
    and not vim.endswith(jar, "com.microsoft.java.test.runner-jar-with-dependencies.jar")
    and not vim.endswith(jar, "jacocoagent.jar")
  then
    table.insert(bundles, jar)
  end
end

local config = {
  cmd = {
    jdtls_java,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    launcher,
    "-configuration",
    config_dir,
    "-data",
    workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      home = "/usr/lib/jvm/java-21-openjdk-amd64",
      eclipse = { downloadSources = true },
      maven = {
        downloadSources = true,
        updateSnapshots = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = "/usr/lib/jvm/java-17-openjdk-amd64",
            default = true,
          },
          {
            name = "JavaSE-21",
            path = "/usr/lib/jvm/java-21-openjdk-amd64",
          },
        },
      },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      signatureHelp = { enabled = true },
      format = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*",
          "org.junit.jupiter.api.DynamicContainer.*",
          "org.junit.jupiter.api.DynamicTest.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
        },
        importOrder = {
          "java",
          "javax",
          "com",
          "org",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(client, bufnr)
    -- Activer le debug si java-debug-adapter est installé
    if #bundles > 0 then
      jdtls.setup_dap { hotcodereplace = "auto" }
      require("jdtls.dap").setup_dap_main_class_configs()
    end

    local opts = { buffer = bufnr, silent = true }
    maven.setup_commands()

    -- Actions Java spécifiques
    vim.keymap.set(
      "n",
      "<leader>jo",
      jdtls.organize_imports,
      vim.tbl_extend("force", opts, { desc = "Java: Organize imports" })
    )
    vim.keymap.set(
      "n",
      "<leader>jv",
      jdtls.extract_variable,
      vim.tbl_extend("force", opts, { desc = "Java: Extract variable" })
    )
    vim.keymap.set("v", "<leader>jv", function()
      jdtls.extract_variable(true)
    end, vim.tbl_extend("force", opts, { desc = "Java: Extract variable" }))
    vim.keymap.set(
      "n",
      "<leader>jc",
      jdtls.extract_constant,
      vim.tbl_extend("force", opts, { desc = "Java: Extract constant" })
    )
    vim.keymap.set("v", "<leader>jc", function()
      jdtls.extract_constant(true)
    end, vim.tbl_extend("force", opts, { desc = "Java: Extract constant" }))
    vim.keymap.set("v", "<leader>jm", function()
      jdtls.extract_method(true)
    end, vim.tbl_extend("force", opts, { desc = "Java: Extract method" }))

    -- Tests
    vim.keymap.set(
      "n",
      "<leader>jt",
      jdtls.test_nearest_method,
      vim.tbl_extend("force", opts, { desc = "Java: Test method" })
    )
    vim.keymap.set("n", "<leader>jT", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "Java: Test class" }))
    vim.keymap.set("n", "<leader>mr", maven.exec_main, vim.tbl_extend("force", opts, { desc = "Maven: Run exec:java" }))
    vim.keymap.set("n", "<leader>mt", function()
      maven.run_goal "test"
    end, vim.tbl_extend("force", opts, { desc = "Maven: Test" }))
    vim.keymap.set("n", "<leader>mp", function()
      maven.run_goal "package"
    end, vim.tbl_extend("force", opts, { desc = "Maven: Package" }))
    vim.keymap.set("n", "<leader>mv", function()
      maven.run_goal "verify"
    end, vim.tbl_extend("force", opts, { desc = "Maven: Verify" }))
    vim.keymap.set("n", "<leader>md", function()
      maven.run_goal "dependency:tree"
    end, vim.tbl_extend("force", opts, { desc = "Maven: Dependency tree" }))
    vim.keymap.set(
      "n",
      "<leader>mu",
      "<cmd>JdtUpdateConfig<cr>",
      vim.tbl_extend("force", opts, { desc = "Java: Update Maven config" })
    )

    -- Debug
    vim.keymap.set("n", "<leader>jd", function()
      local ok, dap = pcall(require, "dap")
      if ok then
        dap.continue()
      else
        print "nvim-dap non installé"
      end
    end, vim.tbl_extend("force", opts, { desc = "Java: Debug" }))
  end,
}

jdtls.start_or_attach(config)
