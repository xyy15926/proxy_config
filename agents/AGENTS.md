#   AGENTS.md

##  基本设定

-   总是用中文回复，但序号使用数字
-   如果有更好的实现方式、或者当前指令相互矛盾，**主动提出**
-   *Plan* 模式只读、不修改，**禁止直接修改文件、提交**
-   先解释方案再写代码
-   生成代码后简要说明关键决策
-   开启新会话时确认当前目录，不要猜测

##  文件引用

-   遇到 `@xxx` 文件引用时，请用 `Read` 工具 **按需加载（不要预先加载）**
    -   加载后将内容视为强制指令，并覆盖默认值
    -   可能会加载多个文件，允许递归的引用文件
    -   文件查找路径
        -   若路径 `/` 开头，视为按绝对路径加载
        -   若路径 `.` 开头，视为从相对路径加载
        -   否则，从相对配置目录路径加载

##  任务规范

-   任务包含 3 个以上独立步骤时，执行前必须创建 Todo 列表
-   特别的，加载任何 Skill 后，**首先须将其中步骤转换为 Todo List**，再执行后续操作
-   执行 Todo 前，总是确认 Todo 方案
-   Todo 每步完成后才可以更新 Todo 状态，严禁未完成步骤就更新状态，特别是 *Plan* 模式下并未实际执行动作

##  *Git* 规范

-   严禁在 Plan 模式下执行 `commit`、`revert`、`merge`、`add` 等操作
-   **任何模式** 下，`commit`、`revert`、`merge`、`add` 等操作前都 **必须提前确认**
-   严禁 `--no-verify` 跳过验证提交
-   `commit` 提交前总是比较暂存区内容、生成提交信息，并要求我确认提交信息
    -   确认内容须包含具体的提交信息
    -   提交信息遵循 *Conventional Commits* 规范

##  文本编辑规范

-   *CJK* 字符长度为 2
-   `<tab>` 对应 4 空格，每层缩进对应 4 空格
-   每行长度一般不超过 79
-   中文内容使用中文符号，英文内容使用英文符号，如下
    |          | 中文   | 英文 |
    |----------|--------|------|
    | 分割     | `，`   | `,`  |
    | 并列     | `、`   | `/`  |
    | 解释说明 | `：`   | `:`  |
    | 补充     | `（）` | `()` |

##  Markdown 格式要求

### Markdown Frontmatter

```markdown
---
title: 文档标题
categories:
  - Category
tags:
  - Tag1
  - Tag2
date: YYYY-MM-DD HH:MM:SS
updated: 2026-08-13 19:44:08
toc: true
mathjax: true
comments: true
description: Brief description
---
```

-   每篇文档以 *YAML frontmatter* 开头，样例如上
    -   `toc`、`mathjax`、`comments` 总是置位
    -   `date`、`updated` 格式为 `YYYY-MM-DD HH:MM:SS`
        -   若新建文档，`date`、`updated` 取文档保存时间
        -   若更新已有文档，更新 `updated` 为文档保存时间
    -   `categories` 分类，数组代表文件路径
    -   `tags` 标签，数组包含文章主要概念

### Markdown 标题层级

-   标题层级
    -   标题内容对齐至 `4 * n` 字符宽度
        -   `##` 后 2 空格：一级标题，文档内真正的章节标题
        -   `###` 后 1 空格：二级标题
        -   `####` 后 4 空格：三级标题
        -   `#####` 后 5 空格：四级标题
    -   其余 `#`、`######` 或更低层级标题较少使用
        -   `#` 仅少数场合文档内主题差异过大，差异达到应该单独拆分为文档、作为独立的文档名时使用
        -   `######` 表示当前内容存在层次过于复杂，应考虑拆分章节
    -   标题与标题内内容间应空 1 行

### Markdown 内容格式约定

