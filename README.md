# 舞台梦境ai项目-过程记录

「醒来之前」梦境舞台与 AI 交互项目的过程归档，包含早期视觉探索、网页舞台预演、Blender 建模、Godot 叙事游戏、研究报告及验证截图。

## 从哪里开始

- [Godot 游戏与操作说明](game/README.md)：当前独立游戏原型、3D资产、开发说明与能力边界。
- [网页舞台预演](prototype/README.md)：共振排练室、演员控制和可选AI后台。
- [Windows 游戏下载](https://github.com/hqqcf0320-wq/dream-stage-ai-process-records/releases/tag/archive-v0.2)：现有 v0.2 交付包。
- [研究与制作记录](docs/)：实现计划、舞台研究、建模研究及验证记录。
- [PDF报告](reports/)；[效果截图](docs/evidence/)。
- [2026-09-01早期探索](archive/2026-09-01/)：早期视觉原型、第一人称网页原型和研究资料。

## 3D源文件

- `game/source/before-waking-art.blend`：游戏美术母版。
- `game/assets/`：GLB模型、贴图、字体和声音。
- `prototype/public/assets/before-waking-master.blend`：舞台预演母版。
- `prototype/public/assets/before-waking-stage.glb`：网页预演资产。

## 运行网页预演

安装 Node.js 后，在 `prototype` 目录运行：

```sh
npm ci
npm run dev
```

根据终端提示打开本地网址。AI后台需要自行设置服务器环境变量 `OPENAI_API_KEY`；无凭证仍可按原说明运行规则预演。游戏开发与导出依赖见 `game/README.md`。

## 归档说明

本仓库保存已有项目文件，不表示这些原型已经完成真实舞台或多人观众验证。能力边界以各版本README为准。原有研究记录保留当时内容，未在本次归档中重新核验。

原文件名和目录结构保留；早期独立项目置于 `archive/2026-09-01/`。未包含本机工具安装、依赖目录、缓存、临时文件和环境凭证。Windows现成交付包作为Release附件保存。本次新增本说明和 `FILE_MANIFEST.csv`，清单记录原始文件的大小与SHA-256校验值。
