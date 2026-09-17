# 梦境 AI 舞台空间：视觉 Skills、模型与原型技术检索

核验日期：2026-09-01  
来源范围：官方 GitHub、官方产品文档、官方模型页、论文/模型卡。没有用榜单或营销类二手文章替代事实核验。

## 一句话结论

对你的项目，最好的第一版不是“让一个最强 AI 模型现场不停生成视频”，而是：

> **高质量模型先生成梦境素材，TouchDesigner 在现场根据演员身体、声音和主动控制实时重组这些素材；实时扩散只作为可随时关闭的实验支路。**

推荐栈：

```text
概念图 / 纹理 / 短视频
GPT Image 2、Midjourney V8.2、Krea 2、Nano Banana 2
                │
                ▼
      ComfyUI（可重复的生成工作流）
                │
                ▼
TouchDesigner（反馈、粒子、雾、投影、声音分析）
        ▲                       ▲
        │                       │
MediaPipe 摄像头动作追踪       麦克风 FFT / RMS
        │                       │
        └── 演员控制：freeze / reject / replay / intensity
```

如果申请材料需要一个可以直接打开的网页，再平行做一个 **Three.js + MediaPipe + Web Audio** 的轻量版本。

---

## 1. 先澄清 Kimi、Krea 和 Kling

### Kimi：会理解视觉，但不是独立的高质量图片生成模型

