---
title: Pixi 项目规范
categories:
  - rules
tags:
  - agents
  - instructions
  - rules
  - pixi
date: 2026-07-09 15:34:39
updated: 2026-07-09 15:35:49
toc: true
mathjax: true
description: Pixi 项目规范，仅应该维护 Pixi 管理的项目环境时由 Agent 按需引入。
---

## 项目目录结构

-   项目目录结构（若为项目）
    -   `src/<包名>`：源码目录
    -   `tests/<包名>`：*pytest* 测试目录
        -   `<test>_<模块名>.py`：单元测试文件与模块文件对应
    -   `assets/`：源码无关项目资源
    -   `tmp/`：临时文件目录
    -   `pyproject.toml`：项目配置，包含代码检查、格式化、打包等配置
    -   `pixi.toml`：*pixi* 环境配置

