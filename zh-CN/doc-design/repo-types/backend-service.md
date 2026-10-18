# 后端服务

## 1 适用范围

适用于以向其他程序提供远程调用能力为主要用途的项目
常见项目形态包括 Web API 服务与 RPC 服务

## 2 项目结构

```text
<项目>/
├─ docs/
│  ├─ design/
│  │  ├─ module-<标识>/        每个业务模块的契约、实现与测试
│  │  ├─ architecture.md       模块职责划分与协作关系
│  │  ├─ class-design.md       单模块服务的内部实现与白盒测试
│  │  ├─ deployment.md         部署、升级与恢复流程
│  │  ├─ infrastructure.md     基础设施、资源与接入约定
│  │  ├─ instrumentation.md   业务数据记录、采集去向与责任
│  │  ├─ interface.md          项目对外的远程接口契约
│  │  ├─ release.md            验证、合并与版本固化流程
│  │  ├─ security.md           安全设计
│  │  └─ testcase.md           项目对外行为的黑盒测试
│  ├─ ops-guide/            运营指南，按需设置
│  │  ├─ README.md          运营指南入口
│  │  ├─ data-collection.md 原始数据来源与定义
│  │  ├─ data-analysis.md   指标与分析方法
│  │  └─ ops-actions.md     允许执行的运营动作
│  ├─ user-guide/
│  │  └─ integration-guide.md  调用方接入指南
│  └─ README.md                项目文档入口
├─ reference/                  必须随仓保存的外部原件
├─ CHANGELOG.md                已发布版本的变化记录
├─ CONTEXT.md                  项目术语
├─ README.md                   项目入口与工程类型标识
├─ ROADMAP.md                  当前版本状态与后续版本目标
├─ SSOT.md                     外部依据及其真实出处
└─ …                           源码、测试代码与构建配置按实际技术栈组织
```

| 文件或文档组 | 必要条件 | 行文参考 |
| --- | --- | --- |
| `CHANGELOG.md` | 始终必需 | [changelog](../documents/changelog.md) |
| `CONTEXT.md` | 始终必需 | [context](../documents/context.md) |
| `README.md`（各层） | 始终必需 | [readme](../documents/readme.md) |
| `ROADMAP.md` | 始终必需 | [roadmap](../documents/roadmap.md) |
| `SSOT.md` | 设计依赖外部依据 | [ssot](../documents/ssot.md) |
| `architecture.md` | 服务包含多个业务模块 | [architecture](../documents/architecture.md) |
| `class-design.md` | 服务未拆分为多个业务模块 | [class-design](../documents/class-design.md) |
| `deployment.md` | 需要部署运行 | [deployment](../documents/deployment.md) |
| `infrastructure.md` | 始终必需 | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | 始终必需 | [instrumentation](../documents/instrumentation.md) |
| `interface.md` | 始终必需 | [interface](../documents/interface.md) |
| `module-<标识>/` 文档组 | 服务包含多个业务模块 | [module](../document-sets/module.md) |
| `ops-guide/` 文档组 | 运营或数据平台使用者需要数据收集、分析判断或运营操作指导 | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | 需要发布版本 | [release](../documents/release.md) |
| `security.md` | 始终必需 | [security](../documents/security.md) |
| `testcase.md` | 始终必需 | [testcase](../documents/testcase.md) |
| `integration-guide.md` | 接口交付给仓库外部的接入者 | [integration-guide](../documents/integration-guide.md) |
| `reference/` | 存在必须随仓保存的外部原件 | [ssot](../documents/ssot.md) |

## 3 治理顺序

1. 治理对外契约
   - 先治理项目级 [interface](../documents/interface.md)
2. 治理职责划分与运行约束
   - 根据对外契约治理已选用的 [architecture](../documents/architecture.md)，形成后再治理各模块
   - 在治理内部实现前，先治理其依赖的 [infrastructure](../documents/infrastructure.md) 内容
   - 先治理 [security](../documents/security.md) 与已选用的 [deployment](../documents/deployment.md) 中影响内部实现的约束
   - 治理 [instrumentation](../documents/instrumentation.md)，明确内部实现所需的数据记录约定
3. 治理内部设计
   - 单模块服务治理项目级 [class-design](../documents/class-design.md)
   - 多模块服务按 [architecture](../documents/architecture.md) 定义的模块依赖关系，先治理被依赖的模块
   - 多模块服务的每个模块内部按 [module](../document-sets/module.md) 文档组规定的顺序治理
4. 治理整体验证
   - 在内部设计明确后，治理项目级 [testcase](../documents/testcase.md)
5. 完成交付设计
   - 完成 [infrastructure](../documents/infrastructure.md)、[security](../documents/security.md) 与已选用的 [deployment](../documents/deployment.md) 的其余设计
   - 在前述设计明确后，治理已选用的 [release](../documents/release.md)
   - 在对外契约与接入所需的运行约定明确后，治理已选用的 [integration-guide](../documents/integration-guide.md)
   - 在运营所需的数据、接口与操作约束明确后，治理已选用的 [ops-guide](../document-sets/ops-guide.md)
6. 完善文档入口
   - 在项目设计明确后，按 [readme](../documents/readme.md) 完善项目级文档入口 `docs/README.md`

## 4 检查条件

- [ ] 支撑运营分析的业务数据记录机制已设计，记录时机、数据内容、数据去向与责任方明确
- [ ] 第二章中条件成立的文档与文档组均已建立
- [ ] 文档位置符合第二章的层级树，文档组内部的文件组成符合对应组规则
- [ ] 后续设计依赖的契约与约束，均能定位到已经明确的上游文档
