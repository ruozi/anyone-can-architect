# Drill-down 层层深入

> **从问题或需求的整体出发，逐步拆解并细化解决方式，直到能直接实现**

最终层级可以是 chapter、section 或 subsection
在该层把解决方式写到能够直接实现，不再增加标题层级

每次拆解先明确当前部分要解决的问题与范围，形成整体解决思路
再按职责划分各部分，明确每部分负责什么、各部分如何配合

- 关联紧密的内容放在一起，各部分之间只保留必要的接口
- 各部分合起来覆盖当前问题，职责不遗漏、不重叠
- 难以确定或容易变化的设计决定在所属部分明确，不推迟到实现时再决定
- 正常、失败、中断与外部依赖异常的处理在所属部分一起明确

对象、输入输出、处理规则或异常行为尚未明确时，继续细化对应内容

拆解与细化过程中，反复核对各部分的职责与配合，确认组合起来能够解决当前问题
发现职责不明确、遗漏、重叠或接口不一致时，调整整体划分与对应部分的解决方式，再继续拆解与细化

参考：

- [Simon, *The Architecture of Complexity*, 1962](../../SSOT.md#4-设计与可维护性)
- [Parnas, *On the Criteria To Be Used in Decomposing Systems into Modules*, 1972](../../SSOT.md#4-设计与可维护性)
- [Ousterhout, *A Philosophy of Software Design*, 2018](../../SSOT.md#4-设计与可维护性)
- [Stevens, Myers, Constantine, *Structured Design*, 1974](../../SSOT.md#4-设计与可维护性)
- [Dijkstra, *The Structure of the "THE"-Multiprogramming System*, 1968](../../SSOT.md#4-设计与可维护性)
