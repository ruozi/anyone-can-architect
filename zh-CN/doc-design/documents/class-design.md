# 文档设计：class-design

## 1 文档定位

一个模块内部的解决方案设计
负责指导模块内部的全部实现细节的无歧义实现
其中必须包含 interface 定义的每个对外能力怎样实现

模块对外的能力定义归 [interface](interface.md)
对外契约的黑盒测试归 [testcase](testcase.md)
内部机制的白盒测试写在本文最后一章，按[测试用例](../patterns/testcase.md)展开
顶层模块之间怎样协作归 [architecture](architecture.md)
有子模块时，本文定义内部组成与子模块协作，子模块的实现归其自身的 class-design，分工见 [module 文档组](../document-sets/module.md#23-父子职责)

## 2 文档结构

对「内部机制」[层层深入](../../skills/references/drill-down.md)，分出的 [chapter](../../CONTEXT.md#chapter) 数量不限，往下是 [section](../../CONTEXT.md#section)，再往下是 [subsection](../../CONTEXT.md#subsection)
「对外能力」的 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section) 与 interface 一一对应，排在「内部机制」之后，对每个 [section](../../CONTEXT.md#section) [层层深入](../../CONTEXT.md#drill-down)
有子模块时，「内部机制」的第一个 [chapter](../../CONTEXT.md#chapter) 为「内部组成」，以模块表列出子模块、能力与责任边界，以关系表列出子模块之间的协作，子模块名链接对应 README
最后一章为「内部测试」，根据本文定义的内部结构与处理机制设计白盒测试
整章按[测试用例](../patterns/testcase.md) pattern 展开，依次写夹具、测试场景与测试用例

结构示意：

```text
「内部机制」               对它层层深入，分出以下 chapter
## 1 <内部机制的一部分>
## 2 <内部机制的一部分>
…                          分出几个 chapter 随解决方案
## N-1 <一类业务>          对应 interface 的一个 chapter
### N-1.1 <接口>           对应 interface 的一个 section · 对它层层深入
#### N-1.1.1 <细分>        按需
## N <接口>                interface 里 chapter 本身是接口时同样 · 对它层层深入
## N+1 内部测试            按测试用例 pattern 展开，内容降一层标题
```

## 3 行文步骤

1. 理解所有 interface 定义的对外能力，以及实现它们要什么、依赖哪些下游模块或外部系统
2. 定大致行文结构（非精确的章节结构）
   - 明确结构：实现设计分成「内部机制」与「对外能力」两个大块，最后追加「内部测试」一章
   - 其中「对外能力」是按 interface 一一对应排出 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section)，但是具体章节编号未知（需要依赖「内部机制」的最终排布）
3. 对「内部机制」[层层深入](../../CONTEXT.md#drill-down)：分出的 [chapter](../../CONTEXT.md#chapter)、[section](../../CONTEXT.md#section) 与 [subsection](../../CONTEXT.md#subsection) 在这一步定
   - 明确正向机制、机制固有的失败分支、保证、边界条件与阈值，验证场景写在测试部分
   - 有子模块时，先写「内部组成」，子模块的能力链接子级 interface，不复述其签名与实现
   - 只定义本模块拥有的数据结构
   - 与依赖模块或外部系统的交互只写本模块发出的调用和收到的结果，不描述对方内部
4. 对每个「对外能力」依次[层层深入](../../CONTEXT.md#drill-down)：每个对应 interface 的 [chapter](../../CONTEXT.md#chapter) 或 [section](../../CONTEXT.md#section)，写这个接口怎样实现
   - 对外结果只用 interface 已声明的结果，内部错误到它们的映射写清
   - interface 里的类型与签名只链接不复述
   - 「内部机制」已说明的内容只引用不重复
5. 写「内部测试」
   - 从内部结构与处理机制列出待验证的分支、状态转移、错误映射与不变量
   - 按[测试用例](../patterns/testcase.md) pattern 定义夹具、列出场景并展开用例，设计依据链接本文对应设计位置
   - 明确测试的驱动入口与观察点，按需使用内部入口、状态与依赖替身
   - 对外契约已经定义的黑盒场景引用 testcase，不重复展开
   - 有子模块时，验证子模块之间的组合与协作，子模块自身的契约与实现由子级文档验证
6. 通篇核对 [chapter](../../CONTEXT.md#chapter) 编号：「内部机制」之后依次为「对外能力」与「内部测试」，编号连续，「对外能力」的 [section](../../CONTEXT.md#section) 顺序与 interface 一致

## 4 示例

与 interface 示例里的订单模块配对，「对外能力」三章与那份 interface 同形：

| 章节 | pattern |
| --- | --- |
| `## 1 模块结构` | [分层视图](../patterns/layered-view.md)的分层模块依赖视图 |
| `## 2 订单状态机` | [状态机](../patterns/state-machine.md) |
| `## 3 库存预占记录` | [模块接口](../patterns/interface.md)的数据结构说明 |
| `## 4 订单受理` | 只有标题 |
| `### 4.1 创建订单` | [时序图](../patterns/sequence-diagram.md) |
| `### 4.2 取消订单` | 编号列表 |
| `## 5 库存协作` | 只有标题 |
| `### 5.1 预占库存` | [时序图](../patterns/sequence-diagram.md) |
| `### 5.2 预占结果回调` | [流程图](../patterns/flowchart.md) |
| `## 6 查询订单状态` | 代码 |
| `## 7 内部测试` | [测试用例](../patterns/testcase.md) |

## 5 检查条件

- [ ] 「对外能力」的 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section) 与 interface 一一对应，排在「内部机制」之后，编号连续
- [ ] 「内部机制」与每个「对外能力」都层层深入到叶子，模块的实现只有一种
- [ ] 没有复述 interface 的类型与签名
- [ ] 内部机制的保证、边界条件与阈值明确，验证场景集中在测试部分
- [ ] 最后一章为「内部测试」，根据内部设计验证分支、状态转移、错误映射与不变量，满足测试用例 pattern
- [ ] 对外结果都是 interface 已声明的，内部错误到它们的映射写清了
- [ ] 有子模块时，第一章为「内部组成」，与子模块目录一致，子模块的能力只链接子级 interface
- [ ] 只定义本模块拥有的数据结构
- [ ] 与依赖模块或外部系统的交互只有本模块发出的调用和收到的结果
- [ ] 「对外能力」没有复述「内部机制」已说明的内容
