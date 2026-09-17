# 内部证据与缺口记录

访问/核查日期：2026-09-07。对应唯一报告源 `report-source.md`；这是取证记录，不是额外的用户报告。

| 判断 | 原始来源、作者/发布者与日期 | 访问证据与可信度 | 边界、反例与处置 |
|---|---|---|---|
| 游戏方法可连接规则、行动与体验目标 | Hunicke、LeBlanc、Zubek，MDA，2004；https://www.cs.northwestern.edu/~hunicke/MDA.pdf | 原文，较高 | 是设计框架，不证明本作必然动人；转化为可玩的动作反馈后另行试玩 |
| 有意义的行动需要系统理解与行动欲望相匹配 | Wardrip-Fruin等，Agency Reconsidered，2009；https://cs.uky.edu/~sgware/reading/papers/wardripfruin2009agency.pdf | 原文，较高 | 不等于按钮越多或分支越多越好；固定意义结构内保留不同参与路径 |
| 身体和共享空间会影响参与 | Hornecker、Buur，CHI 2006；https://www.ehornecker.de/Papers/FrameworkCHI.pdf | 作者原文，较高 | 键鼠游戏不能证明实体观众体验；保留真人试演缺口 |
| 作品预设轨迹与实际参与轨迹可以不同 | Benford等，CHI 2009；https://www.researchgate.net/publication/221516077_From_interaction_to_trajectories_Designing_coherent_journeys_through_user_experiences | 作者上传正文，较高 | 不是无限生成剧情的依据；应用为进入、追赶、交换与照顾的衔接 |
| 强烈体验之后的释放与反思需要设计 | Benford等，CHI 2012；https://people.cs.nott.ac.uk/pszjm2/uploads/2012/11/Uncomfortable-interactions.pdf | 作者原文，较高 | 不作为丧亲疗效证据；采用安静参与、暂停和缓和结尾 |
| 渲染和视觉反馈可支持迭代编辑 | Huang等，BlenderAlchemy，2024；https://arxiv.org/html/2404.17672v1 | 原始论文，较高 | 实验范围偏材质/光照；不外推为完整人物与游戏生产能力 |
| 建模分阶段和回看能控制错误传播 | Thinking in Blender，2026预印本；https://arxiv.org/html/2606.02580v1 | 原始预印本，中等 | 非本项目对照实验；早期错误和运行成本仍存在 |
| 垂直切片和好奇心值得作为设计线索 | GDC官方讲座介绍；https://gdcvault.com/play/1022329/The-Vertical-Slice 及 https://www.gdcvault.com/play/1027368/Independent-Games-Summit-Sparking-Curiosity | 只核查官方介绍，中等 | 未看完整讲座，不引用视频中的具体过程或结论 |
| Compatibility适合集显作为可测起点 | Godot官方系统要求，访问当日；https://docs.godotengine.org/en/stable/about/system_requirements.html | 官方文档+本机OpenGL3.3实际运行，较高 | 不能保证所有电脑帧率；本机完成帧采样60FPS不视作稳定性能基准 |
| Blender MCP是操作桥接 | ahujasid，blender-mcp，访问当日源码；https://github.com/ahujasid/blender-mcp | README、许可、实现检查，较高 | 未新装桥接；已有bpy可完成资产，不把工具存在当作审美质量证明 |
| Blender skill可参考检查顺序 | jithinolickal，blender，访问当日；https://github.com/jithinolickal/blender | SKILL与依赖检查，中等 | GPU/UI等假设不直接适配本机；没有整包安装 |
| Three.js skills有需纠正的技术建议 | alton47，threejs-skills，访问当日；https://github.com/alton47/threejs-skills | 源文与本地Three.js r180对照，较高 | 非颜色贴图色彩空间、多材质draw call等不能照搬；不是官方背书 |
| 资产CC0与插件许可不同 | Poly Haven；https://polyhaven.com/license 及 https://github.com/Poly-Haven/polyhavenassets | 官方许可、插件源码，较高 | 本版自行制作纹理，没有将插件许可等同于素材许可 |
| 大型3D生成工具不适合此台集显直接运行 | Tencent Hunyuan3D-2.1；https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1 | 官方README硬件要求与自定义许可，较高 | 未运行；显存与地域条款需按实际部署重新核对 |
| TRELLIS.2不作为本机制作主线 | Microsoft，TRELLIS.2；https://github.com/microsoft/TRELLIS.2 | 官方README/Linux/NVIDIA要求，较高 | H100演示速度不外推到Iris Xe；未本机运行 |
| glTF工具可检查导出有效性 | Don McCurdy，glTF-Transform CLI 4.5.0；https://github.com/donmccurdy/glTF-Transform | 官方说明+本地CLI/validator实际运行，较高 | 保留交互层级；有效glTF不证明造型好看 |

检索分为：游戏/具身互动原始论文、Blender视觉迭代论文、GitHub实现/许可证/硬件要求、官方渲染与导出接口。两条独立研究线分别覆盖游戏设计与工具审查；协调阶段复核了重要论文、技能错误与部署约束。原生检索输出保留于会话；此处不编造无法重建的逐字查询日志。

停止继续扩张工具清单的原因：关键选择已有原始证据，额外同类清单不足以改变 Blender + Godot 的当前路线。未解决的主要问题已经转为本作实测：接触姿态、实时画面、交互因果与真人感受。前面三项由工程和窗口检查推进；真人感受仍需创作者与新玩家试演，不被截图或状态测试替代。
