# 文档设计：interaction

## 1 文档定位

从用户视角定义产品的交互行为，使用户操作、界面状态与反馈能够被一致地理解、实现和验证

内部实现归对应的模块设计
使用指导归 [user-manual](user-manual.md)
交互行为的黑盒测试归 [testcase](testcase.md)

## 2 文档结构

第一章“使用场景”汇总用户要完成的事情、对应入口与后续章节

从第二章起，每章展开一个使用场景，按操作过程[层层深入](../../skills/references/drill-down.md)
界面示意跟随具体操作，展示操作前后的状态与反馈
多个场景共用的交互规则在一处定义，其他场景引用对应内容

以 HTML 交互示意作为主要表达方式，展示界面布局、内容、控件，以及操作触发的状态变化
能用示意表达的信息直接展示，文字补充影响交互的业务条件与行为规则
飞书卡片使用[卡片示意](../patterns/lark-card-mockup.md)

结构示意：

```text
## 1 使用场景
## 2 <使用场景>
### 2.1 <具体内容>
### 2.2 <具体内容>
#### 2.2.1 <具体内容>
#### 2.2.2 <具体内容>
## 3 <使用场景>
…
```

## 3 行文步骤

1. 确定用户、目标与使用场景
   - 按用户目标划分场景，确定入口与适用条件
   - 涉及角色差异时，说明对应的入口、操作与权限
   - 汇总场景并链接到后续对应章节
2. 梳理场景中的操作过程与分支
   - 从入口开始，确定每次操作触发的界面状态、反馈与后续操作
   - 梳理失败、中断及恢复分支
3. 制作 HTML 交互示意
   - 按具体操作展示用户可见的界面状态，使用符合场景的示例数据与文案
   - 控件、反馈位置与布局贴近实际使用环境
   - 各状态提供可直接定位的链接
   - 操作顺序、即时反馈或动态变化难以通过静态示意表达时，提供可操作的原型
4. 补充影响交互的业务条件与行为规则
   - 补充示意未表达的权限限制、校验规则与控件启用条件
   - 涉及数据保存、取消、离开或重试时，定义操作后的结果与保留内容
   - 规则紧邻对应操作或状态，共用规则引用同一处定义
5. 核对完整场景
   - 沿正常过程与各分支检查入口、状态变化、反馈及后续操作
   - 核对示意与规则一致，每项操作的触发条件与结果均有定义

## 4 示例

### 4.1 交互设计文档

````markdown
# 部门报告工具交互设计

## 1 使用场景

| 使用场景 | 入口 | 交互设计 |
| --- | --- | --- |
| 生成部门报告 | 主界面「部门报告」 | [生成部门报告](#2-生成部门报告) |

## 2 生成部门报告

### 2.1 选择报告范围

[选择范围示意](report-interaction.html#range)
[日期错误示意](report-interaction.html#invalid-range)

部门列表仅显示当前账号有权限的部门，默认选择所属部门
日期范围默认本月，部门与日期均有效时可生成报告
开始日期不得晚于结束日期，修正后清除错误并启用「生成报告」

### 2.2 生成报告

#### 2.2.1 处理中

[处理中示意](report-interaction.html#processing)

点击「生成报告」后进入处理中
本场景不提供取消，关闭窗口不终止生成
重新打开时恢复该报告的最新状态

#### 2.2.2 已生成

[已生成示意](report-interaction.html#success)

报告生成后保存至「历史报告」
点击「查看报告」进入该报告详情

#### 2.2.3 生成失败

[生成失败示意](report-interaction.html#failure)

服务繁忙时可重试，重试继续处理本次生成请求，不重复创建报告
````

### 4.2 HTML 交互示意

report-interaction.html 展示五种状态，通过页首链接定位

```html
<!doctype html>
<html lang="zh-CN">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>生成部门报告交互示意</title>
<style>
  body { margin: 0; padding: 24px; background: #f5f6f7; color: #1f2329;
    font: 14px/1.6 sans-serif; }
  nav, main { max-width: 640px; margin: auto; }
  nav { display: flex; gap: 16px; flex-wrap: wrap; }
  section { margin-top: 24px; padding: 24px; background: white;
    border: 1px solid #dee0e3; border-radius: 8px; }
  h1 { margin: 0 0 12px; font-size: 20px; }
  h2 { margin: 0 0 12px; font-size: 16px; }
  p { margin: 8px 0; }
  label { display: block; margin-top: 12px; }
  input, select, button { font: inherit; padding: 8px; }
  input, select { border: 1px solid #8f959e; border-radius: 4px; }
  button { margin-top: 16px; padding: 8px 16px; background: #1456f0;
    color: white; border: 0; border-radius: 4px; }
  button:disabled { background: #eff0f1; color: #646a73; }
  .error { color: #c02a38; }
</style>
<nav aria-label="交互状态">
  <a href="#range">选择范围</a><a href="#invalid-range">日期错误</a>
  <a href="#processing">处理中</a>
  <a href="#success">已生成</a><a href="#failure">生成失败</a>
</nav>
<main>
  <section id="range">
    <h1>生成部门报告</h1>
    <label>部门 <select aria-label="部门"><option>销售部</option></select></label>
    <label>开始日期 <input aria-label="开始日期" type="date" value="2026-09-01"></label>
    <label>结束日期 <input aria-label="结束日期" type="date" value="2026-09-30"></label>
    <button>生成报告</button>
  </section>
  <section id="invalid-range">
    <h2>生成部门报告</h2>
    <label>部门 <select aria-label="部门"><option>销售部</option></select></label>
    <label>开始日期 <input aria-label="开始日期" type="date" value="2026-09-30"></label>
    <label>结束日期 <input aria-label="结束日期" type="date" value="2026-09-01"></label>
    <p class="error">开始日期不能晚于结束日期</p>
    <button disabled>生成报告</button>
  </section>
  <section id="processing">
    <h2>生成部门报告</h2>
    <label>部门 <select aria-label="部门" disabled><option>销售部</option></select></label>
    <label>开始日期 <input aria-label="开始日期" type="date" value="2026-09-01" disabled></label>
    <label>结束日期 <input aria-label="结束日期" type="date" value="2026-09-30" disabled></label>
    <p role="status">正在生成报告，请稍候</p>
    <button disabled>生成中</button>
  </section>
  <section id="success">
    <h2>报告已生成</h2>
    <p>销售部 · 2026-09-01 至 2026-09-30</p>
    <p>共 128 条记录</p>
    <button>查看报告</button>
  </section>
  <section id="failure">
    <h2>生成部门报告</h2>
    <label>部门 <select aria-label="部门"><option>销售部</option></select></label>
    <label>开始日期 <input aria-label="开始日期" type="date" value="2026-09-01"></label>
    <label>结束日期 <input aria-label="结束日期" type="date" value="2026-09-30"></label>
    <p class="error" role="alert">报告服务繁忙，请稍后重试</p>
    <button>重试</button>
  </section>
</main>
</html>
```

## 5 检查条件

- [ ] 使用场景、入口与对应章节可定位
- [ ] 操作过程与分支覆盖场景的实际交互
- [ ] 用户可见的状态、内容与反馈有对应示意
- [ ] 操作后的变化与后续操作已定义
- [ ] 影响交互的权限、校验与启用条件已定义
- [ ] 涉及保存、取消、离开与重试时，结果及保留内容已定义
- [ ] 示意与规则一致，共用规则有引用
- [ ] 正常过程及失败、中断、恢复分支中的触发条件与结果均有定义
- [ ] 文字补充示意未表达的业务条件与行为规则，不重复描述已展示的内容
