-- Debugging plugins. Per-language debug setup lives in configs/dap.lua.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- panels for variables, stack, breakpoints
      "nvim-neotest/nvim-nio", -- required by nvim-dap-ui
      "mfussenegger/nvim-dap-python", -- Python debug adapter setup
    },
    -- Loads on first use of these keys, or when another plugin requires "dap".
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Debug: Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Debug: Start / continue" },
      { "<leader>do", "<cmd>DapStepOver<cr>", desc = "Debug: Step over" },
      { "<leader>di", "<cmd>DapStepInto<cr>", desc = "Debug: Step into" },
      { "<leader>dO", "<cmd>DapStepOut<cr>", desc = "Debug: Step out" },
      { "<leader>dt", "<cmd>DapTerminate<cr>", desc = "Debug: Terminate" },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dapui.setup()

      -- Open the debug UI when a session starts and close it when it ends.
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      require "configs.dap"
    end,
  },
}
