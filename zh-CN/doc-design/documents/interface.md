# 文档设计：interface

## 1 文档定位

一个单元对外的接口契约，调用方只读它就能正确使用该单元
单元可以大到整个项目，小到项目内的任何一个模块

单元的定位与价值归 [readme](readme.md)
内部实现与内部机制的白盒测试归 [class-design](class-design.md)
对外契约的黑盒测试归 [testcase](testcase.md)
模块间拓扑归 [architecture](architecture.md)

## 2 文档结构

只有 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section) 两层
一个 [chapter](../../CONTEXT.md#chapter) 下没有 [section](../../CONTEXT.md#section) 或有两个以上的 [section](../../CONTEXT.md#section)

结构示意：

```text
## 1 公共契约           按需 · 数据契约
## 2 <一类业务>
### 2.1 共用契约        按需 · 数据契约
### 2.2 <接口>          模块接口
### 2.3 <接口>          模块接口
## 3 <接口>             业务只有一个接口时 chapter 本身就是接口 · 模块接口
```

- 公共契约 [chapter](../../CONTEXT.md#chapter)：被不同业务的接口共用的契约
- 一类业务的 [chapter](../../CONTEXT.md#chapter)：每个接口一个 [section](../../CONTEXT.md#section)
  - 共用契约 [section](../../CONTEXT.md#section)：这类业务共用的契约

## 3 行文步骤

1. 理解并列出全部内容，先不动笔
   - 理解业务：每个接口服务什么业务
   - 理解数据结构：每个接口用到的数据结构
2. 决定公共契约
   - 有被不同业务的接口共用的数据结构或校验契约：作为第一个 [chapter](../../CONTEXT.md#chapter)，按数据契约 pattern 写
   - 没有：跳过
3. 划分 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section)
   - 按业务把接口归成几个 [chapter](../../CONTEXT.md#chapter)，名字用业务语言，不用协议动词、路径或方法名
   - 只含一个接口的 [chapter](../../CONTEXT.md#chapter) 就是这个接口，不设 [section](../../CONTEXT.md#section)
   - 含多个接口的 [chapter](../../CONTEXT.md#chapter) 内有被多个接口共用的数据结构或校验契约：作为它的第一个 [section](../../CONTEXT.md#section)，按数据契约 pattern 写
   - 含多个接口的 [chapter](../../CONTEXT.md#chapter) 一个接口一个 [section](../../CONTEXT.md#section)，名字用业务语言
4. 逐个写接口：按模块接口 pattern 写，不加解释性说明，不列举调用方

## 4 示例

项目级 interface，有公共契约 [chapter](../../CONTEXT.md#chapter)，订单受理有共用契约 [section](../../CONTEXT.md#section)：

| 章节 | pattern |
| --- | --- |
| `## 1 公共契约` | 只有标题 |
| `### 1.1 错误体与错误码` | [数据契约](../patterns/schema.md) |
| `### 1.2 公共类型` | [数据契约](../patterns/schema.md) |
| `## 2 订单受理` | 只有标题 |
| `### 2.1 订单共用类型` | [数据契约](../patterns/schema.md) |
| `### 2.2 创建订单` | [模块接口](../patterns/interface.md) |
| `### 2.3 取消订单` | [模块接口](../patterns/interface.md) |
| `### 2.4 订单状态变更通知` | [模块接口](../patterns/interface.md) |
| `## 3 订单查询` | 只有标题 |
| `### 3.1 查询订单` | [模块接口](../patterns/interface.md) |
| `### 3.2 查询订单列表` | [模块接口](../patterns/interface.md) |

模块级 interface，没有公共契约，查询订单状态这个 [chapter](../../CONTEXT.md#chapter) 本身是一个接口：

| 章节 | pattern |
| --- | --- |
| `## 1 订单受理` | 只有标题 |
| `### 1.1 创建订单` | [模块接口](../patterns/interface.md) |
| `### 1.2 取消订单` | [模块接口](../patterns/interface.md) |
| `## 2 库存协作` | 只有标题 |
| `### 2.1 预占库存` | [模块接口](../patterns/interface.md) |
| `### 2.2 预占结果回调` | [模块接口](../patterns/interface.md) |
| `## 3 查询订单状态` | [模块接口](../patterns/interface.md) |

## 5 检查条件

- [ ] 只有 [chapter](../../CONTEXT.md#chapter) 与 [section](../../CONTEXT.md#section) 两层，没有一个 [chapter](../../CONTEXT.md#chapter) 只有一个 [section](../../CONTEXT.md#section)
- [ ] [chapter](../../CONTEXT.md#chapter) 名与 [section](../../CONTEXT.md#section) 名是业务语言，没有协议动词、路径或方法名
- [ ] 契约类型按使用范围归属，公共契约 [chapter](../../CONTEXT.md#chapter) 里没有只被一个 [chapter](../../CONTEXT.md#chapter) 使用的类型，共用契约 [section](../../CONTEXT.md#section) 里没有只被一个接口使用的类型
- [ ] 没有列举调用方
- [ ] architecture 工况中调用到的接口都在本文档中，本文档列出的接口都有工况触发
