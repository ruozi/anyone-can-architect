# 文档设计规则

本目录保存工程类型规则、文档组、单篇文档设计规则和内容表达方式

本文件统一提供导航，各工程类型的项目结构、文档必要条件与治理约定以对应类型规则为准
设计项目文档时先读工程类型规则，再读选用的文档组与对应文档设计，按内容需要选择 pattern

## 工程类型与文档设计

工程类型规定项目结构与文档的必要条件

| 工程类型 | 适用项目 | 设计规则 |
| --- | --- | --- |
| `web-app` | 以浏览器为用户交互入口的应用 | [Web 应用](repo-types/web-app.md) |
| `mobile-app` | Android、iOS 等移动应用 | [移动应用](repo-types/mobile-app.md) |
| `desktop-app` | Windows、macOS、Linux 等桌面应用 | [桌面应用](repo-types/desktop-app.md) |
| `client-sdk` | 提供给客户端工程接入的 SDK 或库 | [客户端 SDK](repo-types/client-sdk.md) |
| `backend-service` | 向其他程序提供远程调用能力的服务 | [后端服务](repo-types/backend-service.md) |
| `automation` | 指令或事件触发的自动化工作流 | [自动化服务](repo-types/automation.md) |
| `guideline` | 部门规范、团队指南和规则集合 | [规范仓库](repo-types/guideline.md) |

## 文档组

文档组规定共同描述一个设计对象的文件组成、职责关系与设计顺序，保存在 `document-sets/`
工程类型选择需要的文档组，单个文件的结构与写法引用对应文档设计

| 文档组 | 负责什么 |
| --- | --- |
| [module](document-sets/module.md) | 模块的 README、对外契约、内部实现与黑盒测试 |
| [command](document-sets/command.md) | 命令说明、注册表、路由中枢与叶子命令 |
| [event](document-sets/event.md) | 触发策略、注册表、调度中心与具体事件 |
| [ops-guide](document-sets/ops-guide.md) | 运营数据采集、分析方法与可执行动作 |

## 文档设计

