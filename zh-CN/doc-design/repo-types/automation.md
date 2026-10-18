# 自动化服务

## 1 适用范围

适用于以接收指令或响应触发、自动完成业务任务为主要用途的项目
常见于基于 IM 交互的自动化工作流

## 2 项目结构

```text
<项目>/
├─ docs/
│  ├─ design/
│  │  ├─ command/              用户命令交互与处理设计
│  │  ├─ event/                后台触发与事件处理设计
│  │  ├─ module-<标识>/        每个业务模块的契约、实现与测试
│  │  ├─ architecture.md       模块职责划分与协作关系
│  │  ├─ deployment.md         部署、升级与恢复流程
│  │  ├─ infrastructure.md     定义需要构建或依赖的基础设施
│  │  ├─ instrumentation.md   业务数据记录、采集去向与责任
│  │  ├─ release.md            验证、合并与版本固化流程
│  │  ├─ security.md           安全设计
│  │  └─ testcase.md           项目整体行为的黑盒测试
│  ├─ ops-guide/            运营指南，按需设置
│  │  ├─ README.md          运营指南入口
│  │  ├─ data-collection.md 原始数据来源与定义
│  │  ├─ data-analysis.md   指标与分析方法
│  │  └─ ops-actions.md     允许执行的运营动作
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
| `architecture.md` | 拆分业务模块 | [architecture](../documents/architecture.md) |
| `command/` 文档组 | 存在用户实时参与的命令交互 | [command](../document-sets/command.md) |
| `deployment.md` | 需要部署运行 | [deployment](../documents/deployment.md) |
| `event/` 文档组 | 存在后台事件、消息订阅、webhook 或定时触发 | [event](../document-sets/event.md) |
| `infrastructure.md` | 始终必需 | [infrastructure](../documents/infrastructure.md) |
| `instrumentation.md` | 始终必需 | [instrumentation](../documents/instrumentation.md) |
| `module-<标识>/` 文档组 | 拆分业务模块 | [module](../document-sets/module.md) |
| `ops-guide/` 文档组 | 运营或数据平台使用者需要数据收集、分析判断或运营操作指导 | [ops-guide](../document-sets/ops-guide.md) |
| `release.md` | 需要发布版本 | [release](../documents/release.md) |
| `security.md` | 存在凭据、权限、敏感数据或不可信输入 | [security](../documents/security.md) |
| `testcase.md` | 需要验证跨命令、事件或模块的整体行为 | [testcase](../documents/testcase.md) |
| `reference/` | 存在必须随仓保存的外部原件 | [ssot](../documents/ssot.md) |

## 3 治理顺序

1. 确定入口与对外行为
   - 先治理已选用的 [command](../document-sets/command.md)、[event](../document-sets/event.md) 文档组的注册表与对外契约
   - 处理流程与测试在其依赖的契约与约束明确后治理，见第 4 步
2. 确定职责划分与运行约束
   - 根据入口契约治理已选用的 [architecture](../documents/architecture.md)，形成后再治理各模块
   - 在治理模块与入口处理设计前，先治理它们依赖的 [infrastructure](../documents/infrastructure.md) 内容
   - 先治理已选用的 [security](../documents/security.md)、[deployment](../documents/deployment.md) 中影响模块与入口处理设计的约束
   - 治理 [instrumentation](../documents/instrumentation.md)，明确内部实现所需的数据记录约定
3. 治理模块设计
   - 未选用 [module](../document-sets/module.md) 文档组时，跳过本步
   - 按 [architecture](../documents/architecture.md) 定义的模块依赖关系，先治理被依赖的模块
   - 每个模块内部按 [module](../document-sets/module.md) 文档组规定的顺序治理
4. 完成入口处理设计
   - 在入口处理依赖的契约与约束明确后，完成已选用的 [command](../document-sets/command.md)、[event](../document-sets/event.md) 文档组的其余设计
5. 完成整体验证与交付设计
   - 在入口处理设计完成后，治理已选用的 [testcase](../documents/testcase.md)
   - 完成 [infrastructure](../documents/infrastructure.md) 的其余设计
   - 完成已选用的 [security](../documents/security.md)、[deployment](../documents/deployment.md) 的其余设计
   - 在前述已选用的设计明确后，治理已选用的 [release](../documents/release.md)
   - 在运营所需的数据、接口与操作约束明确后，治理已选用的 [ops-guide](../document-sets/ops-guide.md)
6. 完善文档入口
   - 在项目设计明确后，按 [readme](../documents/readme.md) 完善项目级文档入口 `docs/README.md`

## 4 检查条件

- [ ] 支撑运营分析的业务数据记录机制已设计，记录时机、数据内容、数据去向与责任方明确
- [ ] 第二章中条件成立的文档与文档组均已建立
- [ ] 文档位置符合第二章的层级树，文档组内部的文件组成符合对应组规则
- [ ] 后续设计依赖的契约与约束，均能定位到已经明确的上游文档
