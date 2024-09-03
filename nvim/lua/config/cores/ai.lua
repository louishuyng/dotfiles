require("codecompanion").setup({
  strategies = {
    -- CHAT STRATEGY ----------------------------------------------------------
    chat = {
      adapter = "copilot",
    },
    -- INLINE STRATEGY --------------------------------------------------------
    inline = {
      adapter = "copilot",
    },
    -- AGENT STRATEGY ---------------------------------------------------------
    agent = {
      adapter = "copilot",
    },
  },
  -- DEFAULT PROMPTS ----------------------------------------------------------
  default_prompts = {
    ["Custom Prompt"] = {
      strategy = "inline",
      description = "Prompt the LLM from Neovim",
      opts = {
        index = 3,
        default_prompt = true,
        mapping = "<LocalLeader>cc",
        user_prompt = true,
      },
      prompts = {
        {
          role = "system",
          tag = "system_tag",
          content = function(context)
            if context.buftype == "terminal" then
              return "I want you to act as an expert in writing terminal commands that will work for my current shell "
                  .. os.getenv("SHELL")
                  ..
                  ". I will ask you specific questions and I want you to return the raw command only (no codeblocks and explanations). If you can't respond with a command, respond with nothing"
            end
            return "I want you to act as a senior "
                .. context.filetype
                ..
                " developer. I will ask you specific questions and I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing"
          end,
        },
      },
    },
    ["Explain"] = {
      strategy = "chat",
      description = "Explain how code in a buffer works",
      opts = {
        index = 4,
        default_prompt = true,
        mapping = "<LocalLeader>ce",
        modes = { "v" },
        slash_cmd = "explain",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content = [[When asked to explain code, follow these steps:

1. Identify the programming language.
2. Describe the purpose of the code and reference core concepts from the programming language.
3. Explain each function or significant block of code, including parameters and return values.
4. Highlight any specific functions or methods used and their roles.
5. Provide context on how the code fits into a larger application if applicable.]],
        },
        {
          role = "${user}",
          contains_code = true,
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return "Please explain this code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
          end,
        },
      },
    },
    ["Unit Tests"] = {
      strategy = "chat",
      description = "Generate unit tests for the selected code",
      opts = {
        index = 5,
        default_prompt = true,
        mapping = "<LocalLeader>ct",
        modes = { "v" },
        slash_cmd = "tests",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content = [[When generating unit tests, follow these steps:

1. Identify the programming language.
2. Identify the purpose of the function or module to be tested.
3. List the edge cases and typical use cases that should be covered in the tests and share the plan with the user.
4. Generate unit tests using an appropriate testing framework for the identified programming language.
5. Ensure the tests cover:
      - Normal cases
      - Edge cases
      - Error handling (if applicable)
6. Provide the generated unit tests in a clear and organized manner without additional explanations or chat.]],
        },
        {
          role = "${user}",
          contains_code = true,
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return "Please generate unit tests for this code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
          end,
        },
      },
    },
    ["Fix code"] = {
      strategy = "chat",
      description = "Fix the selected code",
      opts = {
        index = 6,
        default_prompt = true,
        mapping = "<LocalLeader>cf",
        modes = { "v" },
        slash_cmd = "fix",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content = [[When asked to fix code, follow these steps:

1. **Identify the Issues**: Carefully read the provided code and identify any potential issues or improvements.
2. **Plan the Fix**: Describe the plan for fixing the code in pseudocode, detailing each step.
3. **Implement the Fix**: Write the corrected code in a single code block.
4. **Explain the Fix**: Briefly explain what changes were made and why.

Ensure the fixed code:

- Includes necessary imports.
- Handles potential errors.
- Follows best practices for readability and maintainability.
- Is formatted correctly.

Use Markdown formatting and include the programming language name at the start of the code block.]],
        },
        {
          role = "${user}",
          contains_code = true,
          content = function(context)
            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

            return "Please fix the selected code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
          end,
        },
      },
    },
    ["Buffer selection"] = {
      strategy = "inline",
      description = "Send the current buffer to the LLM as part of an inline prompt",
      opts = {
        index = 7,
        modes = { "v" },
        default_prompt = true,
        mapping = "<LocalLeader>cb",
        slash_cmd = "buffer",
        auto_submit = true,
        user_prompt = true,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          tag = "system_tag",
          content = function(context)
            return "I want you to act as a senior "
                .. context.filetype
                ..
                " developer. I will ask you specific questions and I want you to return raw code only (no codeblocks and no explanations). If you can't respond with code, respond with nothing."
          end,
        },
        {
          role = "${user}",
          contains_code = true,
          content = function(context)
            local buf_utils = require("codecompanion.utils.buffers")

            return "### buffers\n\nFor context, this is the whole of the buffer:\n\n```"
                .. context.filetype
                .. "\n"
                .. buf_utils.get_content(context.bufnr)
                .. "\n```\n\n"
          end,
        },
        {
          role = "${user}",
          contains_code = true,
          tag = "visual",
          condition = function(context)
            -- The inline strategy will automatically add this in visual mode
            return context.is_visual == false
          end,
          content = function(context)
            local selection = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
            return "And this is the specific code that relates to my question:\n\n```"
                .. context.filetype
                .. "\n"
                .. selection
                .. "\n```\n\n"
          end,
        },
      },
    },
    ["Explain LSP Diagnostics"] = {
      strategy = "chat",
      description = "Explain the LSP diagnostics for the selected code",
      opts = {
        index = 8,
        default_prompt = true,
        mapping = "<LocalLeader>cl",
        modes = { "v" },
        slash_cmd = "lsp",
        auto_submit = true,
        user_prompt = false,
        stop_context_insertion = true,
      },
      prompts = {
        {
          role = "system",
          content =
          [[You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages. When appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting.]],
        },
        {
          role = "${user}",
          content = function(context)
            local diagnostics = require("codecompanion.helpers.actions").get_diagnostics(
              context.start_line,
              context.end_line,
              context.bufnr
            )

            local concatenated_diagnostics = ""
            for i, diagnostic in ipairs(diagnostics) do
              concatenated_diagnostics = concatenated_diagnostics
                  .. i
                  .. ". Issue "
                  .. i
                  .. "\n  - Location: Line "
                  .. diagnostic.line_number
                  .. "\n  - Severity: "
                  .. diagnostic.severity
                  .. "\n  - Message: "
                  .. diagnostic.message
                  .. "\n"
            end

            return "The programming language is "
                .. context.filetype
                .. ". This is a list of the diagnostic messages:\n\n"
                .. concatenated_diagnostics
          end,
        },
        {
          role = "${user}",
          contains_code = true,
          content = function(context)
            return "This is the code, for context:\n\n"
                .. "```"
                .. context.filetype
                .. "\n"
                .. require("codecompanion.helpers.actions").get_code(
                  context.start_line,
                  context.end_line,
                  { show_line_numbers = true }
                )
                .. "\n```\n\n"
          end,
        },
      },
    },
    ["Generate a Commit Message"] = {
      strategy = "chat",
      description = "Generate a commit message",
      opts = {
        index = 9,
        default_prompt = true,
        mapping = "<LocalLeader>cm",
        slash_cmd = "commit",
        auto_submit = true,
      },
      prompts = {
        {
          role = "${user}",
          contains_code = true,
          content = function()
            return
                "You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:"
                .. "\n\n```\n"
                .. vim.fn.system("git diff")
                .. "\n```"
          end,
        },
      },
    },
  },
  display = {
    action_palette = {
      width = 95,
      height = 10,
    },
    chat = {
      window = {
        layout = "float", -- float|vertical|horizontal|buffer
        border = "none",  -- none|single|double
      },
    },
  },
})


vim.keymap.set("n", "<LocalLeader>ct", ":CodeCompanionToggle<CR>", { desc = "Toggle Code Companion" })
