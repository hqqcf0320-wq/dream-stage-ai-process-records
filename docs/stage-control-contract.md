# 《醒来之前》专业舞台迁移约定 v0.1

状态：设计约定与资产已交付；UE、TouchDesigner 和实体设备适配器未实现，不能据此声称设备已经接通。

## 空间与资产

Blender 母版使用米、Z向上、+Y朝窗。GLB/浏览器使用米、Y向上、-Z朝窗。演员在浏览器坐标 (-0.6,0,-1.9)，红窗中心 x=0、z=-4.1；这些是预演尺寸，须根据场地重新定标。

建议UE约定 +X朝窗、+Y观众视角的右侧、+Z向上，厘米单位。按本项目自定义方向，浏览器点 (x,y,z) 转为 UE 点 (-100z,100x,100y)。这是事件/定位数据的转换约定，不是让导入器再次转换已经处理好的模型；用一米标尺和三个轴标检查，避免重复缩放或镜像。UE官方采用左手、Z向上坐标系，跨软件需要检查轴向。[Epic坐标文档](https://dev.epicgames.com/documentation/en-us/unreal-engine/coordinate-system-and-spaces-in-unreal-engine)。

导入 `.glb` 后保留 `RoomSet`、`GreenChair`、`Grandpa`、`SmallBear`、`BigBear`、`ExchangePlinth` 分组。导入流程参考 [Epic glTF导入入口](https://dev.epicgames.com/documentation/en-us/unreal-engine/importing-gltf-files-into-unreal-engine)，本轮未在UE内实测。若当前版本无法保留所需层级，应从 `.blend` 分组重导，而非把整个场景合并成一个静态网格。

正式演出隐藏 `Grandpa` 数字占位。实体椅子和真人不属于可旋转的 `RoomSet`。雨、云、金线、光束是浏览器程序效果，GLB不携带它们；UE需分别重建材质和Niagara系统。不能把“导入GLB成功”当作舞台迁移完成。

## 已运行的本地输入

WebSocket：`ws://127.0.0.1:4173/audience`

```json
{"type":"gesture","who":"C","kind":"stomp"}
```

允许 who=A/B/C/D；kind=stomp/sway/sing/hug/sleeve/call。主舞台收到后产生唯一ID、时间、当前段落，冻结时不接收。本轮无可靠传感识别、无服务器持久演出状态；浏览器刷新会新开一场。

## 迁移后继续保留的消息

以下为未来适配器约定，不是已实现网络端点：

| 消息 | 字段 | 执行者 |
|---|---|---|
| AudienceGesture | eventId, participantId, kind, timestamp, position, observedDetail, inputSource | 传感器/操作员；不得凭空推断心理 |
| PerformerGO / HOLD | sessionId, chapterVersion, operatorId | 演员或舞监 |
| ResonanceProposal | sourceEvent, who, action, actorCue, visualCue, epoch, chapter | AI只提议 |
| Accept / Reject | proposalId, chapterVersion, operatorId | 演员或舞监 |
| VisualCue | acceptedProposalId, sourceEvent, targetZone, effectPreset, duration | 确定性渲染控制 |

消息归因和版本校验沿用 `prototype/src/score.js`。过期候选不可重放；AI失败保留当前段落；暂停后恢复由人推进。演员建议可忽略，机械运动不出现在模型输出枚举中。

TouchDesigner后续可用OSC传递离散事件和连续风雨参数；官方区分 OSC In/Out CHOP 的通道和 OSC In/Out DAT 的消息处理。[Derivative OSC](https://derivative.ca/UserGuide/OSC)。建议把带ID的动作事件与连续雨量分开，避免把同一动作每一帧重复算作新参与。

## 正式搭台前的验证顺序

1. 一米标尺、固定椅子和演员位置正确；转动数字房间不带走真人。
2. 一个输入区触发一条金线，四区同时触发仍分别归因。
3. 从中心与两侧看太阳雨和房间退远，确认投影遮挡与透视是否能接受。
4. 真人接住一个具体动作的回调；暂停、拒绝、迟到AI均不打断表演。
5. 再接舞台灯光和多面画面。实体升降由专业舞台控制与现场人员独立处理。
