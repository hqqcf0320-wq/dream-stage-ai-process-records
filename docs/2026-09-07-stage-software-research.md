# 《醒来之前》：建模、实时渲染与舞台软件研究

研究日期：2026-09-07。范围：官方文档与官方 API 的能力核验；没有安装软件、制作原型、申请账号或调用付费生成。以下“推荐/推断”是对本项目的技术判断，不是供应商性能保证。官方网页滚动更新，版本标签不代表所有插件已经相互兼容。

## 结论

建议将 **Blender 作为可编辑资产母版，Unreal 作为面向正式舞台的实时场景与排练主线，TouchDesigner 作为按需接入的传感器/影像映射桥梁**。暂不把 Houdini、Tripo、Meshy 都设成必需依赖。Three.js 可提供轻量查看/交互草样，但不因为它容易在当前电脑运行就让它决定整个舞台方向。

如果正式作品以真人姥爷、真实桌椅和投影为主，第一轮重点可以变为 **Blender 舞台空间预演 + TouchDesigner 投影互动试验**，不必先制作一个高精度数字姥爷。反之，若核心是虚拟房间不断旋转、退远、变形，以及数字角色动作可由现场改变，Unreal 主线更合理。

主任务只读检测到当前电脑约 15.7 GB RAM、Intel Iris Xe 集成显卡，暂未发现独显；这不是所有设备的全盘清单。应区分本机的资产编辑/轻量查看、学校或工作站的实时视觉运行、实际舞台的多路输出三种负载，不能把当前电脑当作整场演出的性能上限。具体预算需结合场地、投影分辨率、帧率与 GPU 实测，而不是先购买软件堆栈。

## 先区分三种工作

1. **建模与动画制作**：做青绿石板桌椅、红窗、小熊、角色，调整材质、骨骼和关键动作。Blender/Houdini/AI 3D 工具属于这一层。
2. **实时演出系统**：每一帧渲染、接收观众动作、保持金光和天气响应，控制进入下一段的时机。Unreal/Unity/TouchDesigner 属于这一层。
3. **AI 决策与创作辅助**：制作期间 AI 可以写脚本、操作软件、生成资产；演出期间 AI 可以解释新输入、选择可表演的变化、给演员建议。两者不能混为一谈。能用语言自动做一间房，不等于那间房已经能稳定支撑现场即兴。

