# Web 应用

## 1 适用范围

适用于以浏览器为用户交互入口的应用项目
常见项目形态包括管理后台、在线编辑器与协作平台

优先将前端与后端作为独立仓库治理；必须同仓交付时，采用全栈结构

## 2 项目结构

### 2.1 纯前端 Web App

仓库只交付前端；需要后端能力时，作为外部依赖接入

```text
<项目>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<标识>/     每个业务模块的接口、内部实现与测试
│  │  ├─ architecture.md    模块职责、进程边界与协作关系
│  │  ├─ class-design.md    单模块应用的内部实现与白盒测试
│  │  ├─ distribution.md    前端制品构建、交付、验证与故障处置
│  │  ├─ infrastructure.md  基础设施、资源与接入约定
│  │  ├─ instrumentation.md   业务数据记录、采集去向与责任
│  │  ├─ interaction.md     用户场景、界面与交互行为
│  │  ├─ release.md         验证、合并与版本固化流程
│  │  ├─ security.md        攻击面分析与防护论证
│  │  └─ testcase.md        应用整体用户交互行为的黑盒测试
│  ├─ ops-guide/            运营指南，按需设置
│  │  ├─ README.md          运营指南入口
│  │  ├─ data-collection.md 原始数据来源与定义
│  │  ├─ data-analysis.md   指标与分析方法
│  │  └─ ops-actions.md     允许执行的运营动作
│  ├─ user-guide/
│  │  └─ user-manual.md     用户操作与故障处理指南
│  └─ README.md             项目文档入口
├─ reference/               必须随仓保存的外部原件
├─ CHANGELOG.md             已发布版本的变化记录
├─ CONTEXT.md               项目术语
├─ README.md                项目入口与工程类型标识
├─ ROADMAP.md               当前版本状态与后续版本目标
├─ SSOT.md                  外部依据及其真实出处
└─ …                        源码、测试代码与构建配置按实际技术栈组织
```

| 文件或文档组 | 必要条件 | 行文参考 |
| --- | --- | --- |
| `CHANGELOG.md` | 始终必需 | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | 始终必需 | [context](../documents/context.md) |
| `README.md`（各层） | 始终必需 | [readme](../documents/readme.md) |
| `ROADMAP.md` | 始终必需 | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | 设计依赖外部依据 | [ssot](../documents/ssot.md) |
| `architecture.md` | 前端包含多个业务模块或多个进程 | [architecture](../documents/architecture.md) |
| `class-design.md` | 前端只有一个业务模块 | [class-design](../documents/class-design.md) |
| `distribution.md` | 始终必需 | [distribution](../documents/distribution.md) |
| `infrastructure.md` | 存在需要定义资源结构或接入约定的基础设施 | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | 始终必需 | [instrumentation](../documents/instrumentation.md) |
| `interaction.md` | 始终必需 | [interaction](../documents/interaction.md) |
| `module-<标识>/` 文档组 | 前端包含多个业务模块 | [module](../document-sets/module.md) |
| `ops-guide/` 文档组 | 运营或数据平台使用者需要数据收集、分析判断或运营操作指导 | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | 需要发布版本 | [release](../documents/release.md) |
| `security.md` | 涉及凭据、权限、敏感数据或不可信输入 | [security](../documents/security.md) |
| `testcase.md` | 始终必需 | [testcase](../documents/testcase.md) |
| `user-manual.md` | 需要向用户提供独立的使用或问题处理说明 | [user-manual](../documents/user-manual.md) |
| `reference/` | 存在必须随仓保存的外部原件 | [ssot](../documents/ssot.md) |

### 2.2 全栈 Web App

仓库同时交付前端与后端
项目级记录、用户指南与运营指南沿用 §2.1 的位置与必要条件

```text
design/
├─ backend/             后端内部设计与部署
├─ frontend/            前端内部设计与分发
│  ├─ module-<标识>/    多模块前端的模块设计
│  ├─ architecture.md   前端内部的模块职责与协作
│  ├─ class-design.md   单模块前端的内部实现与白盒测试
│  ├─ distribution.md   前端制品构建、交付、验证与故障处置
│  ├─ infrastructure.md 前端基础设施、资源与接入约定
│  ├─ instrumentation.md   业务数据记录、采集去向与责任
│  ├─ interaction.md    用户场景、界面与交互行为
│  ├─ security.md       前端安全设计
│  └─ testcase.md       前端整体行为的黑盒测试
├─ architecture.md      前后端职责、边界与协作关系
└─ release.md           整个应用的发布验证、合并与版本固化
```

