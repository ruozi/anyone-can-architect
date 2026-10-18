# 项目外部依据

## 1 行文规范

- [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)：规定中文全角标点、中英文与数字间的空格及排版一致性，直角引号「」是可用的引号形式
- [ISO 2145](https://www.iso.org/standard/26533.html)：规定章节编号如 `1`、`1.1`，编号末尾不带点，并规定编号的引用方式
- [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/STE_faq.html)：通过受控词汇、单句单一主题、直接操作指令与条件前置减少技术英语的歧义
- [Google Developer Documentation Style Guide](https://developers.google.com/style)：规定开发者文档的语言风格、措辞、格式与组织方式

## 2 文档结构

- [The Pyramid Principle](https://www.barbaraminto.com/concept)（Barbara Minto）：按金字塔组织思想，先整体后细节、先结论后依据

## 3 术语治理

- [Ubiquitous Language](https://martinfowler.com/bliki/UbiquitousLanguage.html)（Martin Fowler）：开发者与业务方共同建立明确的领域语言，在交流中检验歧义，并随领域理解更新
- [W3C SKOS Primer](https://www.w3.org/TR/skos-primer/#secconcept)：区分概念与名称，为同一概念维护不同语言的首选名称、替代名称、说明与语义关系

## 4 设计与可维护性

- [Simon, The Architecture of Complexity, 1962](https://www.jstor.org/stable/985254)：复杂系统具有层级与近可分解结构，层级形成稳定中间形态，下层细节以总量影响上层，描述先轮廓后细节
- [Parnas, 模块分解准则, 1972](https://dl.acm.org/doi/10.1145/361598.361623)：模块按职责分配，从难做或会变的决定出发划分，分别隐藏决定，接口尽量少暴露
- [Ousterhout, 软件设计哲学, 2018](https://web.stanford.edu/~ouster/cgi-bin/book.php)：复杂性表现为难理解、难修改及改动放大、认知负担与未知的未知，深模块用小接口隐藏复杂性
- [Stevens, Myers, Constantine, Structured Design, 1974](https://doi.org/10.1147/sj.132.0115)：以高内聚、低耦合组织设计，形式随功能，用造句检验职责划分
- [Dijkstra, THE 系统的结构, 1968](https://dl.acm.org/doi/10.1145/363095.363143)：按抽象层次组织系统，故障与正常情况一起设计

## 5 理念

- [Garry Tan, Boil the Ocean](https://garryslist.org/posts/boil-the-ocean)：AI 降低工作的成本，使过去代价过高的完整目标值得追求

## 6 API 设计

- [RFC 9110（HTTP 语义）](https://www.rfc-editor.org/rfc/rfc9110)：定义 HTTP 方法、状态码、字段及安全性与幂等性等语义
- [OWASP API Security Top 10](https://owasp.org/API-Security/)：归纳 API 常见安全风险，包括授权、认证、资源消耗与配置问题

## 7 平台与工具

- [Mermaid 官方语法](https://mermaid.ai/open-source/)：定义各类图的文本语法、配置与渲染方式
- [GitHub REST API：Issues](https://docs.github.com/en/rest/issues/issues)：定义 Issue 的创建、列表查询与鉴权方式
- [飞书发送消息](https://open.feishu.cn/document/server-docs/im-v1/message/create)：定义消息发送接口、消息类型、请求参数与消息体容量限制
- [飞书卡片 Card 2.0 JSON 结构](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)：定义卡片的 JSON 结构、配置、标题、正文组件与元素数量限制

- [Antigravity Agent Skills](https://www.antigravity.google/docs/skills?tab=ide)：定义 SKILL.md 格式及 IDE、2.0 与 CLI 的技能发现目录

## 8 版本

- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)：按版本整理对使用者有意义的变化，区分未发布内容与已发布记录，并按变更类型组织
- [Semantic Versioning](https://semver.org/lang/zh-CN/)：按兼容性变化、功能增加与问题修复区分主版本、次版本与修订版本
