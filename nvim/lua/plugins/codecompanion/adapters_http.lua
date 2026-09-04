-- ==========================================================================
-- File    : adapters_http.lua
-- Author  : xyy15926
-- Created : 2026-09-01 20:05:50
-- Updated : 2026-09-03 16:29:23
-- Desc    : HTTP adapters.
--
-- 1. `adapter` 适配器：调用、参数控制、报文解析等配置
-- 1.1. CodeCompanion 官方模型运营商适配器可参考
--   `stdpath("config")/lazy/codecompanion.nvim/lua/codecompanion/adapters/`
--   目录下适配器配置文件
-- 1.2. `adapters` 一般无需配置
-- 1.2.1. 主要模型运营商 openai、anthropic、openrouter 等已有官方适配实现：
--   默认模型可在对应的 `interactions` 中配置，候选模型列表在适配器中会自动
--   获取、配置
-- 1.2.2 仅，温度、top_p 等控制参数需在 `adapters` 中 `schema` 中配置
-- 1.2.3 或，需创建从头、或基于 `openai_compatiable` 等创建自定义适配器A
-- 1.3. 注意区分 HTTP、ACP 适配器需分开配置
-- ==========================================================================

-- %% =======================================================================
--  先拉 adapters 中模型清单，判断模型参数支持
--  但，这样要先加载 codecompanion 插件，那插件整体配置要基于 `config` 字段
--  的回调函数，且 `opts` 要移入 `config` 函数中
--  故，下述配置直接手动至 `enabled = true`
--  
--  Ref:
--  codecompanion.nvim/lua/adapters/http/openrouter.lua
-- ==========================================================================
--
-- local base_adapter = require("codecompanion.adapters.http.openrouter")
-- local fetch_models = require("codecompanion.adapters.utils.models.fetch")
-- local models_source = {
--   name = "OpenRouter",
--   url = "https://openrouter.ai/api/v1/models",
-- }
--
-- ---@param self CodeCompanion.HTTPAdapter
-- ---@param parameter string
-- ---@return boolean
-- local function model_supports(self, parameter)
--   local cached_models = fetch_models.get(models_source, self)
--   local model = cached_models[self.schema.model.default]
--   if not model then
--     return false
--   end
--
--   return model.opts.supported_parameters[parameter] or false
-- end


return {
  -- HTTP 适配器全局配置
  opts = {
    show_model_choices = true,      -- 切换适配器时提供模型列表
    compaction = false,             -- 禁用服务器侧会话压缩
    show_presets = true,            -- 展示预定义适配器
    proxy = nil,                    -- 设置代理
    allow_insecure = true,
  },
  openrouter_free = function()
    return require("codecompanion.adapters").extend("openrouter", {
      env = {
        api_key = "OPENROUTER_API_KEY",
      },
      -- `schema` 中设置值
      schema = {
        preset = { default = nil, },  -- openrouter 网站上预置的 schema，启用将覆盖本地设置
        provider = { default = nil, },
        model = {
          -- default = "z-ai/glm-5.2:free",
          default = "minimax/minimax-m3:free",
        },
        -- 以下参数在 openrouter 适配器中 `enabled` 是根据模型情况确定是否支持
        -- 若未手动 `enabled`，则在首次启动对话时，以下参数不启用
        temperature = {
          default = 1,
          -- enabled = model_supports(base_adapter, "temperature"),
          enabled = true,
        },
        top_p = {
          default = 1,
          enabled = true,
        },
        ["reasoning.effort"] = {
          default = "medium",
          enabled = true,
        },
      },
    })
  end,
}