| 文件或文档组 | 必要条件 | 行文参考 |
| --- | --- | --- |
| `backend/` | 始终必需 | [backend-service](backend-service.md) |
| `frontend/` | 始终必需 | 各文件沿用 §2.1 对应的行文参考 |
| `architecture.md` | 始终必需 | [architecture](../documents/architecture.md) |
| `frontend/architecture.md` | 前端包含多个业务模块或多个进程 | [architecture](../documents/architecture.md) |
| `frontend/distribution.md` | 始终必需 | [distribution](../documents/distribution.md) |
| `frontend/interaction.md` | 始终必需 | [interaction](../documents/interaction.md) |
| `release.md` | 需要发布版本 | [release](../documents/release.md) |
| `frontend/testcase.md` | 始终必需 | [testcase](../documents/testcase.md) |

`frontend/` 内部文件的必要条件按前端自身情况判断，沿用 §2.1 对应规则
`backend/` 套用 [backend-service](backend-service.md) 的内部设计、接口、测试、基础设施、数据观测、安全与部署规则；对应文件从 `docs/design/` 映射到 `backend/`
项目级记录、文档入口、用户指南与 [release](../documents/release.md) 统一治理；用户手册与后端接入指南放在 `docs/user-guide/`，release 定义整个仓库的发布验证、合并与 Tag 固化
运营指南统一放在外围的 `docs/ops-guide/`，引用前后端各自的事件与数据定义
前端分发与后端部署分别由 `frontend/distribution.md` 和 `backend/deployment.md` 定义
用户交互由 `frontend/interaction.md` 定义；前端与后端分别维护自己的 `testcase.md`，不建立项目级 testcase

## 3 治理顺序

后续治理发现上游设计缺失或冲突时，修正对应文档，并同步受影响的下游设计

### 3.1 纯前端 Web App

1. 治理用户交互
   - 先治理 [interaction](../documents/interaction.md)
2. 治理职责划分与运行约束
   - 根据 [interaction](../documents/interaction.md) 治理已选用的 [architecture](../documents/architecture.md)
   - 先治理已选用的 [infrastructure](../documents/infrastructure.md) 中影响内部实现的资源结构与接入约定
   - 先治理 [distribution](../documents/distribution.md) 与已选用的 [security](../documents/security.md) 中影响内部实现的约束
   - 治理 [instrumentation](../documents/instrumentation.md)，明确内部实现所需的数据记录约定
3. 治理内部设计
   - 单模块前端治理项目级 [class-design](../documents/class-design.md)
   - 多模块前端按 [architecture](../documents/architecture.md) 定义的模块依赖关系，先治理被依赖的模块
   - 多模块前端的每个模块内部，按 [module](../document-sets/module.md) 文档组规定的顺序治理
4. 治理整体验证
   - 依据 [interaction](../documents/interaction.md) 治理项目级 [testcase](../documents/testcase.md)
5. 完成交付与使用说明
   - 根据内部设计，补齐已选用的 [infrastructure](../documents/infrastructure.md)，完成已选用的 [security](../documents/security.md) 的防护论证
   - 根据内部设计与交付约束，完成 [distribution](../documents/distribution.md)
   - 在前述设计明确后，治理已选用的 [release](../documents/release.md)
   - 在交互行为与交付方式明确后，治理已选用的 [user-manual](../documents/user-manual.md)
   - 在运营所需的数据、接口与操作约束明确后，治理已选用的 [ops-guide](../document-sets/ops-guide.md)
6. 完善文档入口
   - 在项目设计明确后，按 [readme](../documents/readme.md) 完善项目级文档入口 `docs/README.md`

### 3.2 全栈 Web App

1. 治理前端 [interaction](../documents/interaction.md)，明确用户交互行为
2. 根据前端 [interaction](../documents/interaction.md)，治理整体 [architecture](../documents/architecture.md)
3. 根据整体职责与依赖关系治理两端设计
   - 跨端协作先明确后端 [interface](../documents/interface.md) 契约，再治理依赖该契约的前端实现
   - `frontend/` 的后续设计按 §3.1 治理；release、用户指南、运营指南与项目文档入口在项目级统一治理
   - `backend/` 按 [backend-service](backend-service.md) 的治理顺序治理；release、接入指南、运营指南与项目文档入口在项目级统一治理
4. 完成统一发布与使用说明
   - 在两端设计与交付方案明确后，治理已选用的项目级 [release](../documents/release.md)
   - 根据前端交互与后端接入约定，治理已选用的 [user-manual](../documents/user-manual.md) 与 [integration-guide](../documents/integration-guide.md)
   - 在运营所需的数据、接口与操作约束明确后，治理已选用的 [ops-guide](../document-sets/ops-guide.md)
5. 按 [readme](../documents/readme.md) 完善项目文档入口 `docs/README.md`

## 4 检查条件

- [ ] 支撑运营分析的业务数据记录机制已设计，记录时机、数据内容、数据去向与责任方明确
- [ ] 所选项目形态下，必要条件成立的文档与文档组均已建立
- [ ] 文档位置符合所选项目形态的层级树，内部文件组成符合对应文档组或引用规则
- [ ] 后续设计依赖的契约与约束，均能定位到已经明确的上游文档
- [ ] 全栈应用的前端调用设计引用后端 [interface](../documents/interface.md)，并符合其契约
