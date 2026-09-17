# 梦境舞台：可玩电脑原型与未来沉浸式演进路线

> 研究日期：2026-09-01。事实性能力说明仅采用官方文档、官方代码仓库、W3C 规范、作者/大学研究仓储中的原始研究。带“设计判断”的部分是基于这些材料对本项目作出的综合建议，不是来源原文。

## 结论先行

第一版不应把目标定义为“做一个漂亮的 3D 场景”，而应定义为：

> **做一个 6–8 分钟、可独立完成、可被录屏展示的第一人称梦境体验；玩家暂时扮演演员，用身体控制的替代输入改变整个梦境，而场景同时留下只属于该玩家的感知痕迹。**

当前最佳实现不是先上 TouchDesigner 或 Unreal，而是：

- **Three.js + 自定义 shader/post-processing**：做网页 3D、梦境变形和可分享版本；
- **Web Audio / Three.js PositionalAudio**：让记忆声音真正存在于空间中，而不是背景音乐；
- **键盘、鼠标、Gamepad**：现在模拟未来的身体、呼吸、声音和否决动作；
- **状态机 + 事件日志**：保存 `freeze / reject / replay / intensity`，未来把输入源换成摄像头、麦克风、OSC 或 VR 控制器时不改作品语法；
- **WebXR 作为同一个项目的展示模式，而不是另做一套 VR 项目**。

视觉上不要依赖“每帧调用 AIGC”。第一版应把高质量生成图像作为记忆纹理、远景、门后世界和粒子源，再用实时 3D、灯光、位移、雾、残影、空间声和交互把它们变成活的舞台。这样既保留 AIGC 的画质，也有游戏必须具备的响应性和可控性。

## 1. 为什么第一版选择 Web 3D

### 1.1 它已经覆盖本项目的核心技术

