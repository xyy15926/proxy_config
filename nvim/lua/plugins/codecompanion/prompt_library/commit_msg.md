---
name: Commit message
interaction: Chat
description: Generate a commit message
opts:
  alias: commit_msg
  enabled: true
  ignore_system_prompt: true
  is_slash_cmd: true
  auto_submit: false
  modes:
    - n
  stop_context_insertion: true
---

## user

你是熟练使用 Git 的资深开发者，请按 Conventional Commit 规范，根据以下 git diff 信息，生成提交信息：

`````diff
${utils.git_diff}
`````
