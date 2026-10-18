# 客户端 SDK

## 1 适用范围

适用于以向其他客户端工程提供可安装、可调用的软件包为主要用途的项目
常见项目形态包括 SDK 与可复用客户端库

支持纯客户端 SDK，以及 SDK 与配套后台服务共同设计两种形态

## 2 项目结构

### 2.1 纯客户端 SDK

只治理 SDK 本身，需要的后台能力作为外部依赖接入

```text
<项目>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<标识>/        每个业务模块的契约、实现与测试
│  │  ├─ architecture.md       模块职责划分与协作关系
│  │  ├─ class-design.md       单模块 SDK 的内部实现与白盒测试
│  │  ├─ distribution.md       制品构建、分发与故障处置流程
│  │  ├─ infrastructure.md     基础设施、资源与接入约定
│  │  ├─ instrumentation.md   业务数据记录、采集去向与责任
│  │  ├─ interface.md          SDK 对外的调用契约
│  │  ├─ release.md            验证、合并与版本固化流程
│  │  ├─ security.md           安全设计
│  │  └─ testcase.md           SDK 对外行为的黑盒测试
│  ├─ ops-guide/               运营与数据平台操作指南，按需设置
│  │  ├─ README.md             运营指南入口
│  │  ├─ data-collection.md    原始数据来源与定义
│  │  ├─ data-analysis.md      数据分析方法
│  │  └─ ops-actions.md        可执行的运营动作
│  ├─ user-guide/
│  │  ├─ integration-guide.md  调用方接入指南
│  │  └─ user-manual.md        产品使用手册，按需设置
│  └─ README.md                项目文档入口
├─ reference/                  必须随仓保存的外部原件
├─ CHANGELOG.md                已发布版本的变化记录
├─ CONTEXT.md                  项目术语
├─ README.md                   项目入口与工程类型标识
├─ ROADMAP.md                  当前版本状态与后续版本目标
├─ SSOT.md                     外部依据及其真实出处
└─ …                           源码、测试代码与构建配置按实际技术栈组织
```

`user-guide/` 面向产品使用者，指导接入或使用产品
`ops-guide/` 面向运营或数据平台使用者，指导数据收集、分析判断与运营动作，并验证动作效果
`user-guide/` 内的指南根据使用方式选用 [integration-guide](../documents/integration-guide.md) 或 [user-manual](../documents/user-manual.md) 的写法
`ops-guide/` 按 [ops-guide](../document-sets/ops-guide.md) 文档组组织

| 文件或文档组 | 必要条件 | 行文参考 |
| --- | --- | --- |
| `CHANGELOG.md` | 始终必需 | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | 始终必需 | [context](../documents/context.md) |
| `README.md`（各层） | 始终必需 | [readme](../documents/readme.md) |
| `ROADMAP.md` | 始终必需 | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | 设计依赖外部依据 | [ssot](../documents/ssot.md) |
| `architecture.md` | SDK 包含多个业务模块 | [architecture](../documents/architecture.md) |
| `class-design.md` | SDK 未拆分为多个业务模块 | [class-design](../documents/class-design.md) |
| `distribution.md` | 始终必需 | [distribution](../documents/distribution.md) |
| `infrastructure.md` | 存在需要构建或依赖的基础设施 | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | 始终必需 | [instrumentation](../documents/instrumentation.md) |
| `interface.md` | 始终必需 | [interface](../documents/interface.md) |
| `module-<标识>/` 文档组 | SDK 包含多个业务模块 | [module](../document-sets/module.md) |
| `ops-guide/` 文档组 | 运营或数据平台使用者需要数据收集、分析判断或运营操作指导 | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | 需要发布版本 | [release](../documents/release.md) |
| `security.md` | 涉及凭据、用户数据、网络传输或权限 | [security](../documents/security.md) |
| `testcase.md` | 始终必需 | [testcase](../documents/testcase.md) |
| `integration-guide.md` | 始终必需 | [integration-guide](../documents/integration-guide.md) |
| `user-manual.md` | 产品使用者需要独立的使用说明 | [user-manual](../documents/user-manual.md) |
| `reference/` | 存在必须随仓保存的外部原件 | [ssot](../documents/ssot.md) |

### 2.2 SDK 与后台共同设计

SDK 与配套后台服务的设计文档放在同一个设计入口下

