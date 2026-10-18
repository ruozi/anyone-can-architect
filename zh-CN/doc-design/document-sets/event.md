# 文档组：event

## 1 适用场景

无用户实时参与的后台事件、消息订阅、webhook 与定时任务

用户直接参与的交互使用 [command](command.md) 文档组

## 2 文档组成

事件文档放在 `docs/design/event/`，用[层级树](../patterns/hierarchy-tree.md)表达目录结构
调度中心固定为 `00-mediator.md`
事件文件从 `01` 开始使用两位数字编号

```text
event/
├─ README.md
├─ 00-mediator.md
├─ 01-overdue.md
└─ 02-weekly-report.md
```

| 文件 | 职责 | 文档设计 |
| --- | --- | --- |
| README.md | 触发方式、事件注册表与共用约定 | [readme](../documents/readme.md) |
| 00-mediator.md | 事件受理、分发与恢复 | [event-mediator](../documents/event-mediator.md) |
| 每个事件文件 | 单个事件的触发、处理、输出与失败处置 | [event](../documents/event.md) |

## 3 设计顺序

1. 确定事件文件清单
2. 按 [readme](../documents/readme.md) 文档设计建立事件注册表
3. 按 [§2](#2-文档组成) 引用的文档设计编写调度中心与各事件
4. 完善 README

## 4 检查条件

- [ ] 事件文件与注册表一一对应
- [ ] 各文件满足对应文档设计
- [ ] 调度中心固定为 `00-mediator.md`
