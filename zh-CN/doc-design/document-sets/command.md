# 文档组：command

## 1 适用场景

用户在即时通讯中通过自然语言、菜单或卡片操作发起命令

无用户实时参与的后台触发使用 [event](event.md) 文档组

## 2 文档组成

命令文档放在 `docs/design/command/`，用[层级树](../patterns/hierarchy-tree.md)表达目录结构
固定使用 `00-routing.md`、`01-feedback.md` 与 `02-help.md`
其余命令或命令组从 `03` 开始编号
命令组按业务对象分目录，组内命令从 `01` 开始编号

```text
command/
├─ README.md
├─ 00-routing.md
├─ 01-feedback.md
├─ 02-help.md
└─ 03-task/
   ├─ README.md
   ├─ 01-create.md
   └─ 02-query.md
```

| 文件 | 职责 | 文档设计 |
| --- | --- | --- |
| README.md | 命令说明、注册表与共用规则 | [readme](../documents/readme.md) |
| 00-routing.md | 命令受理、识别、参数提取与派发 | [command-router](../documents/command-router.md) |
| 各组 README.md | 组内共用约定，有共用约定时设置 | [readme](../documents/readme.md) |
| 每个叶子命令文件 | 单个命令的处理与回复 | [command](../documents/command.md) |

## 3 设计顺序

1. 确定命令分组与文件清单
2. 按 [readme](../documents/readme.md) 文档设计建立命令注册表
3. 按 [§2](#2-文档组成) 引用的文档设计编写路由中枢与叶子命令
4. 完善各 README

## 4 检查条件

- [ ] 叶子命令文件与注册表一一对应
- [ ] 各文件满足对应文档设计
- [ ] 路由、反馈与帮助分别固定为 `00-routing.md`、`01-feedback.md` 与 `02-help.md`
