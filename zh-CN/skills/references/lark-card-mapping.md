# 飞书卡片映射（Lark Card Mapping）

## 1 适用范围

把[飞书卡片示意](../../doc-design/patterns/lark-card-mockup.md)里的每个 HTML 样式与特征转换为飞书 Card JSON 2.0 组件或富文本语法
字段定义以[卡片 JSON 2.0 结构](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)与[组件总览](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/component-json-v2-overview)为准
客户端显示差异与实测限制写在对应章节

## 2 通用实现

### 2.1 文本转义

动态文本直接赋值给 `plain_text.content`，整卡使用 JSON 序列化器输出
原始动态文本的 ASCII 标点逐字符转为 `&#十进制码点;`，仅转义一次，再拼入 `markdown.content` 正文，见[特殊字符转义说明](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)
链接 URL 使用 URL 解析器校验，仅接受 `http:` 与 `https:`
URL 序列化后，将 `(`、`)` 编码为 `%28`、`%29`，生成[文字链接](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)语法 `[显示文本](URL)`
URL 校验失败时不生成链接，失败展示由业务设计定义

### 2.2 发送、回调与更新

创建待发送消息时生成并保存 [UUID v4](https://www.rfc-editor.org/rfc/rfc9562.html#section-5.4)，[发送](https://open.feishu.cn/document/server-docs/im-v1/message/create)、[回复](https://open.feishu.cn/document/server-docs/im-v1/message/reply)及重投均使用该消息的 `uuid`

1. 调用[创建卡片实体](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/cardkit-v1/card/create)，`type` 为 `card_json`，`data` 为序列化后的卡片 JSON，保存返回的 `card_id`
2. [发送或回复卡片消息](https://open.feishu.cn/document/server-docs/im-v1/message-content-description/create_json)时，`msg_type` 为 `interactive`，`content` 为 `{"type":"card","data":{"card_id":"已保存的 card_id"}}` 序列化后的字符串
3. 更新时调用 [CardKit 全量更新](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/cardkit-v1/card/update)，使用已保存的 `card_id`，`card.type` 为 `card_json`，`card.data` 为序列化后的完整卡片 JSON

本卡变化：回调应答后用 CardKit 全量更新原卡
另发一张：回调应答后发送新消息

[卡片回调](https://open.feishu.cn/document/uAjLw4CM/ukzMukzMukzM/feishu-cards/card-callback-communication)在 3 秒内应答，耗时处理异步执行
回调按钮的 `value` 只传操作标识与对象标识，业务数据由服务端读取
同一回调重投按回调头的 [`event_id`](https://open.feishu.cn/document/uAjLw4CM/ukzMukzMukzM/feishu-cards/card-callback-communication) 去重
重复点击的业务幂等规则由具体业务设计定义
同一卡片的更新串行执行，首次更新的 [`sequence`](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/cardkit-v1/card/update) 为 `1`，后续每次更新请求加 `1`
卡片更新不触发新消息提醒
更新失败时记录 `card_id`、`sequence`、错误码与错误信息
发送返回[错误码 230099](https://open.feishu.cn/document/server-docs/im-v1/message/create) 时，按 `msg` 中的内层 `ErrCode` 与字段路径定位卡片内容错误，改正前不重试
同一接收目标的发送请求排队执行，相邻请求至少间隔 200ms
返回[错误码 230020](https://open.feishu.cn/document/server-docs/im-v1/message/create) 时，依次等待 1、2、4 秒重试，复用原 `uuid`，三次重试均失败则返回发送失败

## 3 整体表达

对应示意的[卡片示意的整体表达](../../doc-design/patterns/lark-card-mockup.md#3-卡片示意的整体表达)

### 3.1 画布

每个 `card-mockup` 根节点生成一张卡片，使用以下固定骨架，字段见[JSON 2.0 结构](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)
`config.width_mode` 固定为 `fill`，由飞书根据宿主可用宽度展示卡片
示意中的 CSS 宽度、`min-width` 与 `box-sizing` 只用于 HTML 布局，不生成卡片 JSON 字段

```json
{
  "schema": "2.0",
  "config": { "width_mode": "fill", "update_multi": true },
  "header": {},
  "body": { "elements": [] }
}
```

### 3.2 长内容与分页

发送前统计完整卡片序列化后的 UTF-8 字节数与组件数

按 UTF-8 序列化不超过 30 KB，见[发送消息](https://open.feishu.cn/document/server-docs/im-v1/message/create)的 `content` 字段限制
递归统计完整卡片中带 `tag` 的对象，总数不超过 200 个，见[JSON 2.0 结构](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)的元素与组件数量限制

可分页列表按以下步骤装载

1. 用完整结果生成整卡，字节数与组件数均未超限时直接发送，不生成分页区
2. 超出时按业务顺序确定展示单元，默认每条记录一个单元，嵌套列表以最内层记录为单元
3. 单条记录无法装入空页时，按下述超长记录规则拆成连续展示单元
4. 逐个装载展示单元，每次生成包含标题、汇总、所属对象标识与标题、分页区的完整卡片并检查容量
   - 加入后超限：移出该单元，本页结束，该单元留到下一页
5. 保存完整结果、展示单元序列与各页的起止单元序号，翻页按已保存的页边界读取，不重新查询业务数据

展示单元使用更新前后可对应的稳定标识
任务进度变化需要刷新分页内容时，按更新后的完整内容重新执行上述装载步骤
以当前页首个展示单元为锚点，按稳定标识定位并显示该单元所在的新页
锚点单元不再存在时，按业务设计定义的定位规则确定展示页

确认卡不分页，按以下步骤装载

1. 超限时，每项仅保留业务设计指定的识别字段，再检查容量
2. 仍超限时，先生成包含标题、最后一项、省略号、总数与操作区的完整卡片
3. 从第一项起逐项加入记录，每次检查整卡容量，超限时移出该项并停止
4. 最后一项只展示一次
5. 前几项与最后一项之间单独显示省略号，其后空一行
6. 末尾显示完整确认范围的总数，对象名称与计数单位由业务设计定义
7. 序号沿用完整确认范围中的顺序
8. 确认按钮的 `value` 中，对象标识指向服务端保存的完整确认范围，回调按该标识读取全部记录执行操作

表单卡不分页，超限时仅删除业务设计标明可省略的说明，保留全部输入字段

单条记录超限时，仅对业务设计标明可摘要的字段生成摘要，再检查容量
未标明可摘要的字段完整保留
可分页内容仍超限时，优先按段落或列表项拆成连续展示单元
拆分保持内容完整，不截断字符、链接或富文本结构
各单元沿用原记录标识与内容顺序，续页保留所属对象的标识与标题

翻页回调只读取已保存的分页结果
私聊翻页更新原卡
群聊按设计选定的[翻页方式](../../doc-design/patterns/lark-card-mockup.md#32-长内容与分页)处理
共同查看时更新原卡
独立浏览时向点击人私聊发送引用同一分页结果的浏览卡，群聊原卡保持不变
私聊浏览卡只保留浏览与翻页操作，业务确认、取消与提交仍在原卡执行
翻页回调不改变原卡归属与业务操作权限
翻页回调只接受服务端已保存的目标页，目标页不存在时拒绝更新，失败提示由业务设计定义

按本节处理后仍超限时不发送，用户提示由具体业务设计定义

## 4 标题栏

对应示意的[标题栏](../../doc-design/patterns/lark-card-mockup.md#4-标题栏)

标题栏生成原生 `header`，主副标题不重复生成正文组件
示意中的标题栏底色、文字颜色、字号、字重、行高与内边距用于预览，不转换为 JSON 样式字段，实际外观由飞书的标题组件与主题渲染

### 4.1 主题颜色

读取 `card-header` 上唯一的主题 class，按下表设置 `header.template`
没有主题、存在多个主题或主题不在表中时返回转换错误

| 主题 class | [`header.template`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/title) |
| --- | --- |
| `theme-default` | `default` |
| `theme-blue` | `blue` |
| `theme-green` | `green` |
| `theme-orange` | `orange` |
| `theme-red` | `red` |
| `theme-grey` | `grey` |

### 4.2 标题内容

| 示意 | 实现 |
| --- | --- |
| `card-header` 内的 `card-title` | 文本写入 [`header.title.content`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/title)，`header.title.tag` 为 `plain_text` |
| `card-header` 内的 `card-subtitle` | 文本写入 [`header.subtitle.content`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/title)，`header.subtitle.tag` 为 `plain_text`，没有时省略 `header.subtitle` |

每个 `card-header` 必须有且只有一个 `card-title`，最多一个 `card-subtitle`，数量不符合时返回转换错误

## 5 布局

对应示意的[布局](../../doc-design/patterns/lark-card-mockup.md#5-布局)

### 5.1 字段行

每个 `field-row` 生成一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)，`flex_mode` 为 `none`，`horizontal_spacing` 为 `12px`
`field-label` 生成标签列，`width` 为 `64px`
`field-value` 生成取值列，`width` 为 `weighted`，`weight` 为 `1`
两列的 `horizontal_align` 为 `left`，文字字号与颜色按[§6](#6-文字)转换

### 5.2 分割线

HTML 的 `<hr>` 转换为飞书 [`hr`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/divider) 组件
`margin` 为 `12px 0px 12px 0px`，对应示意中分割线上下各 12px 的留白

### 5.3 描边框

每个 `outlined-block` 生成一个 [`interactive_container`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/interactive-container)，使用以下固定字段，`elements` 填入框内内容的转换结果

```json
{
  "tag": "interactive_container",
  "has_border": true,
  "border_color": "rgba(223,225,227,1)",
  "corner_radius": "8px",
  "padding": "8px 12px 8px 12px",
  "behaviors": [],
  "elements": []
}
```

**框内内容与操作**

框内有详情按钮时，`elements` 放入一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
`flex_mode` 为 `none`，`horizontal_spacing` 为 `8px`
左列 `width` 为 `weighted`、`weight` 为 `1`，放入整块内容
右列 `width` 为 `auto`、`vertical_align` 为 `center`，放入详情按钮

### 5.4 灰底块

每个 `grey-block` 生成一个 [`interactive_container`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/interactive-container)，使用以下固定字段，`elements` 填入块内内容的转换结果

```json
{
  "tag": "interactive_container",
  "background_style": "rgba(245,246,247,1)",
  "has_border": false,
  "corner_radius": "4px",
  "padding": "8px 12px 8px 12px",
  "behaviors": [],
  "elements": []
}
```

### 5.5 行动区块

每个 `action-block` 生成一个行动区块，颜色按所属 `card-mockup` 内 `card-header` 的主题 class 选择
外层生成一个 [`interactive_container`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/interactive-container)，`corner_radius` 为 `4px`，`has_border` 为 `false`
外层 `background_style` 为底色，`padding` 为 `0px`，`behaviors` 为空数组
外层 `elements` 放入一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)，`flex_mode` 为 `none`，`horizontal_spacing` 为 `0px`，里面两列

`columns` 按左列、右列顺序生成，两列的 `tag` 均为 `column`
左列 `width` 为 `16px`，`background_style` 为竖线色，`elements` 为空数组
右列 `width` 为 `weighted`、`weight` 为 `1`，`background_style` 为底色
右列 `padding` 为 `8px 12px 8px 12px`，`margin` 为 `0px 0px 0px -12px`，`elements` 填入区块内容的转换结果
圆角处内部竖线的裁切效果待客户端验证

颜色枚举使用[官方色板](https://open.feishu.cn/document/feishu-cards/enumerations-for-fields-related-to-color)中的对应值

| 主题 class | 竖线色 | 底色 |
| --- | --- | --- |
| `theme-orange` | `orange-350` | `orange-50` |
| `theme-red` | `red-350` | `red-50` |
| `theme-blue` | `blue-350` | `blue-50` |
| `theme-green` | `green-350` | `green-50` |
| `theme-default` | `blue-350` | `blue-50` |
| `theme-grey` | `blue-350` | `blue-50` |

### 5.6 折叠

每个 `<details>` 生成一个 [`collapsible_panel`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/collapsible-panel)，`expanded` 为 `false`
`<summary>` 转换为 `header.title`，`tag` 为 `markdown`，文案按[§6](#6-文字)转换
其余子节点按原顺序转换，放入 `elements`

### 5.7 表格布局

表格容器使用 `table-layout`，表头使用 `table-header`，记录行使用 `table-row`
从 `table-layout` 的 `--table-columns` 读取统一列宽定义，表头与记录行按同一列序分别生成一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
`flex_mode` 为 `none`，`horizontal_spacing` 为 `8px`
列宽定义中的 `minmax(0,Nfr)` 转为 `width: weighted`、`weight: N`，`N` 为 1 至 5 的整数
像素列宽直接转为 `width`，取值为 16px 至 600px，其他列宽定义返回转换错误
当前示例的列宽定义为 `minmax(0,1fr) 64px 84px`

**表头**

表头各列的 `padding` 为 `8px 0px 8px 0px`
内容列的 `horizontal_align` 为 `left`，最右操作列为 `center`
各列标题转换为 `markdown`，文案加粗，字号与颜色按[§6](#6-文字)转换
表头的 `column_set` 后放一个 [`hr`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/divider) 组件

**记录行**

记录行各列的 `padding` 为 `8px 0px 8px 0px`
内容列的 `horizontal_align` 为 `left`，内容按对应组件规则转换
最右操作列的 `horizontal_align` 与 `vertical_align` 均为 `center`，按钮按 [§9.1](#91-按钮) 转换
每条记录的 `column_set` 后放一个 [`hr`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/divider) 组件

### 5.8 文字层级间距

对应示意的[文字层级间距](../../doc-design/patterns/lark-card-mockup.md#58-文字层级间距)

独立正文标题与段落分别生成 `markdown`，不通过空行或空白组件模拟间距
排列这些文字组件的纵向容器显式设置 `vertical_spacing` 为 `0px`，字段见[JSON 2.0 结构](https://open.feishu.cn/document/feishu-cards/card-json-v2-structure)
组件的 `margin` 按上、右、下、左顺序写为 `Npx 0px 0px 0px`，字段见[富文本组件](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)

按以下顺序确定前置间距 `N`，只应用首个匹配规则

1. 容器内首个文字组件为 `0`
2. 当前组件紧随正文标题，且为所属正文或更小字号的子标题时，为 `4`
3. 当前组件为新部分的 `text-heading` 时，按示意 §5.8 中当前标题字号对应的前置间距取值
4. 相邻独立正文段落之间为 `8`

容器内边距保留，不额外叠加文字组件的默认间距或 HTML 上下边距
字段行、表单、按钮区与其他组件的内部布局按各自章节转换

## 6 文字

对应示意的[文字](../../doc-design/patterns/lark-card-mockup.md#6-文字)

本章只转换正文文字，卡片主副标题按 [§4](#4-标题栏) 转换

正文文字读取 HTML 元素最终生效的字号，包含继承值，按下表显式设置 `markdown.text_size`
字号未在表中列出时返回转换错误

正文颜色使用当前元素或最近祖先元素的 `text-grey`、`text-red` class
同一元素同时带有这两个 class 时返回转换错误
当前元素与祖先均无颜色 class 时，不添加 `<font>` 颜色标签，使用默认正文颜色

正文文字读取 HTML 元素最终生效的字重，包含继承值
字重仅接受 `400` 与 `700`，其他值返回转换错误

同一段文字的字号、颜色与字重组合生成一次转换结果
字号写入 `markdown.text_size`，颜色与字重组合写入 `content`
同时有颜色与加粗时，`<font>` 包裹 `**文本**`

| 示意 | 实现 |
| --- | --- |
| 30px | [`markdown.text_size`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) 为 `heading-0` |
| 24px | `text_size` 为 `heading-1` |
| 20px | `text_size` 为 `heading-2` |
| 18px | `text_size` 为 `heading-3` |
| 16px | `text_size` 为 `heading-4` |
| 14px | `text_size` 为 `normal` |
| 12px | [`text_size`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) 为 `notation` |
| `text-grey` | `<font color='grey'>文本</font>`，取值见[颜色枚举](https://open.feishu.cn/document/feishu-cards/enumerations-for-fields-related-to-color) |
| `text-red` | `<font color='red'>文本</font>`，取值见[颜色枚举](https://open.feishu.cn/document/feishu-cards/enumerations-for-fields-related-to-color) |
| 正文的 `font-weight:700` | [加粗语法](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) `**文本**` |
| 正文的 `font-weight:400` | 普通文本 |
| `text-heading` | 独立使用一个 [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)，`text_size` 按字号映射，`content` 使用示意中的完整标题文本并加粗 |
| `<code>` | 文本含反引号、回车或换行时返回转换错误，其他文本原样用反引号包裹，写入 `markdown.content`，仅做 JSON 序列化，见[行内代码语法](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) |
| 正文 `<a>` | 文本作为显示文本，`href` 作为 URL，按 [§2.1](#21-文本转义) 生成文字链接 |
| `<ul>` 的直接子项 `<li>` | 使用[无序列表语法](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)，每行以 `- ` 开头 |
| `<ol>` 的直接子项 `<li>` | 使用[有序列表语法](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)，每行以递增的 `1. `、`2. ` 等序号开头 |
| 嵌套 `<ul>/<ol>` | 最外层缩进为 0，每深入一层增加 4 个空格 |

## 7 图标与标记

对应示意的[图标与标记](../../doc-design/patterns/lark-card-mockup.md#7-图标与标记)

### 7.1 状态标记

状态标记保留示意中的字符，与所属文案一同写入文本组件的 `content`，文本转义按 [§2.1](#21-文本转义) 处理

### 7.2 行首图标

每个 `<img class="row-icon">` 与同行文字生成一个 [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) 组件
相对 `src` 以示意文件所在目录为基准解析
图片按 [`image_type: message`](https://open.feishu.cn/document/server-docs/im-v1/image/create) 上传，返回的 `image_key` 写入 `icon.img_key`
`icon.tag` 固定为 `custom_icon`
同行文字按[§6](#6-文字)转换，写入 `content`
`markdown.icon` 不添加尺寸字段，图标随字号变化的显示效果待客户端验证

## 8 人员

对应示意的[人员](../../doc-design/patterns/lark-card-mockup.md#8-人员)

发卡应用须具备相应用户 ID 的访问权限，见[人员组件的注意事项](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/user-profile)

头像胶囊使用 `person-capsule`，`data-person-key` 标识对应的业务人员
按该标识从业务设计定义的人员数据中读取发卡应用对应的 `open_id`，写入 [`person.user_id`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/user-profile)
`size` 为 `small`，`show_avatar` 与 `show_name` 为 `true`，`style` 为 `capsule`

单人时，`field-value` 对应列的 `elements` 放入一个 `person`
多人时，取值列嵌套一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)，`flex_mode` 为 `flow`，`horizontal_spacing` 为 `8px`
每人生成一个 `column`，其 `elements` 只放该人的 `person`

句中的 `person-capsule` 按 `data-person-key` 读取对应 `open_id`
在所属 `markdown.content` 的原位置生成[人员标签](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)

```html
<person id='实际 open_id' show_name=true show_avatar=true style='capsule'></person>
```

标签作为富文本语法拼入，周围文案按 [§2.1](#21-文本转义) 转义

标题与按钮中的人员只写纯文本姓名

`person` 组件与 `<person>` 标签只展示身份，不发送提及通知
业务设计要求提及提醒时，读取指定提醒对象的 `open_id`，生成[提及标签](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) `<at id='实际 open_id'></at>`
未取得对应 `open_id` 时，使用业务设计定义的缺失文案，按[§6](#6-文字)转换为普通文字

## 9 操作与输入

对应示意的[操作与输入](../../doc-design/patterns/lark-card-mockup.md#9-操作与输入)

### 9.1 按钮

每个 `card-button` 生成一个 [`button`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/button)，并且只带一个样式 class
缺少样式 class 或同时带有多个时返回转换错误

| 样式 class | `button.type` |
| --- | --- |
| `button-default` | `default` |
| `button-primary` | `primary` |
| `button-danger` | `danger` |

带 `is-disabled` 的按钮，`disabled` 为 `true`，其余为 `false`
按钮完整文案写入 `text.content`，保留示意中的 emoji，`text.tag` 固定为 `plain_text`
文本按 [§2.1](#21-文本转义) 的普通文本规则处理
禁用状态与样式独立，仍保留原来的 `button.type`

每个按钮只带 `button-callback`、`button-open-url` 中的一种，缺少或同时带有两种时返回转换错误

回调按钮使用 `button-callback`
`data-action` 提供操作标识，`data-object-key` 指定业务对象
按 `data-object-key` 从业务设计定义的对象数据中读取实际对象 ID，生成以下结构，回调参数遵循 [§2.2](#22-发送回调与更新)

```json
{
  "behaviors": [
    {
      "type": "callback",
      "value": {
        "action": "data-action 的值",
        "object_id": "实际对象 ID"
      }
    }
  ]
}
```

链接按钮使用 `<a class="card-button button-open-url …">`，`href` 提供目标 URL
URL 按 [§2.1](#21-文本转义) 校验，生成以下交互

```json
{
  "behaviors": [
    {
      "type": "open_url",
      "default_url": "校验后的 URL"
    }
  ]
}
```

每个 `button-area` 生成一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
`flex_mode` 为 `flow`，`horizontal_spacing` 为 `8px`
按示意顺序，每个按钮生成一个 `column`，`elements` 只放对应按钮

### 9.2 表单

表单示意使用 `<form name="表单标识">`
每个 `<form>` 生成一个飞书 [`form`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/form-container)，`name` 直接读取 HTML 的 `name`
子节点按原顺序转换，放入 `form.elements`
生成的 `form` 直接放入 `body.elements`
表单名称为空或与本卡其他表单、控件名称重复时，返回转换错误
表单内所有交互组件的 `name` 读取 `data-field-name`
名称为空，或与本卡其他表单、交互组件名称重复时，返回转换错误

字段名使用 `form-label`，`data-field-name` 对应控件的 `name`
字段名按 [§6](#6-文字) 转换为加粗的 `markdown`，放在对应控件前

控件带 `is-required` 时，`required` 为 `true`，其余为 `false`
字段名中的红色 `*` 按 [§6](#6-文字) 转换，保留一次

提交按钮使用 `form-submit`，`form_action_type` 为 `submit`
文案、样式与回调按 [§9.1](#91-按钮) 转换
每个 `form` 至少包含一个提交按钮，否则返回转换错误

取消按钮使用 `form-cancel`
[`form_action_type`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/button) 为 `reset`，保留取消操作的回调参数
取消回调结束当前操作，不修改业务数据
`reset` 与回调组合后是否按预期触发取消，待客户端验证

控件内的 `is-placeholder` 文本写入该控件的 [`placeholder.content`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/input)，`placeholder.tag` 为 `plain_text`

表单内的输入与选择控件不配置独立回调
提交时，从[回调事件的 `action.form_value`](https://open.feishu.cn/document/feishu-cards/card-callback-communication) 按控件 `name` 读取各字段值

1. 收到提交回调时，先保存本次 `action.form_value`
2. 提交失败或返回修改时，读取对应提交的保存值，按控件 `name` 回填各控件的初始值字段

**输入框**

输入框使用 `card-input`，每个元素生成一个 [`input`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/input)，并且只带一个类型 class

| 类型 class | `input.input_type` |
| --- | --- |
| `input-single` | `text` |
| `input-multiline` | `multiline_text` |

`width` 固定为 `fill`，多行输入框的 `rows` 为 `2`
类型 class 缺少或同时带有多个时，返回转换错误
`card-input` 的 `data-value` 写入 `default_value`
未提供 `data-value` 时，`default_value` 为空字符串
预填值按 [§2.1](#21-文本转义) 的普通文本规则处理

**下拉选择**

下拉选择使用 `card-select`，并且只带一个类型 class
四种下拉控件的 `width` 统一为 `fill`

| 类型 class | 飞书组件 |
| --- | --- |
| `select-single` | [`select_static`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-dropdown-menu) |
| `select-multi` | [`multi_select_static`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-dropdown-menu) |
| `select-person-single` | [`select_person`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-user-picker) |
| `select-person-multi` | [`multi_select_person`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-user-picker) |

类型 class 缺少或同时带有多个时，返回转换错误

下拉单选与多选的 `data-options-key` 指向有序的 `{label, value}` 列表
每项按原顺序生成以下 `options` 结构，字段见[普通下拉选项定义](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-dropdown-menu)

```json
{
  "text": {
    "tag": "plain_text",
    "content": "label 的值"
  },
  "value": "value 的值"
}
```

文案按 [§2.1](#21-文本转义) 的普通文本规则处理
列表为空、`label` 或 `value` 缺失、`value` 重复时，返回转换错误

普通单选读取 `data-value`，在 `options.value` 中找到对应项，将从 1 开始的序号写入 [`initial_index`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-dropdown-menu)
普通多选读取 `data-values` 的 JSON 字符串数组，写入 [`selected_values`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-dropdown-menu)
未提供初始值属性时，省略对应字段
初始值不在候选列表中，或数组格式错误时，返回转换错误

选人控件的 `data-options-key` 指向业务设计定义的有序候选列表
每位候选人的发卡应用 `open_id` 转为 `options` 中的 `{"value":"实际 open_id"}`，按候选列表顺序生成
候选列表为空或存在缺失的 `open_id` 时，返回转换错误，字段见[选人控件的 options 定义](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-user-picker)

选人单选读取 `data-person-key` 对应的 `open_id`，写入 [`initial_option`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/single-select-user-picker)
选人多选读取 `data-person-keys` 的 JSON 标识数组，逐个解析为 `open_id` 字符串，写入 [`selected_values`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/multi-select-user-picker)
未提供初始人员标识时，省略对应初始值字段
人员标识无法解析，或初始人员不在候选列表中时，返回转换错误

### 9.3 日期时间

每个 `card-datetime` 生成一个 [`picker_datetime`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/date-time-picker)，`width` 为 `fill`
`data-value` 写入 `initial_datetime`，格式为 `yyyy-MM-dd HH:mm`，日期与时间必须合法
未提供 `data-value` 时，省略初始值，并按 [§9.2](#92-表单) 读取占位提示
初始值与占位提示均缺失时，返回转换错误

`data-timezone` 提供业务设计指定的 IANA 时区，时区语义见[日期时间选择器的注意事项](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/interactive-components/date-time-picker)
初始值的显示与提交年月日时分的解释，均使用该时区
字段名中展示用户能理解的时区名称
时区缺失或无效时，返回转换错误

## 10 进度展示

对应示意的[进度展示](../../doc-design/patterns/lark-card-mockup.md#10-进度展示)

### 10.1 进度条

进度条使用 `progress-bar`
`data-completed` 提供已结束项数，`data-total` 提供总项数
`data-length` 提供字符条格数，取值为正整数
已结束项包含成功与失败，总项数必须大于 0，且 `0 ≤ 已结束项数 ≤ 总项数`
`█` 的数量为 `floor(已结束项数 × 格数 ÷ 总项数)`，其余用 `░` 补足 `data-length` 指定的格数
参数必须为整数，不合法时返回转换错误

`data-format` 为 `ratio` 时，显示“已结束项数/总项数”
为 `percent` 时，显示 `floor(已结束项数 × 100 ÷ 总项数)%`
未提供时使用 `ratio`，其他值返回转换错误
字符条与右侧数量生成一个 [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text)，`text_size` 为 `normal`
字符条使用行内代码，与右侧数量之间保留一个空格，右侧数量加粗

### 10.2 步骤进度

`<ol class="step-progress">` 的每个直接子项生成一个无边框 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
`flex_mode` 为 `none`，`horizontal_spacing` 为 `0px`
左列 `width` 为 `20px`，按子项顺序展示从 1 开始的序号
右列 `width` 为 `weighted`、`weight` 为 `1`，先放步骤名与状态，再放明细
步骤正文与明细分别按 [§6](#6-文字) 生成文字组件
所有步骤行放入一个单列 `column_set`，`flex_mode` 为 `none`
该列 `width` 为 `weighted`、`weight` 为 `1`，`vertical_spacing` 为 `0px`
每步右列的 `vertical_spacing` 也为 `0px`
`<li>` 的直接子 `<div>` 作为明细，其余内联内容作为步骤正文
左列序号的 `markdown.text_size` 为 `normal`，`text_align` 为 `right`，文本按 [§2.1](#21-文本转义) 转义

## 11 附件

对应示意的[附件](../../doc-design/patterns/lark-card-mockup.md#11-附件)

每个 `<img class="attachment-thumbnail">` 生成一个[图片组件](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/image)
原图读取与上传按 [§7.2](#72-行首图标) 的对应规则执行，返回的 `image_key` 写入 `img_key`
HTML 的 `alt` 写入 `alt.content`，未提供时使用空字符串

```json
{
  "tag": "img",
  "img_key": "上传返回的 image_key",
  "alt": {
    "tag": "plain_text",
    "content": "HTML 的 alt"
  },
  "size": "56px 56px",
  "scale_type": "crop_center",
  "corner_radius": "6px",
  "preview": true
}
```

每个 `attachment-gallery` 生成一个 [`column_set`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/containers/column-set)
`flex_mode` 为 `none`，`horizontal_spacing` 为 `8px`
按示意顺序，每张缩略图生成一个 `width` 为 `auto` 的列，`elements` 只放对应图片组件

「查看全部」按钮按 [§9.1](#91-按钮) 生成回调，通过 `object_id` 读取完整图片列表
后续展示按业务设计提供的完整图片 card mockup 转换，发送与更新按 [§2.2](#22-发送回调与更新) 执行

文件链接生成一个 [`markdown`](https://open.feishu.cn/document/feishu-cards/card-json-v2-components/content-components/rich-text) 组件，保留示意中的 📄 前缀
`<a>` 的文本作为文件名，`href` 作为链接地址，按 [§2.1](#21-文本转义) 转义与校验，文字样式按 [§6](#6-文字) 转换

## 12 实现验证

每个设计中的卡片状态都有对应的正式渲染路径
测试用例按[测试用例](../../doc-design/patterns/testcase.md)表达，引用对应状态的设计依据
测试调用正式渲染路径，核对以下内容

- 内容与操作与该状态的卡片示意及交互设计一致
- 容量与分页满足 [§3.2](#32-长内容与分页)

预览或测试专用卡片不能代替正式渲染结果的验证