文档设计按文档名保存在 `documents/`，一篇文档一个文件，工程类型与文档组按职责选用并决定顺序
规范正文的编写要求见 [guideline](documents/guideline.md)
项目术语文档的结构与写法见 [context](documents/context.md)
项目外部依据、版本规划与变更记录分别见 [ssot](documents/ssot.md)、[roadmap](documents/roadmap.md) 与 [changelog](documents/changelog.md)
业务数据观测设计的结构与写法见 [instrumentation](documents/instrumentation.md)
数据采集与分析指南的结构与写法分别见 [data-collection](documents/data-collection.md) 与 [data-analysis](documents/data-analysis.md)
运营动作指南的结构与写法见 [ops-actions](documents/ops-actions.md)
文档设计不设定位、介绍或索引 [chapter](../CONTEXT.md#chapter)，单元是什么归 readme，导航靠目录结构
文档设计写两件事：文档结构是终点，期望最终长什么样；行文步骤是怎么到达终点，每个 [chapter](../CONTEXT.md#chapter) 内容怎么写归 pattern

## 内容表达方式

Patterns 保存跨工程类型通用的内容表达方式

- pattern 按内容种类命名，说明该种内容怎么写、怎么画
- 表达原则只有一个内容单元时直接写规则，多个内容单元时用组成表并引用对应小节
- 组成表列出内容、必需条件与表达规则，全部必需时在表前统一声明并省略必需条件列
- 表达形式与具体规则在对应小节定义，组成表不重复说明
- 同一种内容的场景差异写在同一篇 pattern 里，不另立文件
- Mermaid 语法与样式以官方语法页为准，pattern 只规定内容纪律，不自创样式
- pattern 可以把自己内容里的一个单元交给另一个 pattern 表达，写明什么条件下交出去；只做选型指引时只链接不嵌套
- 文档设计没有指定表达方式的内容，按各 pattern 的适用场景选用 pattern，没有适配的才用表格或文字
- 文档设计与 pattern 共用的方法论与映射规则见[配套规则](../skills/references/README.md)

### 图

- [流程图](patterns/flowchart.md)（程序化流程、包含 LLM／Agent 的流程）
- [时序图](patterns/sequence-diagram.md)
- [状态机](patterns/state-machine.md)
- [分层视图](patterns/layered-view.md)（层级关系视图、分层模块依赖视图二选一）
- [层级树](patterns/hierarchy-tree.md)

### 文本

- [模块接口](patterns/interface.md)
- [数据契约](patterns/schema.md)
- [LLM 提示词](patterns/llm-prompt.md)
- [Agent 目标](patterns/agent-goal.md)
- [测试用例](patterns/testcase.md)（黑盒与白盒共用的夹具、长链场景与断言写法）

### 卡片

- [飞书卡片示意](patterns/lark-card-mockup.md)

## Mermaid 图型字典（全量 28 型）

> 设计文档里的 Mermaid 图型以「在用」为限
> 「候选」首次使用前，先在目标渲染端实测通过，再按内容种类开 pattern
> 语法以各型的官方语法页为准

### 在用（3 型，承载全部图 pattern）

| 官方型名 | 关键字 | 语法 SSOT | 承载的 pattern |
|---|---|---|---|
| Flowchart | `flowchart` | <https://mermaid.ai/open-source/syntax/flowchart.html> | flowchart · layered-view |
| Sequence Diagram | `sequenceDiagram` | <https://mermaid.ai/open-source/syntax/sequenceDiagram.html> | sequence-diagram |
| State Diagram | `stateDiagram-v2` | <https://mermaid.ai/open-source/syntax/stateDiagram.html> | state-machine |

> C4 Diagram（<https://mermaid.ai/open-source/syntax/c4.html>）不用：官方语法仍是实验状态且布局不可控，分层视图用 `flowchart` + `subgraph`

### 候选（出现真实场景即转在用）

| 官方型名 | 关键字 | 语法 SSOT | 等待的真实场景 |
|---|---|---|---|
| GitGraph Diagram | `gitGraph` | <https://mermaid.ai/open-source/syntax/gitgraph.html> | 版本分支模型 / 合流策略图示 |
| Class Diagram | `classDiagram` | <https://mermaid.ai/open-source/syntax/classDiagram.html> | 类结构图示需求 |
| Entity Relationship Diagram | `erDiagram` | <https://mermaid.ai/open-source/syntax/entityRelationshipDiagram.html> | 实体关系图示需求 |
| Architecture | `architecture-beta` | <https://mermaid.ai/open-source/syntax/architecture.html> | 带云资源图标的部署拓扑<br>现阶段由 layered-view 覆盖 |
| Event Modeling | 见语法页 | <https://mermaid.ai/open-source/syntax/eventmodeling.html> | 事件驱动后端（event sourcing）的工作流建模 |
| Packet | `packet-beta` | <https://mermaid.ai/open-source/syntax/packet.html> | 位级二进制协议 / 包格式定义 |
| Venn | `venn-beta` | <https://mermaid.ai/open-source/syntax/venn.html> | 集合重叠表达，如人群圈选交集、平台能力交集 |

### 不用（内容落位在别处）

| 官方型名 | 该内容种类在本体系的落位 |
|---|---|
| User Journey | 产品流程归 flowchart 或 sequence-diagram<br>journey 只能表达线性流程加打分 |
| Gantt | 排期随时变化，归项目管理工具，不进设计文档 |
| Timeline | 历史与里程碑由 Git 与 Tag 记录，设计文档不复述 |
| Kanban | 任务流归项目管理工具 |
| Pie Chart | 数据展示归数据报表工具，设计文档不放活数据 |
| XY Chart | 同上 |
| Sankey | 同上，投放漏斗与量级分配属于数据分析产物 |
| Radar | 同上 |
| Treemap | 同上 |
| Quadrant Chart | 选型 / 定位论证使用普通对比表 |
| Requirement Diagram | 需求追踪由设计文档树与 § 交叉引用承担 |
| ZenUML | 与 sequenceDiagram 表达力重复，渲染端兼容差 |
| Block Diagram | 结构框图归 layered-view / flowchart |
| Ishikawa | 尚无实际使用场景，暂不纳入 |
| Mindmap | 发散脑暴不落设计文档，收敛结论按目标文档的文档设计写 |
| Wardley Map | 探索性战略工具，本体系服务确定性业务 |
| TreeView | 层级树用代码块缩进，全渲染端兼容 |