```text
docs/
├─ backend/                 后台服务的文档
│  ├─ design/               契约、内部设计、测试与部署
│  └─ user-guide/           后台使用者的指南，按需设置
│     └─ integration-guide.md  后台接口调用方接入指南
├─ design/
│  ├─ architecture.md       两端职责、边界与协作关系
│  └─ release.md            两端代码同仓时的仓库发布流程
├─ ops-guide/               运营数据与动作指南，按需设置
│  ├─ README.md             运营指南入口
│  ├─ data-collection.md    原始数据来源与定义
│  ├─ data-analysis.md      数据分析方法
│  └─ ops-actions.md        可执行的运营动作
├─ sdk/                     SDK 的文档
│  ├─ design/
│  │  ├─ module-<标识>/     多模块 SDK 的模块设计
│  │  ├─ architecture.md    SDK 内部的模块职责与协作
│  │  ├─ class-design.md    单模块 SDK 的内部实现与白盒测试
│  │  ├─ distribution.md    SDK 制品构建、分发与故障处置
│  │  ├─ infrastructure.md  SDK 基础设施、资源与接入约定
│  │  ├─ instrumentation.md   业务数据记录、采集去向与责任
│  │  ├─ interface.md       SDK 对调用方的契约
│  │  ├─ release.md         SDK 仓库的发布流程
│  │  ├─ security.md        SDK 安全设计
│  │  └─ testcase.md        SDK 对外行为的黑盒测试
│  └─ user-guide/
│     ├─ integration-guide.md  SDK 调用方接入指南
│     └─ user-manual.md        SDK 产品使用手册，按需设置
└─ README.md                共同文档入口
```

下表路径相对于 `docs/`

