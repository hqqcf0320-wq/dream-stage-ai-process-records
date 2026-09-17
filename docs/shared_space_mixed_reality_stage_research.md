# 《White Hole》共址虚实融合舞台技术研究

**研究日期：** 2026-09-03  
**问题：** 演员与观众处在同一物理空间；演员戴头显后仍看见真实舞台，并看见与舞台对齐的数字画面；观众戴头显后仍看见真实演员，同时看见同一或个性化的数字内容。未戴头显的观众也应能参与演出。  
**资料范围：** 设备厂商、平台开发文档、官方规格、官方源码/文档与 Aalto 官方设施资料。

## 结论先行

**可以实现。** 这类形态通常叫 **co-located mixed reality（共址混合现实）**。Meta Quest 3/3S、Apple Vision Pro、Varjo XR-4、VIVE XR Elite/Focus Vision 都能通过外部摄像机的实时透视，把真实演员和舞台送进佩戴者视野，再在上面叠加空间化数字内容。光学透视设备（Magic Leap 2、已停产的 HoloLens 2）则让佩戴者直接透过透明光学系统看真人。

但“每个人都戴上眼镜”并不会自动产生同一个混合世界。完整系统至少有五层：

1. **现实可见：** passthrough 或透明光学系统让人看见真实演员、道具和其他人；
2. **共享坐标：** 所有头显知道“绿色椅子/舞台原点”在同一个物理位置；
3. **演出状态：** 所有人同时进入 `RECALL → DISTORTION → RESIDUE`，或收到同一个 cue/timecode；
4. **个人渲染：** 每台头显依据角色渲染同一事件的不同版本；
5. **舞台安全：** 边界、灯光、走位、紧急停止、人工 cue 与无头显备份。

对 White Hole 来说，最聪明的第一步不是给整场观众配头显，而是做一个 **两台 Quest 3 的 90–110 秒试验**：演员一台、一个观众一台；其余观众裸眼看投影、真实灯光与听空间声音。这样一次就能验证“演员是否还能表演”“真人与幻象是否真的叠合”“不同视角是否有戏剧价值”，同时避免把问题变成设备运维。

## 1. 你描述的画面具体如何成立

设绿色椅子是舞台的物理原点。

- 演员戴 Quest 3，通过彩色立体透视看见真实椅子、地面和观众；头显在椅子背后渲染一扇不存在的下午窗。演员靠近时，窗光的数字晕染扩张，或出现只有演员能看见的人影。
- 观众戴另一台 Quest 3，通过自己的透视摄像机直接看见真实演员。因为两台设备使用同一个空间锚，观众看见的数字窗也固定在同一把椅子后面，而不是粘在自己的脸上。
- 演员和观众不必看到完全相同的内容。演出服务器只同步“当前 cue、开始时间、演员到椅子的距离”；演员端可以看见诱惑他的完整人物，观众端只看见人物留下的轮廓或光的缺口。
- 未戴头显的观众仍看见真实演员、椅子、投影、颜色、灯光，并听见同一空间声音。他们不看见私密幻象，但必须仍能理解完整的情绪和动作弧线。

这是一种 **混合部署**，而不是“VR 版戏剧”和“普通舞台”两套作品。

## 2. 四类显示方式的本质区别

| 方式 | 人如何看见真人 | 能否个性化 | 舞台优势 | 关键局限 |
|---|---|---:|---|---|
| **Video-see-through MR**：Quest、Vision Pro、Varjo、VIVE | 摄像机拍摄真人，再显示到头显屏幕 | 是 | 可做虚实遮挡、整体调色、门户和完全不同的个人视角 | 真人不是裸眼直视；有摄像、显示、曝光、视场和深度误差 |
| **Optical-see-through AR**：Magic Leap 2、HoloLens 2 | 直接透过透明光学系统看真人 | 是 | 真人视觉更直接，没有视频透视的画面延迟与失真 | 虚拟黑色/完全不透明较难；视场有限；HoloLens 路线已衰退 |
| **Spatial augmented reality**：投影/LED/灯光 | 裸眼直接看舞台 | 否，通常所有人共享 | 无佩戴负担，演员面部完整可见，最像剧场 | 不能给每个人不同画面；遮挡、演员投影阴影和观看甜点位需处理 |
| **混合部署** | 头显观众看 MR，其余人裸眼看共享舞台 | 部分 | 同一场演出同时拥有共同事实与私密内心 | 必须避免头显观众获得理解剧情所必需的“特权信息” |

