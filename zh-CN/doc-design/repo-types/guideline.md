# 规范仓库

## 1 适用范围

适用于部门规范、团队指南和规则集合

主要交付对象为产品或服务时，按对应工程类型治理

## 2 项目结构

以下为组织示例，规范文件与目录按实际主题安排，由项目入口明确位置

```text
<项目>/
├─ <交付对象>/       独立交付的非文档对象，按需设置
│  └─ CHANGELOG.md   对象变更、兼容影响与迁移说明
├─ <规范主题>/       按主题组织的规范正文
│  ├─ README.md      主题入口，按需设置
│  └─ <规范>.md      具体规范与使用要求
├─ reference/        必须随仓保存的外部原件
├─ CONTEXT.md        项目术语
├─ README.md         项目入口与工程类型标识
└─ SSOT.md           外部依据及其真实出处
```

| 文件或文档组 | 必要条件 | 行文参考 |
| --- | --- | --- |
| `CONTEXT.md` | 始终必需 | [context](../documents/context.md) |
| 根 `README.md` | 始终必需 | [readme](../documents/readme.md) |
| 主题 `README.md` | 需要说明主题职责或提供主题内导航 | [readme](../documents/readme.md) |
| `SSOT.md` | 规范依赖外部依据 | [ssot](../documents/ssot.md) |
| `<规范>.md` | 始终必需，按实际主题组织 | [guideline](../documents/guideline.md) |
| `<交付对象>/CHANGELOG.md` | 非文档对象存在独立交付方与消费者 | [changelog](../documents/changelog.md) |
| `reference/` | 存在必须随仓保存的外部原件 | [ssot](../documents/ssot.md) |

guideline 不创建、保留或读取 `ROADMAP.md`
guideline 根目录不创建、保留或读取 `CHANGELOG.md`
对象级记录说明消费者需要获知的变更摘要、兼容影响和迁移动作