Three.js 的 `WebXRManager` 是对 WebXR Device API 的抽象，可启用 XR、取得控制器并设置参考空间；官方 VR 流程只需要加入 `VRButton`、启用 `renderer.xr.enabled`，并把普通动画循环换成 `renderer.setAnimationLoop()`。这意味着桌面第一人称版本与未来 VR 版本可以共用场景、交互对象和大部分状态逻辑。[Three.js WebXRManager](https://threejs.org/docs/pages/WebXRManager.html) · [Three.js VR 指南](https://threejs.org/manual/en/how-to-create-vr-content.html)

桌面行走可直接采用 Three.js 官方 `PointerLockControls`，其文档明确定位于第一人称 3D 游戏；因此无须先引入完整游戏引擎才能获得鼠标锁定和第一人称视角。[PointerLockControls](https://threejs.org/docs/pages/PointerLockControls.html)

W3C WebXR 规范将模式区分为 `inline`、`immersive-vr` 和 `immersive-ar`。沉浸式会话需要安全上下文、设备/浏览器支持和用户主动触发，正式实现必须先用 `isSessionSupported()` 检测，再在用户点击后请求会话。这决定了第一版必须始终保留可完整游玩的桌面模式，而不能把 VR 当作唯一入口。[W3C WebXR Device API](https://www.w3.org/TR/webxr/)

Web Audio 的 `PannerNode` 与单一 `AudioListener` 可以按声源与听者的三维位置、朝向、距离模型及方向锥进行空间化；Three.js 的 `PositionalAudio` 封装了同一机制并可直接挂到场景物体上。因此“只有走到绿色桌椅附近，爷爷的声音才从某个方向出现”可在浏览器内完成。[W3C Web Audio](https://www.w3.org/TR/webaudio-1.0/#PannerNode) · [Three.js PositionalAudio](https://threejs.org/docs/pages/PositionalAudio.html)

Three.js 官方后处理链提供 `EffectComposer` 与多个 pass；官方代码和文档已有 bloom、afterimage、色差、景深、film grain 等基础。对梦境而言，真正有用的是“低剂量、受状态驱动”的 bloom、afterimage、色偏和景深，而不是把所有效果永久开满。[Three.js 后处理指南](https://threejs.org/manual/en/post-processing.html) · [官方 Unreal Bloom 示例](https://threejs.org/examples/webgl_postprocessing_unreal_bloom.html) · [AfterImageNode](https://threejs.org/docs/pages/AfterImageNode.html)

### 1.2 它最适合申请展示

浏览器原型的优势不是绝对画质最高，而是评审可点开链接、用鼠标键盘完成体验、看见交互后果，也能在有头显时进入 WebXR。第一阶段的瓶颈是作品的交互命题是否成立，而不是渲染引擎上限。

## 2. 原型不应是“逛场景”，而应是一段有弧线的演出

建议做成一段 **6–8 分钟、三幕式、单次可完成** 的 playable performance：

1. **召回（Recall）**：空间几乎是黑的。玩家跟随一束斜阳和遥远椅子摩擦声前进；靠近绿色桌椅后，记忆逐步显影。
2. **失真（Distortion）**：桌椅数量、房间尺度、方向与声音开始不可靠。玩家的“强度”越高，图像越明亮但越不稳定；此时出现第一次 `reject`。
3. **留下或放手（Keep / Release）**：玩家必须选择冻结一个片段，拒绝一个片段，并回放自己此前留下的轨迹。结尾不是胜负，而是一幅由本次选择生成的“记忆切片”。

这比传统任务清单更接近舞台：系统提供节奏与约束，玩家的动作决定每晚具体怎样发生。结束时生成可截图的唯一画面和一条简短事件序列，既便于作品集展示，也证明互动不只是装饰。

## 3. 当前没有摄像头和麦克风时，最推荐的输入映射

输入不应按“游戏功能”随便绑定，而应模拟未来的表演信号。核心规则是：**每一个临时输入都要有明确的未来传感器替代物。**

| 当前输入 | 体验中的动作 | 现在驱动的参数 | 未来替代输入 |
|---|---|---|---|
| `WASD` | 身体在舞台中的位移 | 玩家位置、雾场扰动、靠近触发、脚步轨迹 | 姿态/空间追踪的身体质心与速度 |
| 鼠标移动 | 凝视/注意 | 第一人称相机、声场听者朝向、被注视物的显影 | HMD 头部姿态或 gaze |
| 按住 `Space`，松开 | 吸气—蓄积—呼气 | `intensity` 包络；光、颗粒、声压随按压时长上升，松开缓慢回落 | 麦克风呼吸/音量包络 |
| `Shift` + 移动 | 冲动/高能动作 | 速度峰值、残影长度、世界不稳定度 | 身体速度/加速度峰值 |
| `Q` | `freeze` | 锁定当前梦境构图与声场 2–4 秒，同时写入快照 | 演员预设手势或舞台控制器 |
| `E` | `reject` | 当前记忆物件碎裂/退场，系统切换到另一变体；不是简单删除 | 手势、语音词或脚踏开关 |
| `R` | `replay` | 回放最近 5–8 秒的玩家轨迹与世界状态，玩家仍可在其中移动 | 手势/语音/导演控制 |
| `F` | 触碰/接受 | 只对近距离记忆锚点生效，建立“个人痕迹” | 手部追踪或 VR controller |
| `1–3` | 选择记忆声部 | 绿桌椅 / 阳光 / 人的缺席，不直接切换整张场景 | 演员控制面板的 cue |
| `Esc` | 安全退出/暂停 | 暂停运动、降低声音、显示退出 | VR 按钮、舞台 kill switch |

如接手柄，推荐左摇杆=身体位移，右摇杆=注意方向，右扳机的连续值=`intensity`，肩键=`freeze/reject`，面键=`replay/touch`。Gamepad API 能在动画循环里读取最新轴与按钮状态，适合把“强度”从二元按键升级为连续表演量。[MDN Gamepad API](https://developer.mozilla.org/en-US/docs/Web/API/Gamepad_API/Using_the_Gamepad_API)

### 输入设计的两个硬约束

- `freeze / reject / replay` 必须在 150–250 ms 内先给出视觉或声音确认；复杂变形可以继续展开，但不能让玩家怀疑输入是否生效。
- `intensity` 不能等于“画面越亮越好”。它至少同时控制一个吸引项和一个代价项，例如光更强、记忆更清楚，但空间也更破碎；这样输入才是表达选择，不是效果旋钮。

## 4. 演员控制与观众独特视角：从第一天就分开状态

建议把系统状态拆成四层：

```text
Authored invariants（作者不可被破坏的节奏/安全边界）
        ↓
Shared stage state（演员控制：冻结、拒绝、强度、当前记忆）
        ↓
Personal perception state（每位观众：相机、走过的路、听到的声源、个人痕迹）
        ↓
Event log（谁在何时做了什么，可回放、解释、恢复）
```

第一版只有一个玩家，也应按照这个结构实现。玩家暂时同时承担“演员输入”和“观众视角”，但代码中两类动作不要混在同一个对象里。未来才能做到：演员改变所有人共享的天气和舞台，而 A 观众因靠近桌子听见一段声音，B 观众因停在门口看见另一层记忆。

### 单台电脑能做到什么、不能做到什么

- **一个屏幕可做两种不同视角，但不能做两个私密视角。** Three.js 可用多个 camera 加 scissor/viewport 将同一场景从两个机位渲染到一个画布；适合“玩家第一人称 + 舞台/导演观察窗”或双人 split-screen。[Three.js 多相机指南](https://threejs.org/manual/en/cameras.html) · [WebGLRenderer scissor](https://threejs.org/docs/pages/WebGLRenderer.html#setScissor)
- **真正独一无二且彼此不可见的体验，需要独立显示设备。** 最低成本路线是同一台笔记本运行本地服务，每位观众用自己的手机/平板浏览器进入；每台设备渲染自己的 camera 和个人声场，服务端只同步共享舞台状态。
- **多个 VR 头显也应视为多个客户端。** 一台电脑渲染多台头显会迅速受接口、性能和运行时限制；更稳妥的是每个头显/设备运行一个客户端，共享一个权威状态服务。

### 多设备版本的推荐网络模型

先使用 WebSocket 的房间模型；当确实需要游戏式状态同步、重连、插值和服务端权威时，用 Colyseus。其官方文档明确提供 authoritative game server、房间、二进制增量状态同步、预测/插值与 Web/Unity 等 SDK，且有 Three.js 示例。这比一开始自行设计点对点协议更合适。[Colyseus 官方文档](https://docs.colyseus.io/) · [官方 GitHub](https://github.com/colyseus/colyseus)

推荐的消息边界：

- 服务端权威：当前幕、演员 cue、全局 intensity、共享物件状态、时间轴；
- 客户端私有：相机姿态、个人已发现内容、个人声场混音、辅助功能设置；
- 上行事件：观众触碰/选择；服务端决定它是否改变共享世界；
- 事件日志：保留 cue、状态版本与来源，支持 `replay` 和现场恢复。

WebRTC `RTCDataChannel` 可以点对点双向传输任意数据，但仍需要信令与连接管理；第一版小型局域网体验没有必要为“少一个服务器中转”付出这份复杂度。[MDN RTCDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)

## 5. 观众 agency：技术之外的舞台设计原则

### 5.0 两个最接近本项目的一手机构案例

Royal Shakespeare Company 的《Dream》把现场动捕演员、Unreal 虚拟森林和网页观众端结合在同一场演出中；RSC 官方资料称，最多 2,000 名远程观众在关键节点以鼠标、触控板或触屏影响虚拟世界，演员实时回应，演员动作也参与操控音乐。这证明“演员掌控共享世界、网页观众在有限节点介入”不是概念拼贴，而是已经被大型剧场机构实际演出的结构。[RSC《Dream》官方案例](https://www.rsc.org.uk/press/releases/live-performance-and-gaming-technology-come-together-to-explore-the-future-for-audiences-and-live-theatre)

MIT Media Lab 与 Punchdrunk 的 Remote Theatrical Immersion 研究则指出，简单传输现场影像会限制远程参与者的 agency；其实验让线上与现场参与者拥有不同叙事线索、需要互相依赖才能拼合意义，并刻意避免把体验过度做成目标导向的游戏。对本项目的启示是：借用游戏的具身移动、空间探索和即时反馈，但不要把梦境变成任务闯关或积分系统。[MIT Media Lab 项目原页](https://www.media.mit.edu/projects/remote-theatrical-immersion-extending-sleep-no-more/overview/) · [项目研究者原始博士论文](https://web.media.mit.edu/~patorpey/publications/torpey_phd-thesis_2013_media_scores.pdf)

### 5.1 行为多不等于感到有控制权

《The Justice Syndicate》的实践研究发现，机器发出参与邀请、且不把人分为“观众”和“参与者”，能降低尴尬并增加 agentive behaviour；但行为强度提高并不自动带来更强的主观 agency。对本项目的直接含义是：不要用大量可点物件伪装互动，至少让一次选择改变后续世界、一次选择只改变个人视角，并让玩家能分辨二者。[作者所在大学的研究记录与开放稿](https://researchportal.lsbu.ac.uk/en/publications/the-justice-syndicate-using-ipads-to-increase-the-intensity-of-pa-3/)（DOI: 10.1080/14794713.2020.1722916）

### 5.2 先教会空间规则，再故意破坏它

对《Sleep No More》的环境—行为研究指出，人会依赖既有的 place schema 来预测在一个空间里应如何行动；沉浸式空间与传统“剧场 schema”不一致时，观众必须更新规则。原型第一幕应以无文字、低风险方式让人学会：靠近会显影、注视会聚焦、按住会增加强度；第二幕再让同一个规则失灵或反转。这样“梦境失真”来自玩家已经学会的预期被打破，而不是单纯迷路。[Glasgow School of Art 研究仓储](https://radar.gsa.ac.uk/10200/)（DOI: 10.1080/14682761.2023.2185928）

### 5.3 给选择设边界，不把全部责任甩给观众

Adam Alston 对沉浸式剧场的批评指出，看似自由的参与常把风险承担、寻找机会与“玩得好”的责任转给观众。设计上应避免只有最敢闯、最熟悉游戏的人才能获得核心内容：主线记忆必须可达，隐藏内容可以奖励探索；提供“跟随光线”的温和引导、暂停和退出；`reject` 不能造成无法理解且不可恢复的永久损失。[University of Surrey 开放研究记录](https://openresearch.surrey.ac.uk/esploro/outputs/journalArticle/Audience-Participation-and-Neoliberal-Value-Risk/99516312302346)（DOI: 10.1080/13528165.2013.807177）

### 5.4 进入和离开本身也是演出

基于三年观众研究的 VR onboarding/offboarding 框架强调，应显式定义体验目标、技术 affordance、用户 agency 与风险，并训练引导人员、监测体验；忽略进出 VR 的过渡会带来迷向、过载、晕动和情绪风险。即使桌面版，也应有 20–30 秒“校准/学会呼吸”的进入段和一个把声音、亮度、运动逐渐还给现实的退出段，而不是菜单后突然开场、黑屏后突然结束。[原始研究论文](https://journals.sagepub.com/doi/10.1177/13548565231187329)

### 5.5 每个观众可以缺失内容，但不能失去意义

“独一无二视角”不应等于随机删减。每位观众都要经历同一个情感骨架（召回—失真—留下/放手），但通过不同位置、注视、停留时间和选择获得不同证据、声音与最终记忆切片。独特性放在感知层，叙事可理解性由共同节奏保证。

## 6. 视觉与声音的具体生成方案

### 6.1 不追求完整写实房间，建立三类资产

1. **记忆锚点**：绿色桌椅、窗、阳光中的尘、空椅等少量可识别 3D 物件；
2. **生成表皮**：AIGC 图片作为天空盒/远景、半透明幕、投影纹理、粒子颜色源和 transition mask；
3. **实时场**：雾、光束、粒子、变形地面、残影、空间声音，完全由玩家状态驱动。

梦幻感来自“熟悉物件 + 不可能的空间关系 + 对动作有记忆的介质”，而不是堆砌模糊滤镜。

### 6.2 建议的实时视觉映射

- `movement speed` → 粒子尾迹、布景轻微位移、脚步音密度；
- `gaze duration` → 局部清晰度提高，外围仍保持雾化；
- `intensity` → 阳光体积感、bloom、低频声压上升，同时几何偏移增加；
- `freeze` → 世界动画停止但粒子极慢漂浮，声音只保留一个近距离呼吸层；
- `reject` → 当前锚点先反向聚拢再碎裂，避免像普通删除；
- `replay` → 过去轨迹以半透明“替身”重走，空间声音也按旧位置回放。

空间声至少放置 3 个声源：桌椅摩擦（物体源）、窗外环境（大范围/方向源）、人的记忆（移动或不可见点源）。声音应承担导航与叙事，而不是只作氛围。

## 7. 何时升级 TouchDesigner，何时升级 Unreal

### 7.1 升级 TouchDesigner 的触发条件

当目标从“电脑上可玩的作品集原型”变成“真实空间里的现场演出”并出现以下任意两项时再上 TouchDesigner：

- 两台以上投影机、异形表面或投影映射；
- 需要 OSC/MIDI/DMX、灯光台、传感器或舞台 cue 的快速接线；
- 需要演出者/技术员实时调参和旁路；
- 需要为持续运行优化独立输出窗口。

TouchDesigner 官方文档显示它原生通过 OSC In/Out CHOP/DAT 交换控制数据，WebSocket DAT 可与网页双向通信，Perform Mode 则为现场输出优化且只渲染指定窗口。这适合让 Web 游戏继续负责状态和观众客户端，TouchDesigner负责投影、灯光和现场视觉，不必重写全部作品。[TouchDesigner OSC](https://docs.derivative.ca/OSC) · [WebSocket DAT](https://docs.derivative.ca/WebSocket_DAT) · [Perform Mode](https://docs.derivative.ca/Perform_Mode)

推荐未来桥接：

```text
Actor sensors → input adapter → shared stage state / event log
                                    ├→ Web audience clients / WebXR
                                    └→ OSC or WebSocket → TouchDesigner → projectors / DMX
```

### 7.2 升级 Unreal 的触发条件

当以下要求成为核心而不是“以后可能”时再迁移/并行开发 Unreal：

- 原生高端 VR、复杂物理交互、重型 3D 资产和持续 90fps 性能优化；
- 权威服务器多人体验成为产品主体；
- 多机同步投影、LED/CAVE、视锥校准或专业跟踪；
- 已有技术美术/Unreal 工程能力，且评审不再需要零安装网页入口。

Epic 的官方 VR Template 已提供移动、抓取、OpenXR 起点和 spectator screen；其 networking framework 采用服务端权威、客户端重建画面；nDisplay 可在多机上同步多个显示/投影视口，并接受跟踪输入。能力很强，但这些正是第二、三阶段问题，不是当前验证互动命题的最低成本工具。[Unreal VR Template](https://dev.epicgames.com/documentation/unreal-engine/vr-template-in-unreal-engine) · [Unreal Networking Overview](https://dev.epicgames.com/documentation/unreal-engine/networking-overview-for-unreal-engine) · [nDisplay Overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/ndisplay-overview-for-unreal-engine)

尤其不要把单实例 Unreal Pixel Streaming 误当成多观众独特视角。Epic 官方入门文档说明，默认多人连接到同一实例时看到相同画面且可共享控制；真正独立的视点需要不同客户端/实例或真正的多人网络架构。[Epic Pixel Streaming 入门](https://dev.epicgames.com/documentation/unreal-engine/getting-started-with-pixel-streaming-in-unreal-engine)

## 8. 推荐演进路径与验收门槛

### Phase 1 — 桌面可玩垂直切片（现在）

技术：Three.js、Web Audio、键鼠/手柄、单人、本地事件日志。

交付：一段 6–8 分钟体验；三幕；至少一次 `freeze/reject/replay`；结尾生成本次唯一记忆切片；可直接用浏览器打开或部署。

验收：5 位第一次接触的测试者中，至少 4 位不用口头解释即可完成；至少 3 位能说出自己的动作改变了什么，而不只是“画面很好看”。

### Phase 2 — 双角色证明

技术：仍在单机；加入“演员控制台 + 观众第一人称”双视图，或两只手柄；严格区分共享状态与个人状态。

验收：演员执行 cue 时观众都看到全局变化；观众个人探索不会意外改写全局；完整 event log 可回放。

### Phase 3 — 局域网多观众

技术：本地 Node/Colyseus；笔记本为权威服务端，手机/平板为 2–4 个独立观众客户端；每人独立 camera、耳机和个人记忆层。

验收：每人最后得到不同的记忆切片，但都能复述同一情感主线；客户端掉线重连不会破坏全局演出。

### Phase 4 — 真实演员输入

先替换输入适配器，不改世界状态机：

- 摄像头姿态 → position / speed / gesture cue；
- 麦克风 → breath envelope / pitch / silence；
- 始终保留键盘/手柄作为校准与 kill-switch；
- 原始视频/音频默认不上传、不长期保存，事件日志只留必要特征与 cue。

验收：传感器失败时可在一次 cue 内切回手动；演员能够明确拒绝、冻结和回放，而不是被模型“猜测意图”绑架。

### Phase 5 — WebXR / 现场舞台

两条支路可以并行：

- WebXR：同一个网页项目进入头显，每位观众独立视角与空间声；
- TouchDesigner：把 shared stage state 送到真实投影/灯光，Web 客户端继续承担个人视角；
- 只有在项目确实需要专业原生 XR、复杂物理或 nDisplay 时，才启动 Unreal 迁移。

## 9. 现在应调用的能力组合

如果目标是直接生成下一版，而不是继续比较工具，最小组合是：

1. **原型/网站构建能力**：把当前平面效果重构为 Three.js 第一人称可玩垂直切片；
2. **图像生成能力**：生成统一视觉语法的绿桌椅、窗、尘埃、缺席人物等纹理/远景资产；
3. **浏览器测试能力**：真实跑通键鼠、声音解锁、全屏、性能、移动端和未来 WebXR 入口；
4. **可选 3D 资产能力**：只为少数记忆锚点生成/建模，不把整部作品变成资产生产项目。

现阶段不需要一个“自动生成完整梦境游戏”的万能 skill。最关键的是由原型构建能力掌控交互状态机，由图像生成提供视觉原料，再以浏览器测试闭环。生成模型负责梦的表皮，实时引擎负责梦如何回应人。

## 10. 最容易失败的三种做法

1. **把自由移动误认为 agency**：可以四处走，但无论做什么世界都一样；修复方式是为关键动作设计可观察、持久且可回放的后果。
2. **一开始就做多人 VR/真实舞台**：同时引入硬件、网络、追踪与内容风险，导致无法判断失败来自概念还是系统；先用替代输入验证作品语法。
3. **画质目标压过舞台关系**：生成图很美，但演员无法拒绝、观众没有独特感知、系统也不记得发生过什么；应把状态分层和事件日志视为作品的一部分，而非后端细节。

## 一句话技术决策

> **现在用 Three.js 做一段“演员式输入驱动的第一人称梦境游戏”，用 Web Audio 建空间叙事，把全局舞台状态与个人感知状态分开并记录事件；随后先加局域网多客户端，再替换成真实传感器，最后才根据展示场景接 WebXR、TouchDesigner 或 Unreal。**
