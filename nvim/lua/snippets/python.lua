-- ========================================================
-- snippets/python.lua
--
-- 1. 采用声明式风格配置，或许适合被其他 Snippets 文件引用？
-- ========================================================

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local filename = function() return vim.fn.expand("%:t") end
local now      = function() return os.date("%Y-%m-%d %H:%M:%S") end
local author   = os.getenv("USER") or "Author"

-- ls.add_snippets("python",  {})     -- 命令式风格配置
return {                              -- 声明式风格配置
  -- 文件模板
  s("heading", {
    t({
      "#!/usr/bin/env python3",
      "# ===========================================================================",
    }),
    t({ "", "# File    : " }), f(filename),
    t({ "", "# Author  : " }), i(1, author),
    t({ "", "# Created : " }), f(now),
    t({ "", "# Updated : " }), f(now),
    t({ "", "# Desc    : " }), i(2, "TODO"),
    t({
      "",
      "# ===========================================================================",
      "",
    }),
    t({
      "",
      "# %%",
      "import logging",
      "import sys",
      "from typing import TYPE_CHECKING",
      "",
      "if TYPE_CHECKING:",
      "    from typing import Any",
      "",
      "logger = logging.getLogger(__name__)",
      "",
      "# %%",
      "",
    }), i(0), -- Tab 跳转退出位置，可选
    t({"", "", "", ""}),
  }),

  s("mblock", {
    t({
      "#%% =========================================================================",
      "#   ",
    }), i(1, "Block Comment"),
    t({
      "",
      "# ===========================================================================",
      "",
    }), i(0),
  }),

  -- 函数、类、dataclass
  s("def", {
    t("def "), i(1, "func"), t("("), i(2), t(") -> "), i(3, "None"), t(":"),
    t({
      "",
      "    \"\"\""
    }), i(4, "Docstring"),
    t({
      "",
      "",
      "    Params:",
      "    ---------------------------",
      "",
      "    Returns:",
      "    ---------------------------",
      "",
      "    \"\"\"",
      "    ",
    }), i(0, "pass"),
  }),

  s("deft", {
    t("def test_"), i(1, "func"), t("():", "    "),
    i(0, "pass"),
  }),

  s("class", {
    t("class "), i(1, "MyClass"), i(2, ""), t(":"),
    t({
      "",
      "    \"\"\""
    }), i(3, "Docstring"),
    t({
      "",
      "",
      "    Attrs:",
      "    ---------------------------",
      "",
      "    \"\"\"",
      "    def __init__(self"
    }), i(4), t("):"),
    t({
      "",
      "       \"\"\""
    }), i(5, "Docstring"),
    t({
      "",
      "",
      "       Params:",
      "       ---------------------------",
      "",
      "       \"\"\"",
      "       ",
    }), i(0, "pass"),
  }),

  s("dataclass", {
    t({
      "@dataclass",
      "class "
    }), i(1, "DataClass"), t(":"),
    t({
      "",
      "    \"\"\""
    }), i(2, "Docstring"),
    t({
      "",
      "",
      "    Attrs:",
      "    ---------------------------",
      "",
      "    \"\"\"",
    }),
    t({ "", "    " }), i(3, "field"), t(": "), i(4, "type"), t(" = "), i(5, "default"),
  }),

  s("docstring", {
    t({ '"""' }), i(1, "docstring"),
    t({
      "",
      "",
      "Params:",
      "---------------------------",
      "",
    }), i(2, "arg: description"),
    t({
      "",
      "",
      "Returns:",
      "---------------------------",
      "",
    }), i(3, "type: description"),
    t({
      "",
      "",
      "Raises:",
      "---------------------------",
      "",
    }), i(4, "Exception: when"),
    t({ "", '"""' }),
  }),

  -- 代码块缩略
  s("main", {
    t({
      "# %%",
      "def main() -> int:",
      "    \"\"\""
    }), i(1, "Main entry point"),
    t({
      "\"\"\"",
      "    ",
    }), i(0),
    t({
      "",
      "",
      "# %%",
      "if __name__ == \"__main__\":",
      "    sys.exit(main())",
    }),
  }),

  s("ifmain", {
    t({ "if __name__ == \"__main__\":", "    " }),
    i(1, "main()"),
  }),

  s("for", {
    t("for "), i(1, "item"), t(" in "), i(2, "iterable"), t(":"),
    t({ "", "    " }), i(0, "pass"),
  }),

  s("fori", {
    t("for "), i(1, "i"), t(" in range("), i(2, "n"), t("):"),
    t({ "", "    " }), i(0, "pass"),
  }),

  s("with", {
    t("with "), i(1, "context"), t(" as "), i(2, "var"), t(":"),
    t({ "", "    " }), i(0, "pass"),
  }),

  s("try", {
    t({ "try:", "    " }), i(1, "pass"),
    t({ "", "except " }), i(2, "Exception"), t(" as "), i(3, "e"), t(":"),
    t({ "", "    " }), i(0, "pass"),
  }),

  s("tryf", {
    t({ "try:", "    " }), i(1),
    t({ "", "except " }), i(2, "Exception"), t(" as "), i(3, "e"), t(":"),
    t({ "", "    " }), i(4),
    t({ "", "finally:", "    " }), i(0),
  }),

  s("listc", {
    t("["), i(1, "expr"), t(" for "), i(2, "x"), t(" in "), i(3, "iter"), i(4, " if cond"), t("]"),
  }),

  s("dictc", {
    t("{"), i(1, "k"), t(": "), i(2, "v"), t(" for "), i(3, "k, v"), t(" in "), i(4, "iter"), t("}"),
  }),

  -- 模块相关
  s("reload", {
    t({
      "if __name__ == \"__main__\":",
      "    from importlib import reload",
      "",
    }),
    t({
      "",
      "    from "
    }), i(1, "package"), t({ " import " }), i(2, "mod"),
    t({
      "",
      "    reload(",
    }), i(3, "mod"), t(")"),
  }),

  s("logging", {
    t({
      "import logging",
      "",
      "logger = logging.getLogger(__name__)",
      ""
    }),
  }),

  s("argparse", {
    t({
      "import argparse",
      "",
      "parser = argparse.ArgumentParser(description=\""
    }),
    i(1, "Description"), t({ "\")", "parser.add_argument(\"" }),
    i(2, "--foo"), t("\", type="), i(3, "str"), t(", default="), i(4, "None"), t(", help=\""), i(5), t({ "\")", "args = parser.parse_args()" }),
  }),

  s("fixture", {
    t({
      "import pytest",
      "",
      "@pytest.fixture",
      "def ",
    }), i(1, "my_fixture"), t("("), i(2), t("):"),
    t({
      "",
      "    ",
    }), i(3, "pass"),
    t({
      "",
      "    yield",
      "",
      "    ",
    }), i(4, "pass"),
  }),

  s("pathlib", {
    t({
      "from pathlib import Path",
      "",
      "BASE_DIR = Path(__file__).resolve().parent"
    }),
  }),
}
