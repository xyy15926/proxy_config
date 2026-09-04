-- ==========================================================================
-- File    : prompt_library.lua
-- Author  : xyy15926
-- Created : 2026-09-01 21:55:38
-- Updated : 2026-09-01 21:55:38
-- Desc    : Prompts.
-- ==========================================================================

return {
  -- 内置提示词覆盖示例
  ["Explain"] = {
    strategy = "chat",
    description = "解释选中的代码",
    prompts = {
      {
        role = "system",
        content = "你是一个资深软件工程师。用简洁准确的语言解释代码逻辑，重点说明：\n1. 这段代码做了什么\n2. 关键的实现细节\n3. 潜在的注意事项",
      },
      {
        role = "user",
        content = "请解释以下代码：\n\n{{selection}}",
      },
    },
  },

  -- 自定义提示词：代码审查
  ["Code Review"] = {
    strategy = "chat",
    description = "对选中的代码进行审查",
    prompts = {
      {
        role = "system",
        content = "你是一个严格的代码审查者。从以下维度审查代码：\n1. 正确性：是否有逻辑错误或边界情况未处理\n2. 可读性：命名、结构是否清晰\n3. 性能：是否有明显的性能问题\n4. 安全性：是否有潜在的安全风险\n给出具体、可操作的改进建议。",
      },
      {
        role = "user",
        content = "请审查以下代码：\n\n{{selection}}",
      },
    },
  },

  -- 自定义提示词：生成单元测试
  ["Generate Tests"] = {
    strategy = "inline",
    description = "为当前函数生成单元测试",
    prompts = {
      {
        role = "system",
        content = "你是一个测试工程师。为给定的函数编写全面的单元测试，覆盖：\n1. 正常输入\n2. 边界条件\n3. 异常输入\n使用与项目一致的测试框架。",
      },
      {
        role = "user",
        content = "请为以下函数生成单元测试：\n\n{{selection}}",
      },
    },
  },
}