Meta 明确把 passthrough 定义为外部立体摄像机捕捉现实并在头显中实时显示，再叠加数字对象；Quest 3/3S 均为全彩透视并支持深度估计。[Meta Passthrough](https://developers.meta.com/horizon/essentials/horizon-os-passthrough/) Apple 同样说明 Vision Pro 的 passthrough 是外部摄像机的实时视频，而非透明玻璃。[Apple immersive experiences](https://developer.apple.com/design/human-interface-guidelines/immersive-experiences/)

## 3. 最适合当前项目的设备

### 3.1 Meta Quest 3：Aalto 首次实验的首选

Quest 3/3S 都能：

- 以全彩立体透视显示真实演员与空间；
- 用 Spatial Anchor 把内容锁在现实位置；
- 用 Shared Spatial Anchors/Colocation 让同一房间的多台头显共用坐标；
- 用 Depth API 让手、肢体、其他人和移动物体遮住虚拟内容；
- 对透视画面做亮度、饱和度、边缘和 LUT 调色，适合 White Hole 的绿色记忆污染与褪色。[Passthrough customization](https://developers.meta.com/horizon/documentation/unreal/unreal-customize-passthrough/)

Meta 的官方共址方案以一台 host 创建共享空间锚，其他设备定位到这个锚；但锚只负责坐标一致，连续的玩家姿态、物体变化和剧情状态仍需联网传输。[Meta Colocation showcase](https://developers.meta.com/horizon/documentation/unity/unity-learn-mixed-reality-through-discover/) Shared Spatial Anchors 当前面向同一房间的本地多人体验，支持 Quest 2、3、3S 和 Pro，并依赖第三方网络层。[Meta Shared Spatial Anchors](https://developers.meta.com/horizon/documentation/unreal/unreal-spatial-anchors-sharing/)

**为什么优先 Quest 3 而不是 3S：** 两者都能运行 Depth API，但 Quest 3 有硬件深度传感器；其光学与可视质量也更适合演员读地面、道具和对手的细微位置。Meta 官方设备比较可作为借用时的核对表。[Meta device comparison](https://developers.meta.com/horizon/resources/compare-devices/)

**与 Aalto 的匹配：** Takeout 研究时公开库存列出 23 台 Quest 3；这比购买 Vision Pro 或为 Varjo 配多台工作站更现实。借用仍需登录确认数量、项目许可和日期。[Aalto Quest 3 resource](https://takeout.aalto.fi/?i=616365)

### 3.2 Apple Vision Pro：技术模型很好，但不是当前最省力的路线

截至 visionOS 26，Apple 已有非常贴近本题的官方能力：Nearby SharePlay 中，同房间参与者会通过 passthrough 自然出现；group immersive space 为各设备提供共享坐标；设置为 `sharedWithNearbyParticipants` 的 World Anchor 可出现在所有附近参与者的相同物理位置。**但是 SharePlay 不会自动同步剧情状态，应用仍需用 GroupSessionMessenger 发送变化。** [Apple nearby sharing](https://developer.apple.com/documentation/groupactivities/configure-your-app-for-sharing-with-people-nearby)

Vision Pro 官方规格列出 12 ms photon-to-photon latency、750–800 g 重量与约 2.5 小时一般使用续航。[Apple Vision Pro specs](https://www.apple.com/apple-vision-pro/specs/) 它适合坐着或小范围移动的高质量观看，不适合首次就让演员做大幅舞蹈：Apple 建议 progressive/full immersion 不要超出约 1.5 m 边界；需要较多移动时应使用 mixed 模式。[Apple immersive-experience safety](https://developer.apple.com/design/human-interface-guidelines/immersive-experiences/)

因此，它适合未来做一个“高保真观众席版本”，前提是 Aalto 已有设备和 visionOS 开发支持；不适合作为第一版依赖。

### 3.3 Varjo XR-4：高保真专业单人/少量视角，而非观众规模

Varjo XR-4 是芬兰本地的专业视频透视 MR：双 20 MP 前置摄像机、深度遮挡、动态/自定义 mask、色键合成、7 m LiDAR，且支持 SteamVR tracking。[Varjo XR-4](https://varjo.com/products/xr-4) 它需要高端 Windows/NVIDIA 工作站，厂商推荐配置明确针对 native-resolution passthrough、depth occlusion 和高级着色。[Varjo system requirements](https://varjo.com/system-requirements)

它很适合以后做“一名演员或一名关键观众看到极高质量幻象”的研究，也适合精确绿幕/遮罩实验。但官方工具没有像 Meta Colocation 或 Apple Nearby SharePlay 那样完整的观众共址加入流程；共享坐标和状态同步需要自己整合。每台设备还关联一台高端工作站，所以不宜作为十几人观众版本的起点。

### 3.4 VIVE XR Elite / Focus Vision：可行的 OpenXR 备选

VIVE XR Elite 有全彩透视与深度传感器，官方建议的房间尺度最高约 10 × 10 m。[VIVE XR Elite](https://business.vive.com/us/product/vive-xr-elite/) Focus Vision 有双高分辨率全彩透视摄像机、深度传感器、眼动和自动 IPD，适合多人快速佩戴。[VIVE Focus Vision](https://business.vive.com/us/product/vive-focus-vision/)

它们能实现同一类 MR，但当前 VIVE 的 anchor/persisted-anchor 能力与多人演出工作流没有 Meta 那么现成。若 Aalto 现有 VIVE 设备和熟悉 VIVE/OpenXR 的技术人员，才值得把它升为首选；否则会增加集成变量。

### 3.5 光学透视：Magic Leap 2 可研究，HoloLens 2 不应新立项

Magic Leap 2 的透明 eyepiece 让人直接看现实，Dynamic Dimming 用来改善虚拟内容的对比；官方平台支持地图、Spatial Anchors 与多设备共址，同一空间也可离线导入/导出到多台设备。[Magic Leap 2](https://www.magicleap.com/buy-now) [Import/export spaces](https://developer-docs.magicleap.cloud/docs/guides/features/spaces/import-export-spaces/)

如果作品的核心要求是“必须直接看到真人的眼睛和肤色，而不能看摄像机转译”，Magic Leap 2 值得作为后续比较条件。但它不是 Aalto 已确认库存，透明显示对大面积黑暗、实心幻象和高对比场景也不是天然最强。

HoloLens 2 虽然是光学透视、支持 6DoF、空间网格和手眼追踪，[HoloLens 2 hardware](https://learn.microsoft.com/en-us/hololens/hololens2-hardware) 但 Microsoft 已确认 2024 年 12 月停止制造；Azure Spatial Anchors 也已于 2024-11-20 退役，Unity 在 2025-06-23 后的新版本不再支持构建 HoloLens 2。[HoloLens release notes](https://learn.microsoft.com/en-us/hololens/hololens-release-notes) [Azure Spatial Anchors lifecycle](https://learn.microsoft.com/en-us/lifecycle/products/azure-spatial-anchors) [Unity/HoloLens support](https://learn.microsoft.com/en-us/windows/mixed-reality/develop/unity/choosing-unity-version) 除非 Aalto 已有设备且研究问题就是光学透视，否则不要把新项目建在这条路上。

## 4. 共享空间不是一种技术，而是三个同步问题

### 4.1 空间同步：大家的“这里”必须相同

最小做法是把一个共享空间锚放在绿色椅子或舞台固定标记附近。所有虚拟窗、人物、光粒子都相对该锚定位。Meta 提醒 spatial anchor 最有效的范围约在其周围 3 m；对小舞台应使用一个中心锚，而不是给每个特效建独立坐标系。[Meta anchor lifecycle](https://developers.meta.com/horizon/documentation/native/android/openxr-spatial-anchors-features-lifecycle/)

锚定位失败的常见原因不是“算力不够”，而是空间缺少稳定视觉特征、太暗、布景变化或头显没有先完成 Space Setup。Meta 的共址排障建议用户先环视空间，并确保环境有独特视觉特征。[Meta colocation FAQ](https://developers.meta.com/horizon/documentation/unity/unity-colocation-tips-tricks-faq/)

如平台锚在黑箱舞台不稳定，可增加第二层校验：

- 舞台固定 AprilTag/ArUco 标记，用相机估算舞台原点姿态；官方 AprilTag 3 实现包含小标记检测与 pose estimation。[AprilTag official repository](https://github.com/AprilRobotics/apriltag)
- 或用 VIVE Tracker + SteamVR base stations 跟踪椅子/演员身体上的刚体；Aalto Takeout 有 Tracker 3.0，设备官方支持 SteamVR Base Station 1.0/2.0。[VIVE Tracker 3.0](https://developer.vive.com/eu/hardware/tracker3/) [Aalto tracker resource](https://takeout.aalto.fi/?i=615636)
- 高阶版再使用 Aalto Digital Studio 的光学 mocap。作为量级参照，OptiTrack PrimeX 13 官方规格为 240 Hz、4.2 ms camera latency，Motive 通常低于 10 ms并可通过 NatNet 实时流入 Unity/Unreal。[OptiTrack PrimeX 13](https://www.optitrack.com/cameras/primex-13/specs) [Motive specs](https://www.optitrack.com/software/motive/specs)

首版不要同时上共享锚、AprilTag、VIVE Tracker 和 mocap。先用共享锚；只有当漂移成为实际失败原因，再加入一个外部校验系统。

### 4.2 时间与状态同步：同一位置不等于同一时刻

共享锚不会告诉另一台头显“剧情已经进入失真”。需要一个权威演出状态源：

```text
舞台经理 / 演员距离输入
          ↓
本地 Show Controller（唯一权威状态）
          ↓ cueId + startTime + parameter
   ┌──────┴───────────┐
演员头显            观众头显
角色化渲染 A        角色化渲染 B
   └──────┬───────────┘
       投影 / 灯光 / 声音
```

第一版只同步：`cueId`、`serverStartTime`、`actorChairDistance`、`emergencyState`。动画和声音资产预装在每台设备上，以时间戳本地播放。**不要把每台头显的渲染视频通过 Wi-Fi 串流给其他头显。** Unity Netcode for GameObjects 是可用的高层 GameObject 网络层；对两台设备和少量状态，本地 Wi-Fi host 足够，不必先购买云服务。[Unity Netcode for GameObjects](https://docs.unity3d.com/current/Manual/com.unity.netcode.gameobjects.html)

### 4.3 视角同步：同步事实，不必同步画面

“共享”不代表同像。应同步的是：窗在什么地方、当前处于哪一幕、演员距离是多少。各客户端可以把这些事实翻译为不同画面：

- 演员端：人物完整、声音像从近处说话、窗光有吸引力；
- 头显观众端：人物始终背对、声音从错误方向靠近、演员手穿过残影；
- 裸眼观众端：投影只显示窗框和绿色的扩散，声音与真实灯光承担事件。

这样“个性化”服务于角色关系，而不是让观众随机抽到不同滤镜。

## 5. 最容易低估的困难

### 5.1 真人遮挡虚拟物：可做，但快速舞蹈会暴露误差

Quest Depth API 明确支持手、肢体、其他人和宠物等动态遮挡，因此真人演员原则上可以走到虚拟人物前面，并遮住它。有效深度的下限约 0.2 m；过近会不可靠。[Meta Depth API](https://developers.meta.com/horizon/documentation/unity/unity-depthapi-overview/)

官方也明确说明：快速运动时，深度遮挡可能滞后，边缘闪烁，无法做到逐像素、逐帧完全一致。[Meta occlusion limitations](https://developers.meta.com/horizon/documentation/unity/unity-depthapi-occlusions/) 因此：

- 不要把 90 秒高光建立在持续、精确的人体轮廓合成上；
- 把深度遮挡用于一个决定性时刻，例如演员伸手时幻象从手后滑到手前；
- 边缘使用柔和、烟雾状、粒子化或故意破损的美术语言，让误差成为记忆的性质；
- 如果动作很快，让虚拟内容与身体保持更大深度间隔。

### 5.2 舞台灯光不仅影响氛围，也影响追踪

视频透视并不等同于裸眼视觉：摄像机有自动曝光、动态范围、白平衡和显示色域，所以观众裸眼看见的琥珀光，不会在 Quest 中一模一样。透视本身也不是自然视觉；Meta 明确指出其 FoV 以及深度、颜色线索存在限制。[Meta passthrough safety](https://developers.meta.com/horizon/design/mr-health-passthrough/)

全黑、频闪和突然爆亮还会破坏追踪与舒适。Meta 建议在无闪烁灯光下使用 72 Hz，使 Quest 3/3S 的摄像机与显示同步，降低 judder；Apple 也提醒低照度会限制环境感知功能。[Meta passthrough best practices](https://developers.meta.com/horizon/documentation/native/android/mobile-passthrough-bp/) [Apple space safety](https://support.apple.com/guide/apple-vision-pro/prepare-your-space-tana3cdb0b5f/visionos)

所以 White Hole 的“黑暗”应设计为**观众感到黑，而追踪摄像机仍有足够纹理和照度**。可保留低强度、无频闪的工作光/IR 友好照明，避免头显演员在 blackout 中继续走动。

### 5.3 演员的身体和脸会被设备改变

头显会遮住演员眼睛和上半张脸，改变重量中心、汗液、呼吸、听觉和与观众的目光关系。这不是纯技术缺点，而是必须做出的舞台选择：

- 若“无法真正看见对方”就是作品主题，头显可成为服装/面具；
- 若演员的脸和真实目光是核心，不要让主演戴头显，可让演员通过 in-ear、地面 cue、投影或返看屏幕接收系统反馈，只让部分观众戴；
- 若必须让演员戴，舞蹈动作应先以低速、固定走位测试，不能把 passthrough 当作自然视觉。

### 5.4 多人规模的瓶颈是运营，不是 GPU

每增加一名头显观众，就增加一次：佩戴与 IPD 调整、眼镜兼容、卫生处理、账号/权限、空间定位、网络加入、电量检查、内容复位、应急摘除与工作人员说明。Meta 官方也提醒，共址会让受限视野的人集中在同一物理空间，拥挤会增加碰撞风险。[Meta spatial-anchor safety](https://developers.meta.com/horizon/documentation/native/android/openxr-spatial-anchors-overview/)

因此“10 台能联网”不等于“10 位观众能顺利入场”。正式扩容前先测量：每人 onboarding 时间、定位失败率、重启恢复时间、全组开始时间差、清洁与换场时间。

## 6. White Hole 的最小可行架构

### 6.1 90–110 秒版本：推荐架构

**人员：** 1 演员、1 头显观众、2–6 裸眼观察者、1 show operator、1 安全观察员。  
**设备：** 2 × Quest 3、1 × 本地 Wi-Fi 路由器、1 × 运行 Unity/show controller 的电脑、1 × 投影机、1–2 × 扬声器、真实绿色椅子、真实方向光/RGB 灯。  
**空间：** Experimental Studio 1 优先；Design Factory Stage 为低门槛回退。  
**定位：** 一个共享空间锚，放在椅子后方/舞台原点；内容集中在锚周围约 3 m。  
**输入：** 首轮由 operator 发 cue；只加入一个连续输入——演员到椅子的距离。距离可先由手动滑杆替代，之后再接 VIVE Tracker。  
**输出：** 两台头显的角色化 MR + 共享投影 + 真实灯光 + 声音。  
**回退：** 网络/锚/头显失败时，operator 一键切到预渲染投影、固定灯光 cue 和音轨；作品仍能完成。

推荐的三段技术事件：

| 时间 | 共享事实 | 演员头显 | 观众头显 | 裸眼舞台 |
|---|---|---|---|---|
| 0–35 s Recall | 窗出现，椅子是锚 | 看见较完整的下午窗与远人 | 只见微弱窗框与背影缺口 | 琥珀侧光、绿色椅子、远处椅声 |
| 35–75 s Distortion | 距离下降，失真参数上升 | 人影似乎靠近并要求伸手 | 人影其实后退，演员被绿色残影包围 | 投影复制、绿色过饱和、声音方向冲突 |
| 75–110 s Residue | operator/演员触发 release | 幻象先保持 1–2 s 惯性再瓦解 | 看见演员从幻象中“割开”一条缝 | 大部分颜色排空，只留空椅暖光和呼吸 |

**这个试验只回答三个问题：**

1. 真实演员在 passthrough 中是否仍有情绪存在感？
2. 同一物理事件的两种数字视角是否增加戏剧张力？
3. 头显体验与裸眼体验能否共享一个可理解的情绪脊柱？

### 6.2 10 分钟版本：成功后再增加的组件

- 4–8 台头显，而不是一次扩到全场；
- audience role assignment，但角色不超过 2–3 类；
- 两个共享锚或一个锚加外部追踪校验；
- stage manager cue console、设备健康监控和迟到/掉线重新加入；
- 独立的 safety marshal、头显清洁与充电轮换；
- 预演时记录每台设备的定位误差、状态偏差和掉帧；
- 可访问版本：不佩戴头显、减少动态视觉、字幕/音频描述均不损失主线。

只有在 2 台设备连续完成 10 次、定位和同步可靠之后，才扩容。

### 6.3 Aalto 的资源组合

- **设备与基础跟踪：** Takeout 的 Quest 3 与 VIVE Tracker 3.0；
- **黑箱试演：** Marsio Experimental Studio 1 有 360° 黑幕、白色 cyclorama、13,000-lumen projector、LED Fresnels 与 Vortex8 灯；
- **无头显沉浸对照：** Visualisation Studio 的 6 m 圆柱 360° 投影与 9.1 音响，可测试“不戴眼镜是否已经足够”；
- **高阶动作捕捉：** Digital Studio / MAGICS，仅在身体跟踪成为明确研究问题后使用；
- **协作者：** Teekkarispeksi 负责灯光/声音/舞台安全，DADA/DOT 寻找 Unity/互动媒体协作者。

详细准入、联系方式和设备清单见项目现有的 [Aalto resource research](./aalto_stage_resources_research.md)。

## 7. 不戴眼镜的观众如何不是“二等观众”

最合理的设计规则是：

> **公共媒介承载剧情因果，私人媒介承载主观差异。**

所有人都应通过演员动作、灯光、投影和声音理解“记忆吸引 → 失真反噬 → 主动切开 → 留下残余”。头显只让某些人感到“这个记忆如何骗我”，而不能垄断“到底发生了什么”。

无头显观众可通过以下方式参与：

- 共享投影/灯光/空间声，是作品主视图；
- 少量座位或站位改变声音和投影视差，但不要求设备；
- 一位或两位轮换的“记忆见证者”戴头显，其身体反应也成为其他观众可见的表演材料；
- 手机/平板 AR 只作为可选窗口，不作为主通道；
- 公开显示一块非常克制的状态痕迹，例如窗框亮度，告诉裸眼观众某个私密视角正在发生变化，但不把舞台变成技术演示。

## 8. 目前不建议做的事

1. **不建议全体演员和观众第一版都戴头显。** 你会先得到 onboarding 和安全实验，而不是戏剧证据。
2. **不建议先做全身实时数字替身。** 真人已经通过 passthrough 可见；先保留真人，只追踪一个有戏剧意义的变量。
3. **不建议让快速舞蹈持续依赖像素级人体遮挡。** 官方已说明深度会在快速动作中滞后和闪烁。
4. **不建议把云端生成式 AI 放在 cue-critical path。** 关键灯光、声音和视觉 cue 应本地、确定、可人工触发；AI 可在排练前生成材料或在非关键层做变化。
5. **不建议把 HoloLens 2 作为新项目平台。** 硬件已停产，关键云锚服务退役，Unity 新版本支持停止。
6. **不建议先买设备。** Aalto 已有 Quest/Tracker/空间；先借两台完成一个决定性实验。
7. **不建议让头显成为理解剧情的门票。** 否则混合观众不是同一场演出，而是两个作品碰巧同时发生。

## 9. 一个可直接发给 Aalto XR Studio 的技术请求

> I am testing a 90–110 second co-located mixed-reality theatre scene for one performer and one headset spectator, with additional non-headset observers. Both Quest 3 users must see the same real performer and physical green chair through passthrough, while role-specific virtual content is aligned to one shared stage anchor. A local show controller will synchronize only cue state, start time, and one performer-to-chair distance parameter; projection, lighting and sound remain the shared theatrical layer. I would like to borrow two Quest 3 headsets and test Shared Spatial Anchors/colocation, dynamic depth occlusion for one short moment, and a manual fallback. Could you advise on the required project permit, test accounts, suitable flicker-free lighting, local network policy, and a two-hour supervised slot?

## 10. 判定这条路线是否值得继续的门槛

两小时测试后，只在以下条件同时成立时进入 10 分钟版本：

- 两台头显中虚拟窗/人物与椅子的相对误差在观看上不破坏幻觉；
- 10 次运行至少 8 次无需重启即可开始；
- 两台设备进入关键 cue 的感知时间差不破坏动作节奏；
- 演员能安全看见地面、椅子和安全员，并能完成规定动作；
- 头显观众能准确描述“我与演员看到的不是同一个记忆”，而不只是说“效果很酷”；
- 裸眼观察者仍能说出完整的情绪与因果变化；
- 拔网或定位失败时，人工 cue 能在数秒内接管。

若空间对齐失败，先改锚与舞台纹理；若动作时遮挡失败，改美术和动作距离；若只有头显观众理解剧情，改公共投影/灯光/声音；若演员因头显失去表演力，则改为“观众戴、演员不戴”的架构。不要用增加更多技术掩盖这四类失败。

## 最终建议

你的想法在技术上成立，而且真正有戏剧潜力的地方不是“大家看到同一个特效”，而是：**演员与观众共享同一个真实身体，却被放进不同版本的同一段记忆。**

下一次原型应做成：

> **两台 Quest 3 + 一把真实绿色椅子 + 一个共享锚 + 一个权威 cue controller + 一层公共投影/灯光/声音。**

演员和一名观众都通过 passthrough 看见真人世界；系统只同步事实和时间，各自渲染不同幻象；其他人不戴眼镜也能看懂完整场景。这个架构已经足以验证作品最关键的艺术命题，同时保留之后转向 Vision Pro、Varjo、Magic Leap 或 360° 裸眼投影的空间。
