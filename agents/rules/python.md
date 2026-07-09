---
title: Python 规范
categories:
  - rules
tags:
  - agents
  - instructions
  - rules
  - python
date: 2026-07-09 14:56:37
updated: 2026-07-09 15:37:44
toc: true
mathjax: true
description: Python 代码规范，仅应该编写 Python 代码时由 Agent 按需引入。
---

##  文件结构

```python
#!/usr/bin/env python3
# ---------------------------------------------------------
#   Name: <Filename>.py
#   Author: <Author>
#   Created: YYYY-MM-DD HH:MM:SS
#   Updated: 2026-07-09 14:55:10
#   Description:
# ---------------------------------------------------------
"""
File doc string.
"""

# %%
from __future__ import annotations
from typing import Any
import sys
import numpy as np
# from IPython.core.debugger import set_trace

if __name__ == "__main__":
    from importlib import reload
    from flagbear.slp import finer, storage
    reload(finer)
    reload(storage)
from flagbear.slp import finer, storage

# %%
CONST = 1


# %%
def func(
    param_a: int,
):
    """Function Docstring."""
    pass


# %%
class Foo:
    """Class Docstring."""
    pass


# %%
if __name__ == "__main__":
    pass
```

-   开头注释
    -   *Shebang* 行：固定为 `#!/usr/bin/env python3`
    -   文件信息段：根据实际情况补充
        -   `Name`：文件名
        -   `Author`：项目作者
        -   `Date`、`Updated` 格式为 `YYYY-MM-DD HH:MM:SS`
            -   若新建文档，`Date`、`Updated` 取文档保存时间
            -   若更新已有文档，更新 `Updated` 为文档保存时间
        -   `Description`：文件描述
-   文件 *Doc String* 字符串
-   导入段
    -   `from __future__ import annotations`
    -   导入 `typing`、`collections.abc` 中注解类型
    -   标准库模块
    -   第三方库模块
    -   热重载、脚手架（方便调试代码）
        -   **已注释的** 引入 `set_trace`、`debug` 行
        -   包含 `reload` 模块 `if __name__ == "__main__":` 块
    -   本地模块
-   简单全局常量声明段
-   函数、类等文件主要内容
    -   顶层函数、类定义之间空 2 行，类方法之间空 1 行
    -   `# %%` 作为 *IPython* 单元格标记，位于逻辑段、函数与类定义之间
-   命令行调用段 `if __name__ == "__main__":`（如有）

##  编码习惯

-   函数不超过 40 行，否则进行拆分逻辑
-   每行宽度一般不超过 79，否则尝试拆分
    -   普通代码：可使用 `()` 包裹以支持换行
    -   字符串：可直接拆分、换行
    -   函数、方法签名：每个参数独立一行
-   注释、文档字符串使用英文
-   使用 `"` 而不是 `'` 引导字符串
-   *Python 3.9+* 风格类型注解
    -   泛型：`list[str]`、`dict[str, int]`、`collections.abc.Mappging` 等
    -   联合类型 `|` 语法：`str | int`、`str | None`
-   *Google* 风格文档字符串
    -   包含以下小节
        ```
        Params:
        Returns:
        Attrs:
        Raise:
        Yield:
        Examples:
        Ref:
        Shape: For numpy.ndarray or Tensor only
        ```
    -   小节标题与内容分割线：`--------------------------`
    -   最初层级小节内容无需额外缩进
-   变量、文件命名规范如下表
    | 类型           | 约定                  |
    |----------------|-----------------------|
    | 包、子包       | `snake_case`          |
    | 类             | `PascalCase`          |
    | 函数           | `snake_case`          |
    | 方法           | `snake_case`          |
    | 类型别名       | `PascalCase`          |
    | 模块级常量     | `UPPER_SNAKE_CASE`    |
    | 私有属性、方法 | `_leading_underscore` |
    | 测试函数       | `test_*`              |
    | 测试类         | `Test*`               |