- 官方入口：[Kimi](https://www.kimi.com/)
- 官方开放模型：[MoonshotAI/Kimi-K2.5](https://github.com/MoonshotAI/Kimi-K2.5)
- 官方 API 平台：[Moonshot AI Platform](https://platform.moonshot.ai/)

[Kimi K2.5 官方仓库](https://github.com/MoonshotAI/Kimi-K2.5)把它定义为 native multimodal agentic model，示例能力是输入图片或视频后理解、推理、写代码和调用工具；官方示例只展示 `image_url` / `video_url` 输入与文本输出，没有原生 image-output API。Kimi 产品帮助中心说明，K3 可以通过插件调用图片、音频或视频功能，但这不等于存在一个名为“Kimi Image”的、公开模型规格明确的图片基础模型。

因此：**Kimi 可以帮你分析参考图、写 prompt、规划工作流，不能把它直接当作这个舞台项目的核心图像生成引擎。**

### 你更可能想说的是 Krea

- 官方入口：[Krea](https://www.krea.ai/)
- 当前自研图片模型：[Krea 2](https://www.krea.ai/krea-2)
- 实时视频研究：[Krea Realtime 14B](https://www.krea.ai/blog/krea-realtime-14b)

Krea 2 强调审美多样性、风格参考、moodboard 和可调 creativity，对“梦境、记忆、非通用 AI 味”的方向很合适。Krea 还有 webcam / screen / canvas 驱动的 Realtime 产品；其公开研究写明 Krea Realtime 14B 可流式生成长视频，但官方 11 fps 数字来自单张 NVIDIA B200，属于云端数据中心级硬件，不能理解为普通笔记本本地就能达到。

### 如果你想到的是中文视频工具，也可能是 Kling

- 官方入口：[Kling AI](https://klingai.com/)

Kling 是视频生成产品，而 Kimi 是 Moonshot 的通用多模态助手。Kling 可用于预生成梦境视频段落，但和 Veo、Seedance、Runway 一样，不应在第一版中承担毫秒级、持续可靠的演员实时反馈。

---

## 2. GitHub 上到底有哪些“视觉 skills”

这里必须区分三种东西：

1. **真正的 Codex / Claude Agent Skill**：一份让 agent 知道如何调用工具、生成文件和验证结果的指令包。
2. **MCP 工具桥**：让 Codex/Claude 操作 ComfyUI、TouchDesigner、Blender、Unreal。
3. **普通开源项目 / workflow / custom node**：它们能生成或运行视觉，但不是装上就能由 Codex 自动使用的 skill。

### A. 可直接或接近直接给 Agent 使用

| 项目 | 类型 | 适合做什么 | 许可证 / 注意事项 | 判断 |
|---|---|---|---|---|
| [OpenAI imagegen skill](https://github.com/openai/skills/blob/main/skills/.system/imagegen/SKILL.md) | 官方 Codex skill | 生成/编辑高质量 2D 概念图、纹理、透明素材 | OpenAI 官方 skills；云端生成，非连续实时视频 | **当前最直接的 Codex 2D 视觉 skill** |
| [Comfy-Org/comfy-skills](https://github.com/Comfy-Org/comfy-skills) | Comfy 官方 Agent skills | 命令覆盖图片、视频、音频、3D 生成和模板搜索 | MIT；README 当前把 Claude Code 作为 canonical 集成，不能未经验证声称是 Codex 即插即用 | 能力很全，但 Codex 侧优先接下面的 MCP |
| [Comfy-Org/comfy-mcp](https://github.com/Comfy-Org/comfy-mcp) | Comfy 官方 MCP | 检查本地 ComfyUI、运行 JSON workflow、取回结果、搜索模板 | 本地需 Python ≥3.10、comfy-cli 和运行中的 ComfyUI；也有云端版本 | **Codex 驱动 ComfyUI 的可信入口** |
| [Pantani/tdmcp](https://github.com/Pantani/tdmcp) | 社区 TouchDesigner MCP，含 `.agents/skills` / `.codex` 支持 | 自然语言创建 audio-reactive、particle、feedback、OSC/MIDI/DMX/NDI、3D 网络并检查错误 | MIT；能执行 TD 内脚本，必须只绑定本机并限制 exec | **和你的舞台命题最贴近的社区自动化** |
| [8beeeaaat/touchdesigner-mcp](https://github.com/8beeeaaat/touchdesigner-mcp) | 社区 TouchDesigner MCP | 创建/删除节点、设参数、执行方法、截图 TOP、读取错误 | MIT；提供 `.codex` 与 agent skills，但仍需人工审核网络 | 更底层、更适合可控搭建与调试 |
| [ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) | 社区 Blender MCP | 场景、材质、灯光、相机、资产导入和 AI 3D 服务 | MIT；明确为第三方，不是 Blender 官方 | 适合舞美资产和空间预演，不适合现场 show control |
| [Epic Unreal Engine Skills](https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin) | Epic 官方 skill + MCP | Unreal 场景、Blueprint、材质、Niagara、Sequencer、Control Rig | skill repo 为 MIT；Unreal 本体仍受 Epic EULA | 第二阶段大型 3D / 虚拟制作 |

### B. 普通项目或工作流，不要误叫 Codex skill

| 项目 | 能力 | 许可证 | 实时性 / 硬件 | 用法 |
|---|---|---|---|---|
| [ComfyUI](https://github.com/Comfy-Org/ComfyUI) | 节点式图片、视频、3D、音频工作流与 API | GPL-3.0；模型和 custom node 各自另有条款 | 本地需求随模型变化 | 生成层主干 |
| [Comfy official workflow templates](https://github.com/Comfy-Org/workflow_templates) | 官方维护的可克隆模板 | MIT；模型另行授权 | 依模板而定 | 比从空白画布拼 workflow 稳定 |
| [ControlNet Auxiliary Preprocessors](https://github.com/Fannovel16/comfyui_controlnet_aux) | DWPose/OpenPose、MediaPipe face、Depth Anything、边缘、深度、分割 | Apache-2.0；下载的模型权重另查 | 预处理可实时或近实时，生成链速度另算 | 把演员姿态、轮廓变成生成条件 |
| [StreamDiffusion](https://github.com/cumulo-autumn/StreamDiffusion) | 实时交互 diffusion pipeline | Apache-2.0 | 官方 RTX 4090/Ubuntu：SD-Turbo 约 94 fps img2img，LCM-LoRA 约 37 fps；仅限其测试设置 | 实时“梦境化”探针，不是无条件现场保证 |
| [ComfyStream](https://github.com/livepeer/comfystream) | 把 ComfyUI workflow 接到 WebRTC/摄像头流 | MIT | 官方测试 Ubuntu + RTX 4090；workflow 输入输出有限制 | demo 可用，首场演出不宜作为唯一链路 |
| [TRELLIS.2](https://github.com/microsoft/TRELLIS.2) | 高保真 image-to-3D，PBR 材质，导出 GLB | MIT；部分依赖另行授权 | Linux、至少 24GB NVIDIA VRAM；官方 H100 上 512³ 约 3 秒 | 做 3D 梦境物件，不做实时演出 |
| [Hunyuan3D-2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) | image-to-shape + PBR texture | Tencent 社区许可，需逐条核验地域与用途 | shape 约 10GB，texture 约 21GB，完整约 29GB VRAM | 能力强但硬件/许可比 TRELLIS.2 麻烦 |
| [Three.js](https://github.com/mrdoob/three.js) | 浏览器 WebGL/WebGPU 3D、shader、粒子、fog、GLTF | MIT | 中小型场景一般消费级设备可运行 | 可分享网页原型基座 |
| [MediaPipe](https://github.com/google-ai-edge/mediapipe) | 姿态、手、脸、分割 | Apache-2.0；具体模型包再查 | 浏览器/本地实时 | 摄像头动作输入 |
| [MediaPipe for TouchDesigner](https://github.com/torinmb/mediapipe-touchdesigner) | TD 内的手、脸、pose、物体、分割 | MIT | Mac/Windows、离线、输入目前 720p；插件会报告检测延迟 | 演员动作最快接入方式 |

结论：GitHub 上不是没有 skills，而是**生成画面、实时运行和 agent 自动搭建是三层不同能力**。最可信的组合是 `OpenAI imagegen / Comfy skills + Comfy MCP + TouchDesigner MCP`，不是寻找一个“万能 dream-stage skill”。

---

## 3. 2026-09 当前一线视觉模型：按任务选，不做一个虚假的总冠军

### 静态图 / 舞台概念图

| 模型 | 官方链接 | 强项 | 是否适合本项目 | 开放程度 / 门槛 |
|---|---|---|---|---|
| **Midjourney V8.2** | [官方版本文档](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version) | 审美、氛围、个性化、style reference；官方称 V8.2 更 bold、sophisticated、edgy | **很适合第一轮梦境 moodboard** | 闭源 SaaS；不适合深度自动化或本地实时 |
| **Krea 2** | [官方模型页](https://www.krea.ai/krea-2) | 风格多样、moodboard、style transfer、可调 creativity，减少通用 AI look | **最贴“梦幻而私人”的视觉探索** | 云端；官方称已开放权重，具体权重与许可证按发布页核验 |
| **GPT Image 2** | [OpenAI 官方模型页](https://developers.openai.com/api/docs/models/gpt-image-2) | 指令遵循、精确编辑、高保真图像输入、复杂构图；API 明确 | **适合把同一梦境连续修改，而不是每次重抽卡** | 闭源 API；可被 Codex imagegen 直接使用 |
| **Nano Banana 2 / Gemini 3.1 Flash Image** | [Google 官方介绍](https://blog.google/innovation-and-ai/technology/ai/nano-banana-2/) | 快速迭代、参考一致性、编辑、知识与搜索 grounding | 适合快速做不同舞台构图和灯光版本 | 闭源 API / Gemini 产品；所有输出带 SynthID 来源标记 |
| **FLUX.2 [max/pro/flex]** | [BFL 官方文档](https://docs.bfl.ai/flux_2/flux2_overview) | 多参考、姿态与构图控制、精确颜色、摄影质感；不同变体覆盖质量/文字/速度 | 适合生产级 concept art 和参考一致性 | API；按变体收费 |
| **FLUX.2 [klein] 4B** | [同上](https://docs.bfl.ai/flux_2/flux2_overview) | 亚秒级、可本地、可 LoRA；4B 官方约 13GB VRAM | **本地近实时图像支路首选候选** | 4B 为 Apache-2.0；9B 是 FLUX Non-Commercial License |
| **Ideogram 4.0** | [官方产品页](https://ideogram.ai/) | 文字、图形设计、编辑稳定性 | 海报、标题、申请展示板有用；纯梦境氛围不是首选 | 闭源 SaaS/API |

我的实际建议：

- 想先“找到梦的样子”：**Krea 2 或 Midjourney V8.2**。
- 想围绕同一张绿桌椅/爷爷/阳光画面反复精修：**GPT Image 2 或 Nano Banana 2**。
- 想以后本地接 ComfyUI、训练专属梦境 LoRA、做近实时：**FLUX.2 Klein 4B**。

### 预生成视频 / 梦境循环

| 模型 | 官方链接 | 强项 | 舞台用法 |
|---|---|---|---|
| **Veo 3.1** | [Google DeepMind Veo](https://deepmind.google/models/veo/) | 高质量、原生音频、camera / motion controls、首尾帧、reference ingredients、1080p/4K | 预生成最重要的 3–5 段梦境镜头 |
| **Seedance 2.5** | [ByteDance 官方发布](https://seed.bytedance.com/en/blog/one-take-creation-flexible-referencing-introducing-seedance-2-5) | 最长 30 秒、可多轮延长、多模态参考与编辑 | 做长一点、能循环或衔接的舞台背景 |
| **Runway Gen-4.5** | [Runway 官方研究页](https://runwayml.com/research/introducing-runway-gen-4.5) | 电影化视频生成和创作者工作流 | 分镜、预演和短片素材 |
| **Kling** | [Kling 官方入口](https://klingai.com/) | 图生视频、运动和效果生成 | 作为预生成视频候选；先用自己的素材做 A/B 测试 |
| **LTX-2** | [Lightricks 官方 GitHub](https://github.com/Lightricks/LTX-Video) | 开放的音视频联合模型、keyframe、LoRA、ComfyUI 集成 | 本地/可控研究支路；高质量生成仍非舞台逐帧引擎 |

不要用厂商自己发布的 benchmark 宣称绝对“最好”。对你的项目，应拿同一组参考图、同一组梦境描述测试：

1. 绿色桌椅、午后阳光、人物记忆锚点是否保留；
2. 生成 8 个镜头后风格是否仍是一套世界；
3. 图生视频有没有把象征物变形；
4. 能不能做可循环、没有明显跳帧的 6–15 秒片段；
5. 导出分辨率和演出使用条款是否满足需求。

### 3D 资产 / 空间

| 工具 | 官方链接 | 强项 | 硬件与限制 | 判断 |
|---|---|---|---|---|
| **TRELLIS.2** | [Microsoft GitHub](https://github.com/microsoft/TRELLIS.2) | 单图转高分辨率 PBR GLB；开放表面、透明与复杂拓扑 | Linux + ≥24GB NVIDIA VRAM；官方 H100 性能不能外推到消费卡 | **少量标志性 3D 物件首选开源候选** |
| **Hunyuan3D-2.1** | [Tencent GitHub](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) | image-to-shape 与 production-ready PBR texture | 完整形状+纹理约 29GB VRAM；社区许可需核验地区与用途 | 能力强，实施门槛高 |
| **Hunyuan3D-Omni** | [Tencent GitHub](https://github.com/Tencent-Hunyuan/Hunyuan3D-Omni) | point cloud、voxel、skeleton、bounding box 控制 | 官方约 10GB VRAM，仅形状控制；许可另查 | 以后做“演员姿态变 3D 人形”研究可用 |
| **World Labs Marble** | [官方文档](https://docs.worldlabs.ai/marble/models) | 从提示/图像生成可游览的 3D 世界 | 闭源云服务、按 credits；输出与商用条件看账户条款 | 快速探索完整梦境空间，但可控性低于手工舞台 |
| **Blender MCP** | [GitHub](https://github.com/ahujasid/blender-mcp) | 让 agent 修改 Blender 场景、灯光、材质和资产 | Blender 本身免费；MCP 可执行 Python，需使用工程副本 | 把 AI 资产整理成真正舞台空间的中间层 |

对于原型，不要一开始生成“完整梦境宇宙”。先做：**绿色桌椅、窗/阳光、一个人物记忆符号、一个可投影平面、一个雾与粒子系统**。这已经足以验证空间是否会回应演员。

---

## 4. 最适合舞台空间、演员动作和声音实时驱动的工具

### 首选：TouchDesigner

- 官网：[Derivative TouchDesigner](https://derivative.ca/)
- 官方文档：[TouchDesigner User Guide](https://docs.derivative.ca/Main_Page)
- OSC 输入：[OSC In CHOP](https://docs.derivative.ca/OSC_In_CHOP)
- DMX 输出：[DMX Out CHOP](https://docs.derivative.ca/DMX_Out_CHOP)
- 许可证说明：[TouchDesigner Licensing](https://docs.derivative.ca/Licensing)

TouchDesigner 的优势不是“AI 画质最好”，而是能稳定处理实时图像、声音、OSC、MIDI、DMX、传感器、投影 mapping 和 GPU shader。免费 Non-Commercial 版仅限非商业且输出上限 1280×1280；一旦项目有报酬或商业用途，需要 Commercial/Pro。学生可查看 Educational 许可。

推荐输入映射：

| 演员信号 | 视觉参数 | 戏剧意义 |
|---|---|---|
| 身体中心 x / y | 梦境空间的视差与粒子吸引点 | 演员不是站在影像前，而是在“推移”空间 |
| 手掌张开度 | 记忆画面的显影 / 遮蔽 | 演员主动选择让记忆出现 |
| 身体速度 | feedback 拖尾长度、画面溶解 | 动作越快，梦越不稳定 |
| 麦克风 RMS | bloom、亮度、粒子数量 | 声音控制梦境强度 |
| spectral centroid | 色温、雾的锐利度 | 声音频谱改变氛围，而不只是音量 |
| 停顿时长 | 时间冻结、画面向旧版本回退 | 沉默也成为动作 |
| `freeze` | 锁定当前 frame / state | 演员保留诠释权 |
| `reject` | 丢弃当前 AI 变体，回安全画面 | 明确拒绝模型的输出 |
| `replay` | 回放最近一段视觉记忆 | 把舞台本身变成记忆装置 |
| `intensity` | 总体效果上限 | 演员可以调节 AI 介入程度 |

动作入口优先使用 [torinmb/mediapipe-touchdesigner](https://github.com/torinmb/mediapipe-touchdesigner)：它本地离线运行，支持 pose、手、脸、物体和分割。官方 README 说明目前输入上限为 720p，并提供 `detectTime`、`totalInToOutDelay`、`isRealTime` 等性能信号，正适合你做延迟和稳定性记录。

### 高保真 3D：Unreal Engine

- [Unreal Live Link](https://dev.epicgames.com/documentation/unreal-engine/live-link-in-unreal-engine)
- [Unreal DMX](https://dev.epicgames.com/documentation/en-us/unreal-engine/dmx-in-unreal-engine)

Live Link 能把动作捕捉/动画数据实时送入 Unreal，DMX 插件面向 live events 和永久装置。适合后期做 LED 墙、多投影、Niagara、MetaHuman、nDisplay，但首版会把大量时间耗在资产管线、Blueprint 和输出同步，因此不推荐作为第一个原型中枢。

### 可分享网页：Three.js + MediaPipe

- [Three.js](https://github.com/mrdoob/three.js)
- [MediaPipe Web Pose Landmarker](https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/web_js)
- [React Three Fiber](https://github.com/pmndrs/react-three-fiber)
- [GaussianSplats3D](https://github.com/mkkellogg/GaussianSplats3D)

MediaPipe Web 可以从摄像头输出 33 个 pose landmarks、3D world coordinates 和可选人物 segmentation mask；Three.js 可用 shader、bloom、fog、particles、GLTF 和 Web Audio 做一个招生老师能直接打开的互动网页。要把摄像头分析留在本地，并在页面上明确说明“不上传视频”。

---

## 5. 推荐原型方案

### 原型 A：最短路径，先证明你的研究问题（首选）

**目标**：证明“演员不是触发一个预设特效，而是在实时解释、接受或拒绝一个梦境空间”。

技术：

- 生成：Krea 2 / GPT Image 2 / Midjourney V8.2，做 8–12 张同一视觉语言的图；Veo / Seedance 做 3–5 条短循环。
- 编排：ComfyUI 保存 seed、参考图、prompt 和版本。
- 现场：TouchDesigner。
- 动作：MediaPipe TouchDesigner。
- 声音：Audio Device In → Analyze/FFT/RMS。
- 控制：键盘、MIDI 或四个大按钮实现 `freeze/reject/replay/intensity`。

最低硬件：Windows 电脑、NVIDIA 独显、普通 webcam、麦克风、显示器或投影仪。同机只播放预生成内容时，硬件压力远低于实时扩散；如果后续加 FLUX Klein / StreamDiffusion，建议独立测试 12–16GB 以上 VRAM，不能只看“模型能加载”。

验收不是“画面好看”，而是：

- 演员能在 10 秒内理解四个控制；
- 动作到画面主反馈的延迟不会破坏表演感；
- 追踪丢失时画面平滑冻结/回安全状态，不突然闪烁；
- 连续运行 45 分钟不崩；
- 观众能说出“演员改变了什么”，而不是只觉得屏幕在放 AI 视频。

### 原型 B：增加实时 AIGC，但必须可旁路

在原型 A 上加入：

```text
webcam / TD frame
      ↓
StreamDiffusion 或 FLUX.2 Klein 4B img2img
      ↓
Spout / NDI / WebRTC 回 TouchDesigner
      ↓
与预生成安全画面混合
```

必须加：

- 一键 bypass；
- 超过延迟阈值自动回预生成画面；
- 模型固定、workflow 固定、网络依赖清零或有明确降级；
- 演出前做端到端 latency、1% low fps 和 45–60 分钟 soak test。

实时扩散的 37–94 fps 是 StreamDiffusion 在 RTX 4090、512 级输入、特定 Turbo/LCM 模型和 TensorRT 条件下的官方测试，不代表高画质 1080p workflow 能达到同样速度。

### 原型 C：申请用网页版本

**Three.js + MediaPipe Pose + Web Audio + 预生成纹理 / GLB**。

这是展示价值很高的一条平行路线：招生委员会无需安装 TouchDesigner，打开链接、授权 webcam/麦克风，就能体验身体和声音如何改变梦境。提供 WebGL fallback 和一个无摄像头的鼠标/键盘 demo mode。

---

## 6. 画面怎样才真的“梦幻”，而不是常见 AI 风格

不要只写 `dreamy, surreal, cinematic`。先建立一个小型视觉语法：

### 不变的记忆锚点

- 绿色桌椅；
- 斜射的午后阳光；
- 爷爷存在但不一定清晰露面；
- 现实比例中有一处不可能的空间关系；
- 色板固定在 5–7 个颜色；
- 颗粒、镜头和材质保持一致。

### 可由演员改变的层

- 人物清晰度；
- 房间深度；
- 阳光方向；
- 物件是否漂浮或重复；
- 雾、残影、回声般的画面版本；
- 画面的时间方向。

### 实时效果层

- feedback trails；
- soft threshold + bloom；
- chromatic aberration 少量使用；
- volumetric / depth fog；
- 慢速 displacement；
- 粒子残影；
- 低频呼吸式明暗；
- segmentation mask 让影像只从演员身体边缘“渗出”。

这样做的好处是：生成模型负责“梦的素材”，实时引擎负责“梦怎样响应身体”。项目的原创性不再依赖某个平台抽中一张漂亮图。

---

## 7. 许可证、隐私与现场风险

- ComfyUI 主体是 GPL-3.0，但 custom nodes、模型、LoRA 和训练图片各有单独许可证。
- FLUX.2 Klein 4B 是 Apache-2.0；9B 是 FLUX Non-Commercial License，不能混为一谈。
- TouchDesigner Non-Commercial 仅限非商业、输出 1280×1280；有报酬的展演需 Commercial/Pro，学生项目可查 Educational。
- Hunyuan3D 系列使用 Tencent 社区许可。特别是 Hunyuan3D-2 的许可文本包含地域排除；如果使用者、学校或演出地点在 EU、UK、韩国，必须先做法律/机构核验。Hunyuan3D-2.1 也不要凭仓库名推定为 MIT。
- Unreal skill 仓库的 MIT 不等于 Unreal Engine 本体许可；引擎受 Epic EULA。
- MCP 常能在 TouchDesigner、Blender、Unreal 内执行 Python。只绑定 `127.0.0.1`，使用工程副本，限制任意执行工具，演出机不暴露到公共网络。
- 摄像头与麦克风数据默认本地处理；如果上传云端生成，必须向演员和观众说明，并取得适当同意。
- 现场 AI 的关键指标是端到端延迟、帧抖动、长时间稳定性和降级，不是供应商展示页的单帧画质。

---

## 8. 最终选型

| 层 | 推荐 | 为什么 | 暂不优先 |
|---|---|---|---|
| 梦境 moodboard | Krea 2 / Midjourney V8.2 | 审美、风格探索强 | 一开始训练自己的大模型 |
| 可控精修 | GPT Image 2 / Nano Banana 2 | 参考保持与局部编辑强 | 每次从纯文本重抽 |
| 可重复生成工作流 | ComfyUI + 官方模板 + Comfy MCP | seed、节点、输入、版本可记录 | 未审计的“万能 skill” |
| 本地近实时图像 | FLUX.2 Klein 4B / StreamDiffusion | 开放、速度路径清晰 | 把高质量云端视频模型当实时引擎 |
| 现场运行 | TouchDesigner | 动作、声音、投影、OSC/DMX 最直接 | 第一版上 Unreal/nDisplay |
| 动作追踪 | MediaPipe TouchDesigner | 免费、本地、摄像头即可 | 第一版买昂贵 mocap |
| 3D 资产 | TRELLIS.2 → BlenderMCP | PBR GLB、MIT、可进入多个运行时 | 一开始生成完整世界 |
| 网页作品集 | Three.js + MediaPipe + Web Audio | 打开链接就能体验 | 只交录屏 |

### 我会怎样开始

先做原型 A：**Krea 2 / GPT Image 2 生成风格素材 → TouchDesigner + MediaPipe + 音频分析 → 四个演员控制**。等它在演员身上真的成立，再加 StreamDiffusion；等空间关系成为项目核心，再引入 TRELLIS.2 / Blender / Unreal。

这个顺序保留了你项目最有研究价值的部分：不是“AI 能生成多漂亮的梦”，而是**演员能否与一个生成系统协商、拒绝并重新解释自己的记忆**。

---

## 主要一手来源

- [MoonshotAI/Kimi-K2.5](https://github.com/MoonshotAI/Kimi-K2.5)
- [Kimi 使用说明](https://www.kimi.com/en/help/new-user-guide/agentic-chat)
- [OpenAI GPT Image 2](https://developers.openai.com/api/docs/models/gpt-image-2)
- [Google Nano Banana 2](https://blog.google/innovation-and-ai/technology/ai/nano-banana-2/)
- [Krea 2](https://www.krea.ai/krea-2) 与 [Krea Realtime 14B](https://www.krea.ai/blog/krea-realtime-14b)
- [Midjourney model versions](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version)
- [Black Forest Labs FLUX.2](https://docs.bfl.ai/flux_2/flux2_overview)
- [Google DeepMind Veo](https://deepmind.google/models/veo/)
- [ByteDance Seedance 2.5](https://seed.bytedance.com/en/blog/one-take-creation-flexible-referencing-introducing-seedance-2-5)
- [Lightricks LTX-Video](https://github.com/Lightricks/LTX-Video)
- [ComfyUI](https://github.com/Comfy-Org/ComfyUI), [Comfy Skills](https://github.com/Comfy-Org/comfy-skills), [Comfy MCP](https://github.com/Comfy-Org/comfy-mcp), [official workflow templates](https://github.com/Comfy-Org/workflow_templates)
- [StreamDiffusion](https://github.com/cumulo-autumn/StreamDiffusion)
- [TouchDesigner docs](https://docs.derivative.ca/Main_Page), [OSC In](https://docs.derivative.ca/OSC_In_CHOP), [DMX Out](https://docs.derivative.ca/DMX_Out_CHOP), [licensing](https://docs.derivative.ca/Licensing)
- [MediaPipe for TouchDesigner](https://github.com/torinmb/mediapipe-touchdesigner)
- [MediaPipe Pose Landmarker for Web](https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/web_js)
- [Three.js](https://github.com/mrdoob/three.js)
- [Blender MCP](https://github.com/ahujasid/blender-mcp)
- [TRELLIS.2](https://github.com/microsoft/TRELLIS.2)
- [Hunyuan3D-2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1) 与 [Hunyuan3D-Omni](https://github.com/Tencent-Hunyuan/Hunyuan3D-Omni)
- [Unreal Live Link](https://dev.epicgames.com/documentation/unreal-engine/live-link-in-unreal-engine) 与 [Unreal DMX](https://dev.epicgames.com/documentation/en-us/unreal-engine/dmx-in-unreal-engine)

