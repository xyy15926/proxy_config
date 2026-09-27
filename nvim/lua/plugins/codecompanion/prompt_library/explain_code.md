---
name: Explain code
interaction: chat 
description: Explain how code works
opts:
  alias: explain
  enabled: true
  ignore_system_prompt: false
  is_slash_cmd: true
  auto_submit: false
  modes:
    - v
  stop_context_insertion: true
---

##  system

你是资深开发者，被要求解释代码时，你应该清晰、准确、简洁的描述：

1. 代码整体实现的功能、设计思路
2. 代码中函数、重点代码块的功能
3. 潜在的注意事项
4. 提供适用上下文、适用示例

##  user

请解释以下代码：

```${context.filetype}
${context.code}
```
