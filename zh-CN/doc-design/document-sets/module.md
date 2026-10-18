# 文档组：module

## 1 适用场景

适用于按业务能力拆分为多个模块的项目
模块内部的能力满足[拆分条件](#22-子模块)时，同样拆分为子模块

顶层模块的划分、职责边界与依赖关系由 [architecture](../documents/architecture.md) 定义
子模块的划分、职责边界与协作由直接父级的 [class-design](../documents/class-design.md) 定义

## 2 文档组成

### 2.1 模块目录

每个模块一个目录 `module-{X}/`，目录内固定四个文件
顶层模块目录为 `docs/design/module-{X}/`
`{X}` 为模块的英文标识，使用小写英文，多个单词用连字符连接
例如 `order-management`，对应目录 `module-order-management`

| 文件 | 职责 | 文档设计 |
| --- | --- | --- |
| interface.md | 模块对外契约 | [interface](../documents/interface.md) |
| class-design.md | 内部实现与内部测试，有子模块时定义内部组成与子模块协作 | [class-design](../documents/class-design.md) |
| testcase.md | 对外契约的黑盒测试 | [testcase](../documents/testcase.md) |
| README.md | 模块定位与文档导引，有子模块时链接各子模块 README | [readme](../documents/readme.md) |

### 2.2 子模块

子模块目录位于直接父级模块目录内，沿用 [§2.1](#21-模块目录) 的四个文件与命名规则，嵌套层数不设上限

```text
docs/design/module-order/
├─ README.md
├─ interface.md
├─ class-design.md
├─ testcase.md
└─ module-pricing/
   ├─ README.md
   ├─ interface.md
   ├─ class-design.md
   └─ testcase.md
```

模块内部的能力同时满足以下条件时，拆分为子模块
不满足时，留在父级 class-design，按其[公共机制条件](../documents/class-design.md#2-文档结构)决定是否单独成章

- 有独立的对外契约，调用方只读子级 interface 就能正确使用
- 持有自己的状态或算法
- 能通过子级 interface 独立进行黑盒测试

数据结构与辅助类不单独拆分为子模块

**反例**

- ❌ 子模块目录平铺在 `docs/design/` 下，与父模块同级 → 所属关系丢失，子模块目录放在直接父级模块目录内
- ❌ 没有独立契约的内部类拆分为子模块 → 不满足拆分条件，留在父级 class-design
- ❌ 父级 class-design 复述子级 interface 的签名或子级的内部实现 → 父级只引用子级 interface

### 2.3 父子职责

| 层级 | interface | class-design | testcase |
| --- | --- | --- | --- |
| 父级 | 父模块对其调用方的契约 | 内部组成、数据归属与子模块协作，子模块的能力引用子级 interface | 以父级 interface 为边界验证整体行为 |
| 子级 | 子模块对父级与同级子模块的契约 | 子模块自身的实现 | 以子级 interface 为边界验证子模块的契约与算法 |

子级 interface 不自动成为父级的对外契约，父级对外提供的能力在父级 interface 中声明
子模块之间的组合与协作，在父级 class-design 的内部测试中验证
同一测试用例只归属一个层级
目录嵌套不要求实现采用语言层面的嵌套结构

## 3 设计顺序

1. 根据 [architecture](../documents/architecture.md) 的模块划分建立顶层模块目录
2. 每个模块按以下顺序编写
   1. interface
   2. class-design，有子模块时先确定内部组成与各子模块的职责边界
   3. 按子模块之间的依赖关系编写各子模块，被依赖的子模块先编写，每个子模块同样按本步骤的顺序编写
   4. 核对父级 class-design 的子模块协作与各子级 interface 一致
   5. testcase
   6. README

## 4 检查条件

- [ ] 顶层模块目录与 architecture 的模块清单一致
- [ ] 子模块目录位于直接父级模块目录内，与父级 class-design 的内部组成一致
- [ ] 每层模块包含固定四个文件，各文件满足对应文档设计
- [ ] README 链接模块内三篇文档，有子模块时链接各子模块 README
- [ ] 每个子模块满足拆分条件，不满足的能力留在父级 class-design
- [ ] 父级 class-design 引用子级 interface，没有复述子级的契约与实现
- [ ] 父级对外提供的能力都在父级 interface 中声明
- [ ] 每层 testcase 只以本层 interface 为黑盒边界，同一测试用例只归属一个层级