| 文件或文档组 | 必要条件 | 行文参考 |
| --- | --- | --- |
| `backend/` | 始终必需 | [backend-service](backend-service.md) |
| `sdk/` | 始终必需 | 各文件沿用 [§2.1](#21-纯客户端-sdk) 对应的行文参考 |
| `design/architecture.md` | 始终必需 | [architecture](../documents/architecture.md) |
| `sdk/design/architecture.md` | SDK 包含多个业务模块 | [architecture](../documents/architecture.md) |
| `sdk/design/distribution.md` | 始终必需 | [distribution](../documents/distribution.md) |
| `sdk/design/interface.md` | 始终必需 | [interface](../documents/interface.md) |
| `sdk/design/testcase.md` | 始终必需 | [testcase](../documents/testcase.md) |
| `sdk/design/release.md` | SDK 代码独立成仓且需要发布版本 | [release](../documents/release.md) |
| `backend/design/release.md` | 后台代码独立成仓且需要发布版本 | [release](../documents/release.md) |
| `design/release.md` | 两端代码同仓且需要发布版本 | [release](../documents/release.md) |
| `ops-guide/` 文档组 | 沿用 [§2.1](#21-纯客户端-sdk) 的必要条件 | [ops-guide](../document-sets/ops-guide.md) |
| `sdk/user-guide/integration-guide.md` | 始终必需 | [integration-guide](../documents/integration-guide.md) |
| `backend/user-guide/integration-guide.md` | 后台接口交付给仓库外部的接入者 | [integration-guide](../documents/integration-guide.md) |
| `sdk/user-guide/user-manual.md` | 沿用 [§2.1](#21-纯客户端-sdk) 的必要条件 | [user-manual](../documents/user-manual.md) |
| `README.md`（各层） | 沿用 [§2.1](#21-纯客户端-sdk) 的必要条件 | [readme](../documents/readme.md) |

`sdk/` 内部文件的必要条件沿用 [§2.1](#21-纯客户端-sdk)，按 SDK 本身的情况判断
`backend/` 套用 [backend-service](backend-service.md) 的文档规则
两端各自类型规则中的 `docs/` 内容，分别映射到 `docs/sdk/` 与 `docs/backend/`
运营指南统一放在外围的 `docs/ops-guide/`
两端的 release 按上表选择

SDK 调用后台接口时，引用 `backend/design/interface.md` 中的契约
SDK 对调用方提供的契约由 `sdk/design/interface.md` 定义
两端分别维护自己的 `testcase.md`，不建立项目级 testcase
白盒测试随各自的内部实现设计展开
SDK 分发与后台部署分别由 `sdk/design/distribution.md` 和 `backend/design/deployment.md` 定义
接入指南按 SDK 调用方与后台接口调用方分别组织
必要条件沿用各自类型规则
运营指南按采集、分析与动作职责分篇
各篇的内容组织沿用 [ops-guide](../document-sets/ops-guide.md) 文档组与对应文档设计
一个运营目标涉及两端时，三篇指南引用对应端的契约、数据与安全设计
通过跨文档引用串联数据采集、分析判断、运营动作与效果验证
共用方法与操作在一处定义，其他指南引用

设计文档共址不要求两端代码同仓，也不要求统一版本与 Tag
两端代码独立成仓时，各自维护版本记录与发布流程
两端代码同仓时
- 项目级记录统一维护
- `docs/design/release.md` 定义仓库级发布与 Tag 固化

## 3 治理顺序

### 3.1 纯客户端 SDK

1. 治理对外契约
   - 先治理项目级 [interface](../documents/interface.md)
2. 治理职责划分与运行约束
   - 根据对外契约治理已选用的 [architecture](../documents/architecture.md)，形成后再治理各模块
   - 已选用 [infrastructure](../documents/infrastructure.md) 时，在治理内部实现前先治理其依赖的基础设施内容
   - 先治理 [distribution](../documents/distribution.md) 中影响内部实现的平台与制品约束
   - 先治理已选用的 [security](../documents/security.md) 中影响内部实现的约束
   - 治理 [instrumentation](../documents/instrumentation.md)，明确内部实现所需的数据记录约定
3. 治理内部设计
   - 单模块 SDK 治理项目级 [class-design](../documents/class-design.md)
   - 多模块 SDK 按 [architecture](../documents/architecture.md) 定义的模块依赖关系，先治理被依赖的模块
   - 多模块 SDK 的每个模块内部按 [module](../document-sets/module.md) 文档组规定的顺序治理
4. 治理整体验证
   - 在内部设计明确后，治理项目级 [testcase](../documents/testcase.md)
5. 完成分发、发布与指南
   - 完成已选用的 [infrastructure](../documents/infrastructure.md)、[security](../documents/security.md) 的其余设计
   - 完成 [distribution](../documents/distribution.md) 的其余设计
   - 在前述设计明确后，治理已选用的 [release](../documents/release.md)
   - 在对外契约与制品接入约定明确后，治理 [integration-guide](../documents/integration-guide.md)
   - 在使用流程明确后，治理已选用的 [user-manual](../documents/user-manual.md)
   - 在运营所需的数据、接口与操作约束明确后，治理已选用的 [ops-guide](../document-sets/ops-guide.md)
6. 完善文档入口
   - 在项目设计明确后，按 [readme](../documents/readme.md) 完善项目级文档入口 `docs/README.md`

### 3.2 SDK 与后台共同设计

1. 治理 SDK 的 [interface](../documents/interface.md)，明确对调用方提供的能力
2. 根据 SDK 对外契约，治理整体 [architecture](../documents/architecture.md)
   - 明确两端职责、边界与协作关系
3. 根据整体职责与依赖关系治理两端设计
   - SDK 调用后台能力时，先明确后台 [interface](../documents/interface.md)，再治理依赖该契约的 SDK 实现
   - `sdk/` 的后续设计按 [§3.1](#31-纯客户端-sdk) 治理
   - `backend/` 按 [backend-service](backend-service.md) 的治理顺序治理
   - 两端的 release、各类指南与共同文档入口在第 4、5 步治理
4. 完成发布与指南
   - 两端设计、分发与部署方案明确后，按 [§2.2](#22-sdk-与后台共同设计) 的仓库边界治理已选用的 [release](../documents/release.md)
   - 根据两端契约与接入约定，分别治理所需的 [integration-guide](../documents/integration-guide.md)
   - 在使用流程明确后，治理已选用的 [user-manual](../documents/user-manual.md)
   - 在运营所需的数据、接口与操作约束明确后，治理已选用的 [ops-guide](../document-sets/ops-guide.md)
5. 按 [readme](../documents/readme.md) 完善共同文档入口 `docs/README.md`

## 4 检查条件

- [ ] 支撑运营分析的业务数据记录机制已设计，记录时机、数据内容、数据去向与责任方明确
- [ ] 所选项目形态下，必要条件成立的文档与文档组均已建立
- [ ] 文档位置符合所选项目形态的层级树，内部文件组成符合对应文档组或引用规则
- [ ] 后续设计依赖的契约与约束，均能定位到已经明确的上游文档
- [ ] 指南的使用对象与用途明确，内容符合所选文档设计，引用的设计依据一致
- [ ] 共同设计时，SDK 调用后台的设计引用后台 [interface](../documents/interface.md)，并符合其契约
- [ ] 共同设计时，release 的位置与版本边界符合两端代码的仓库组织方式