Blender 的公开 Python API 包含对象、数据、动画和骨骼等操作入口，可被脚本调用；这支持制作自动化，但本身不证明任何特定聊天模型能一次做对。官方：[Blender Python API](https://docs.blender.org/api/current/)。

## 软件比较

| 软件 | 核验的能力 | 本项目适合放在哪里 | 不应预期它直接解决什么 |
|---|---|---|---|
| Blender | Python API、建模/骨骼动画工作流、glTF 和 USD 交换 | 桌椅红窗与小熊母版；镜头预演；预制照顾小熊的动作；可复用纹理 | 并非现成多人演出状态控制台；导出不会带走所有节点逻辑 |
| Houdini | 程序化资产，Houdini Engine 编辑器内 cook；点缓存可导给 Niagara | 特别复杂的裂纹生长、咖啡流体、群集/云等离线制作 | Houdini Engine for Unreal 官方明确不是运行时方案，不能默认观众每跺脚就现场重算复杂流体 |
| Unreal | Control Rig 可在 Sequencer 或 Animation Blueprint 中动画；DMX；nDisplay 多输出同步 | 主视觉、灯光、金光雨粒子、空间旋转、分段表演和数字角色；未来舞台输出 | 单机好看的电影镜头不证明现场多人各视点都成立；完整视频时间轴不等于可即兴 |
| Unity | VFX Graph 的粒子/网格/shader 参数，可由 C# 或 Timeline 触发事件 | 若已有 Unity 团队、学校现成部署或传感器项目，完全可作为主引擎 | 无需因 Unreal 宣传而重写；效果仍需资产、美术和调优 |
| TouchDesigner | CHOP 处理音频、运动、MIDI、OSC 等；Kantan Mapper/CamSchnappr 映射 | 把脚步/姿态/声音转成参数；排练控制；实物/地面投影校准 | 不是复杂角色穿衣动画的首选制作工具；增加一个引擎就增加一条集成链 |
| Tripo | 图文生成、rig-check、自动骨骼；支持多种体型类别；GLB/FBX 输出 | 熊、道具的视觉候选和基础网格 | 自动绑定不等于角色能够自然抱住另一件软物体、对齐手指、替它穿衣 |
| Meshy | 生成/重拓扑/纹理/骨骼/动画 API；标准人形绑定 | 快速候选资产、普通动作占位 | Rigging API 明确主要适合肢体清晰的标准双足模型；胖短肢毛绒熊需实测 |
| Spline | 交互场景、网页发布、3D 格式导出 | 快速可视故事板、非技术合作者调构图 | GLB 导出不保留 states/events/interactivity、物理、环境灯光雾和后处理；无法整套带走到舞台 |
| Three.js | GLTFLoader；WebGPURenderer 可使用 WebGPU，并回退 WebGL2 | 发给人打开就看的场景、事件模拟器、低分辨率草样 | 不应把浏览器试玩能运行视为现场投影、多机同步和专业灯光管线已解决 |

官方依据：[Houdini Unreal 插件](https://www.sidefx.com/products/houdini-engine/plug-ins/unreal-plug-in/)、[Houdini Niagara ROP](https://www.sidefx.com/docs/houdini/nodes/out/labs--niagara_rop.html)、[Control Rig 动画](https://dev.epicgames.com/documentation/unreal-engine/animating-with-control-rig-in-unreal-engine?lang=en-US)、[DMX](https://dev.epicgames.com/documentation/en-us/unreal-engine/dmx-in-unreal-engine)、[Unity VFX Graph](https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/index.html)、[TouchDesigner CHOP](https://derivative.ca/UserGuide/CHOP)、[投影映射](https://derivative.ca/UserGuide/Projection_Mapping)、[Tripo Auto Rig](https://developers.tripo3d.ai/en/docs/animations-rig)、[Meshy Rigging](https://docs.meshy.ai/en/api/rigging)、[Spline GLB 导出](https://docs.spline.design/exporting-your-scene/files/exporting-as-gtlf-glb)、[Three.js GLTFLoader](https://threejs.org/docs/pages/GLTFLoader.html)、[WebGPURenderer](https://threejs.org/docs/pages/WebGPURenderer.html)。

## 将这 12 个剧情动作翻译为制作任务

### 另外两条值得保留的路线：Cinema 4D 与 Notch

- **Cinema 4D**：MoGraph 以 Cloner、Effector、Fields 做程序动画，适合成群云朵、几何秩序、图形节奏和精致风格化场景。若合作者熟悉 C4D 或已有 Maxon 制作管线，它可替代 Blender 成为资产/视觉制作主工具。当前不将两者同时设成必需，因为它们在本阶段职责重叠；也不能把 C4D 里的程序运动直接视为现场观众可控制的成品。[Maxon MoGraph SDK 概览](https://developers.maxon.net/docs/cpp/2026_2_0/page_overview_mograph.html)、[Maxon 3D Motion Design](https://www.maxon.net/en/solutions/3d-motion-design)。
- **Notch**：这是面向实时演出内容的实际备选，而非另一个通用建模软件。官方 Notch Blocks 文档说明，可导出自包含内容，以暴露参数让兼容媒体服务器控制；也支持单独可执行文件。如果场地方使用支持 Notch 的媒体服务器、团队已有 Notch 操作员，它可能比自行搭 UE 与媒体服务器桥梁更合适。当前不首选的原因是尚未确认媒体服务器/操作员，也尚未知道作品更偏视觉效果还是复杂可变剧情；这不是判断 Notch 做不了。[Notch Blocks 手册](https://manual.notch.one/2026.1/en/docs/workflows/working-with-media-servers/blocks/)。

| 画面 | 初步实现建议（推断） | 原型应验证的真正问题 |
|---|---|---|
| 黑色无边，绿椅上的人 | 三维黑场预演；实际舞台用遮光、黑幕、演员独立布光 | 实际空间会不会被反射/投影黑位暴露？不同观众能否看见同一个背影？ |
| 跺脚长金色裂纹 | 保留每次事件位置/时间；用曲线/网格遮罩或粒子生长 | 能否明确看见“这一条来自我”，而非只有全场亮度变化？ |
| 多人金光铺满地面 | 每人局部痕迹汇聚为共用路径；程序实时控制，不必 LLM | 人多后是否互相覆盖？安静参与者是否仍能留下痕迹？ |
| 太阳雨与房间出现 | 预制红窗和青绿桌椅；逐步显现材质，雨/光做实时参数 | 暖感是否真实可见？脚步与雨的因果是否容易学会？ |
| 姥爷半转身 | 真人排练或预制转身动作片段 | 认出的瞬间是否清楚，同时保持“他看不到我”的设定？ |
| 靠近就旋转退远 | 同一房间层级整体变换，允许停顿；空间透视在不同站位测试 | 是理解为“进不去”，还是只有镜头晃动？实体演员如何保持位置可信？ |
| 大熊出现与交换 | 原型先用显现/道具台占位；升降机械属于后续场地工程 | 观众是否理解交换的因果，而非追逐后随机刷新一个道具？ |
| 小熊晃动，姥爷抱起摸脸穿衣 | 可触发、可暂停、可衔接的短片段；真人优先排练细节 | 玩家式动画是否破坏照顾的情感？真人能否等待观众而不显僵硬？ |

建议首个视觉原型就保留材质、阳光、声音和尺度，而非只有方块状态机；同时不要把“复杂穿衣布料模拟”设成第一个必须解决的工程瓶颈。

## 角色：真人、数字人、录像是不同分支

- **最终真人演姥爷**：数字预演可用低精度替身检查背影与空间；抱熊、理袖口、停顿应先以真人试演验证。AI 给演员提示或让场景承接演员动作，不必替代他。
- **最终数字人**：可先制作坐姿、半转身、接熊、摸脸、穿衣、停留等片段，在片段间以参数/状态衔接。Control Rig 官方支持 Sequencer 与程序动画；但双角色接触、衣袖穿过熊手臂仍需专门资产和动作校对，不能用“有骨骼”推导“可完成任意动作”。
- **最终录像/投影演员**：可保留真人动作质感，变化范围受拍摄素材和衔接点限制。必须尽早承认这个限制，避免承诺任意姿态实时即兴。

该选择会显著改变预算与软件路线。研究期间用户已确认“真人演员，数字空间围绕他变化”，因此采用真人路线；以上数字人/录像分支仅作比较，不再是待决定事项。真人路线不等于低技术，数字人路线也不天然更具共振。

## 交换格式与可复用的边界

资产文件能迁移，整个作品的行为不能自动迁移。

- **glTF/GLB**：适合可携带网格、PBR 纹理及所支持的动画。Blender 的导出器对材质节点有指定映射，不能假定程序材质、几何节点动画、粒子模拟与互动逻辑原样保留。当前文档搜索可检索到 Geometry Nodes 实例导出支持，所以也不应反过来声称“几何节点一概不能导出”；要区分静态实例与任意运行时算法。[Blender glTF 手册](https://docs.blender.org/manual/en/5.1/addons/import_export/scene_gltf2.html)。本次搜索取得正文摘要，但直接打开部分 Blender 手册遇到抓取错误，具体高级选项应在锁定版本后再实测。
- **FBX**：角色骨骼/动作及基本材质的常见交换路径。Epic 文档说明导入管线使用 FBX 2020.2，能转换基本材质和纹理；不要承诺复杂着色器一致。[Epic FBX Material Pipeline](https://dev.epicgames.com/documentation/en-us/unreal-engine/fbx-material-pipeline-in-unreal-engine)。
- **USD**：适合更完整场景协作，但仍需对应应用对 USD Preview Surface/MaterialX 等支持；不是无损携带任意 Blender/Unreal 节点图的保证。[Blender USD 手册](https://docs.blender.org/manual/id/5.1/files/import_export/usd.html)。
- **Houdini 缓存**：Niagara ROP 输出静态/动画点缓存，供运行时采样；这与运行时重新求解同一流体不同。[Niagara ROP](https://www.sidefx.com/docs/houdini/nodes/out/labs--niagara_rop.html)。
- **Spline**：官方明确 GLB 只导出部分材质和位置/旋转/缩放 timeline；状态、事件、交互、灯光、雾和后处理不保留。[Spline 导出限制](https://docs.spline.design/exporting-your-scene/files/exporting-as-gtlf-glb)。

推荐保留 `.blend` 等可编辑母版，另出纹理、动画片段和目标引擎版本；金光/天气/剧情转换的语义参数独立于具体软件，例如脚步事件、参与者轨迹、雨量、风向、段落、演员放行，而不把行为埋死在渲染器中。

## 从电脑屏幕到不戴 VR 的真实舞台

Unreal nDisplay 能在多台电脑与多块屏幕/投影之间同步，并按显示面位置设置视锥；官方明确每个输出对应的视口共享视点来源。由此推断：**同步多面画面不等于每个观众同时获得各自透视正确的三维窗口。**旋转房间必须测侧面观众、离中心较远观众的体验。[nDisplay Overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/ndisplay-overview-for-unreal-engine)。

TouchDesigner 的投影工具能够把图像映射到轮廓/实物，CamSchnappr 支持模型与实物对齐及多投影融合。工具能力不能代替现场标定、遮挡处理和灯光协调。[Projection Mapping](https://derivative.ca/UserGuide/Projection_Mapping)。

本项目特别需要先验证：多人身体是否挡住脚下裂纹，演员面光是否冲淡投影，真实绿椅是否在虚拟房间退远时暴露空间矛盾。可把退远设计成窗外/房间外壳的运动，让真人与真实椅子作为稳定锚；是否成立需要场地试验。这是制作方案，不是已验证效果。

## 改判条件与成本

当前推荐并非固定软件名单：

1. 若学校已有成熟 Unity 工作流和技术支持，优先复用它；不要为 Unreal 再付一轮集成成本。
2. 若最终主要为真人与二维投影，TD 主线可能比 UE+TD 双引擎更省工作。
3. 若咖啡/云/裂纹复杂度成为真实视觉瓶颈，再引入 Houdini；此前保留预制和实时参数方案。
4. 若 AI 生成熊经过重拓扑、材质和动作校验仍比手工更慢，直接回到 Blender 手工建模；桌椅红窗这类几何明确的资产尤其不必强求生成式 AI。
5. 若只需向合作者分享交互因果，可出 Three.js 查看版；其验收不应替代舞台/工作站测试。

成本主要由角色接触动画、现场多投影校准、实时硬件、追踪遮挡、演员排练以及跨软件维护决定。本轮不报未经核验的订阅价格、工作小时或承诺性能。正式决定前应锁定一个代表性场景，在目标设备上测试，而不是先买齐软件。

## 思维痕迹

- 编辑与运行分离：若只看 Houdini/AI 的炫目演示，会把制作生成误当现场实时生成；核验后选择离线资产/缓存与现场参数响应分开。
- 资产可迁移不等于体验可迁移：若只看 GLB 支持，会默认 Spline 成品能搬进舞台；核验导出限制后把它限制为草样/故事板，保留可编辑母版和独立事件语义。
- 瓶颈判断：若把数字化完整度作为目标，会先攻布料穿衣和逼真人脸；考虑最终真人舞台后，先验证观众动作被认出、房间距离和熊的共振，角色精细制作按最终媒介决定。

残余不确定性：场地投影/屏幕布局、可用工作站和现场技术支持、人数与追踪方式、观众是否能理解交换，都需要后续具体试验。演员已确认真人。官方文档证明能力入口，不证明这部作品已经达到艺术效果。
