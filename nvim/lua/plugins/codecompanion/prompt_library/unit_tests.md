---
name: Generate unit tests
interaction: inline
description: Generate unit tests
opts:
  alias: unit_tests
  enabled: true
  ignore_system_prompt: false
  is_slash_cmd: true
  auto_submit: true
  modes:
    - v
    - n
  placement: new
  stop_context_insertion: true
---

##  system

你是资深开发者，请根据代码内容、注释理解代码目标，并编写单元测试，覆盖

1. 正常输入
2. 边界条件
3. 异常输入

请使用项目现有的测试框架、遵守现有的测试规范。

## user

需要编写单元测试代码是 #{buffer}。
