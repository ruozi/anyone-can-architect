# Context

## Language

### repo-type

工程类型
一个工程只属于一种，由它的工程形态判定；类型决定这个工程的标准文档结构——要哪些文档、每篇按哪个文档设计写、按什么顺序写
登记在 `doc-design/repo-types/`，项目侧记在 aca-footer；英文键 `repo-type` 是历史标识，沿用
_Avoid_: 「仓库类型」「项目类型」

### repo-type-spec

类型规则
一种工程类型的标准文档结构的载体，即 `doc-design/repo-types/{repo-type}.md`：登记这类工程的文档清单与每篇对应的文档设计、根目录允许哪些文件、设计顺序和导读顺序
_Avoid_: 「类型 README」「repo-type README」

### document-set

文档组（Document Set）是一组共同描述某个设计对象的文档
规定包含哪些文件、各文件的职责与关系，以及设计顺序
规则放在 `doc-design/document-sets/`，由工程类型按需选用
每个文件的写法引用对应文档设计
_Avoid_: 用「模块」统称 module、command、event 文档组

### doc-design

文档设计是单篇设计文档的组织规则
规定分哪些章、每章用哪个 pattern 表达、按什么步骤编写，以及检查条件
规则放在 `doc-design/documents/`，由工程类型与文档组选用
_Avoid_: 「outline」「大纲」「模板」——文档设计给出的章节骨架是判据，不是可替换的样式

### pattern

某一类问题或解决方案的最佳行文单元
一类内容反复出现（一个状态机、一次多方时序、一套 API、一张卡片），它就有一种最佳写法，pattern 把这个写法定死：用最容易被人理解的行文格式，无冗余、无遗漏、无歧义地把这个单元的设计表达清楚，并说明什么情况选它
跨工程类型复用；粒度是文档内的一段内容，被文档设计引用，一个文档设计可引用多个 pattern
_Avoid_: 「图型」「样式」——形态是 pattern 的结果，不是 pattern 本身

### card-mockup

卡片示意（card mockup）
设计文档中用 HTML 和具体示例模拟卡片预期外观的视觉模型，展示布局、文案、数据与控件，帮助读者直观理解设计，并指导卡片 JSON 的实现；具体表达规则由 `lark-card-mockup` pattern 规定

### module

模块是多模块项目里按业务能力切出的设计单元
一个模块一个目录 `docs/design/module-{X}/`，自带完整的对外契约、内部设计与验证
architecture 定义模块划分与拓扑，模块内部由各自的设计文档展开
工程类型决定何时使用模块，目录组成由 module 文档组规定
_Avoid_: 把 module 当代码里的类、文件或独立服务

### axiom

注入式公理
不属于任何一篇文档或一个流程、整套方法论都要守的底线，靠机制注入而不靠引用生效
行文公理 build 时注入设计类 skill 正文、部署时前置进每篇文档设计；完整性公理只注入设计类 skill
源平铺在 `axioms/`，注入到哪里由 [axioms/README.md](axioms/README.md) 登记

### chapter

章
`## N 标题`，文档在标题之下的第一层划分，对应 ISO 2145 的 division、GB/T 1.1 的章
_Avoid_: 「部分」「一级标题」

### section

节
`### N.N 标题`，章之下的第二层划分，对应 ISO 2145 的 subdivision、GB/T 1.1 的条
_Avoid_: 「小节」「二级标题」「条」

### subsection

小节
`#### N.N.N 标题`，节之下的第三层划分，最深一层，只在 pattern 规定的块里出现
_Avoid_: 「三级标题」

### drill-down

层层深入，从问题或需求的整体出发，逐步拆解并细化解决方式，直到能直接实现
文档设计写「对 X 层层深入」指明需要展开的内容
_Avoid_: 「下钻」「递归展开」「入口」

### aca-footer

项目根 README 的最后一行
它是项目被 Anyone Can Architect 设计的标志，登记所用的 Anyone Can Architect 版本与 repo-type，是 repo-type 的唯一事实来源，其他文件、目录和代码只能辅助首次识别，不能覆盖它；仓库自己的版本行紧贴在它上面
_Avoid_: 「印记」「标记」「版本区块」

## Relationships

- [repo-type](#repo-type) has one [repo-type-spec](#repo-type-spec)（类型的全部规则从这一份进入）
- [repo-type-spec](#repo-type-spec) 选用 [document-set](#document-set) 与单篇 [doc-design](#doc-design)，并规定根目录允许的文件与项目整体的设计、导读顺序
- [document-set](#document-set) 组织多篇 [doc-design](#doc-design)，规定组内的文件职责与设计顺序
- [doc-design](#doc-design) references many [pattern](#pattern)（一篇文档内的各段内容各套其表达方式）
- [pattern](#pattern) may reference another [pattern](#pattern)（交出一个内容单元，写明触发条件）
- [doc-design](#doc-design) 引用层层深入的指导原则，指明对哪些部分 [drill-down](#drill-down)
- [module](#module) 使用 module [document-set](#document-set)，由 [repo-type-spec](#repo-type-spec) 决定何时使用
- [aca-footer](#aca-footer) 决定项目的 [repo-type](#repo-type)
- [chapter](#chapter) contains many [section](#section)，[section](#section) contains many [subsection](#subsection)，文档设计只规定到 section

## Flagged ambiguities

- 整篇文档的结构规则归 [doc-design](#doc-design)，不归 [pattern](#pattern)；pattern 只管内容级表达——历史上 integration-guide 与 ssot 曾错放在 patterns，已归位
- 「治理」曾同时指产出设计文档的动作、运维管理和人工维护 — resolved：产出物视角统一叫「设计」，目录 `doc-governance/` 改名 `doc-design/`；运维语义写「约束 / 管理」，人工维护写「维护」，能力范围写「支持」
- 「SSOT」在实践仓里被用于三个不同对象：根目录外部依据 `SSOT.md`、项目自建的跨模块内部标准目录（如 `docs/ssot/`）、以及「作为设计事实源的契约文档」 — 当前规则：根 `SSOT.md` 只收外部依据；后两种用法说明跨模块内部标准在 Anyone Can Architect 里没有指定归属，待裁决
- 项目 CONTEXT 的术语收录范围与写法，按 [context 文档设计](doc-design/documents/context.md)执行
- 「文档设计」与「设计文档」 — resolved：文档设计是 Anyone Can Architect 里规定一篇文档怎么写的规则，设计文档是项目按规则写出的产物（`docs/design/`）；反馈字段 `target_outline` 与反馈类型 `outline-diff` 是既有数据契约，沿用