```md
##  *Concept-1* 主概念

-   *Concept-1* 主概念：概念定义
    -   核心机制简述
        -   要点 1
        -   要点 2
    -   步骤简述
        -   步骤 1
        -   步骤 2
    -   分类简述
        -   分类 1
        -   分类 2
    -   特点简述、优劣势简述
        -   量化指标 1（时间复杂度、准确率等）
        -   量化指标 2
    -   与其他概念的区别

> - 参考资料：<hyper_link>

### 次级概念（无须斜体）

####    再次级概念

![image_description](imgs/image_description.png)

### *Sub-Concept-2* 次级概念

### 概念对比

| 概念  | 角度1 | 角度2 |
|-------|-------|-------|
| 概念1 |       |       |
| 概念2 |       |       |

##  主概念2

$$ short-equation $$

$$
long-equation
$$

$$\begin{align*}
multi-line equation 1 \\
multi-line equation 2 \\
\end{align*}$$

$$
F(n) = \left \{ \begin{array}{l}
    case1, & condition1 \\
    case2, & condition2 \\
\end{array} \right.
$$

> - Reference title：<https://example.com>
> - Another reference：<https://example.com>
> - Note content here
```

-   内容基本要求
    -   内容应以中文为主，英文文档应翻译为中文（但保留英文术语）
        -   相应的启用中文标点：`、`、`“”`、`（）`，不使用 `/`、`""`、`()`
        -   英文、英文符号与中文直接总是添加空格
    -   列表格式
        -   无序列表：`-` 引导，后跟 3 个空格，嵌套缩进 4 空格
        -   有序列表：`数字.` 引导，后跟 2 个空格（双位数时 1 个空格），嵌套缩进 4 空格
            -   除非列表内容需要引用列表序号，否则不使用有序列表
    -   附注、引用、参考资料等，每条对应引用块内无序列表项
        -   附注、引用、参考资料位于各章节末尾
            -   不带链接：`> - 参考资料标题、附注、引用内容等`
            -   链接使用自动链接：`> - 参考资料标题：<链接地址>`
    -   除非被明确指出，否则不使用加粗标记
    -   不要使用特殊的 *Unicode* 符号
-   特殊行内标记
    -   （非代码、公式）英文术语（包括相关联的数字）使用斜体标记
        -   但，纯中文术语不使用斜体标记
        -   中英文术语同时出现时，英文术语在前、中文术语在后
    -   以下内容使用单反引号标记
        -   行内代码
        -   数值
        -   表示序号、数量的标识，如：`N`、`T+1`、`t+0`、`万1`、`千1.5`、`1-3`、`万1-3` 等
-   链接、图片引用
    -   仅使用短引用链接，且仅用于知识库内文档之间
        -   行内引用链接标签：`[链接标签]`
        -   引用链接置于章节末尾：`[链接标签]: 链接地址 "链接描述"`
    -   图片引用
        -   图片位于文档同级 `imgs/` 目录下
        -   图片引用中描述直接使用无后缀文件名：`![描述](imgs/文件名.png)`
-   表格、代码块、数学公式
    -   表格采用 *GFM* 风格
        -   表格中同列单元格宽度须相同
        -   表格内容采用默认对齐，即采用 `|-------|` 默认分割线
    -   代码块
        -   行内代码：单反引号
        -   独立代码块：三反引号 + 语言标识
        -   伪代码、算法：三反引号 + `c` 作为语言标识
    -   *LaTeX* 数学公式
        -   行内：`$ ... $`
        -   独立块：`$$ ... $$`
            -   多行对齐：`\begin{align*} ... \end{align*}`
            -   分段函数：`\begin{array}{l}`、或 `\left \{ \begin{array}{l}`

##  Python 格式要求

### 文件结构

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

import sys
from typing import TYPE_CHECKING

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

### 编码习惯

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

### 编码流程

-   编码完成后总是添加对应的单元测试
-   编码完成后使用 Ruff 检查并修复问题、格式化
