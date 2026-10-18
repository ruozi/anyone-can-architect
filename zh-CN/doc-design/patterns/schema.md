# 数据契约（Schema）

## 1 适用场景

一份数据的结构与校验契约的表达

**编写前提：已确认目标语言或数据描述规范**

## 2 表达原则

以下内容均必需，按表中顺序展开

| 内容 | 表达规则 |
| --- | --- |
| 契约声明 | [§2.1](#21-契约声明) |
| 字段说明 | [§2.2](#22-字段说明) |

### 2.1 契约声明

使用代码块展示目标语言的原生校验声明，或所选数据描述规范
类型、必填性、枚举、取值范围、格式与默认值等可声明的约束直接写入声明
对象是否接受未声明的字段写入声明
跨字段规则与条件必填写入声明，声明表达不了的写在紧邻的文字里并标明字段
被依赖的契约在前，引用它的契约在后
同一份数据只定义一处
结构合法但业务上不足的判定不写入契约
一份契约需要派生变体时，变体紧邻原契约定义，写明与原契约的差异
判断标准：任何一方只凭声明就能判定一份数据是否合法

### 2.2 字段说明

字段说明写在字段声明处的文档注释或描述字段中
说明字段的业务含义，不站在任何一方的视角，不写数据怎么产生、怎么被处理
可省略或可为空的字段，注明省略、空值与空串各自代表什么
解析时施加默认值、归一化或转换的字段，注明解析后的结果与输入的差别
不重复声明已经表达的类型与约束

## 3 目标语言示例：取消订单参数（TypeScript & zod）

```typescript
import { z } from "zod";

/** 取消原因 */
export const CancelReasonSchema = z.enum([
  "customer_request", // 客户主动取消
  "out_of_stock", // 缺货
  "other", // 其他
]);

/** 取消订单的参数 */
export const CancelOrderParamsSchema = z
  .object({
    /** 订单号；空串表示用户没有说明 */
    order_no: z.union([z.literal(""), z.string().regex(/^[A-Za-z0-9]{6}$/)]).default(""),
    /** 取消原因；省略表示客户主动取消 */
    reason: CancelReasonSchema.default("customer_request"),
    /** 补充说明，解析时去掉首尾空白；reason 为 other 时不能为空，其余情况可为空串 */
    note: z.string().trim().default(""),
    /** 是否连同子订单一起取消；省略表示只取消本单 */
    with_children: z.boolean().default(false),
  })
  .strict()
  .refine((p) => p.reason !== "other" || p.note !== "", {
    message: "reason 为 other 时须填写 note",
    path: ["note"],
  });

export type CancelOrderParams = z.infer<typeof CancelOrderParamsSchema>;
```

## 4 数据描述规范示例：取消订单参数（JSON Schema 2020-12）

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "CancelOrderParams",
  "description": "取消订单的参数",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "order_no": {
      "description": "订单号；空串表示用户没有说明",
      "type": "string",
      "pattern": "^([A-Za-z0-9]{6})?$",
      "default": ""
    },
    "reason": {
      "description": "取消原因；省略表示客户主动取消",
      "enum": ["customer_request", "out_of_stock", "other"],
      "default": "customer_request"
    },
    "note": {
      "description": "补充说明；reason 为 other 时不能为空，其余情况可为空串",
      "type": "string",
      "default": ""
    },
    "with_children": {
      "description": "是否连同子订单一起取消；省略表示只取消本单",
      "type": "boolean",
      "default": false
    }
  },
  "if": {
    "properties": { "reason": { "const": "other" } },
    "required": ["reason"]
  },
  "then": {
    "properties": { "note": { "pattern": "\\S" } },
    "required": ["note"]
  }
}
```

## 5 检查条件

### 5.1 约束写在声明之外

- [ ] 类型、必填性、枚举、取值范围、格式与默认值等可声明的约束都在声明中
- [ ] 对象是否接受未声明的字段已在声明中写明
- [ ] 跨字段规则与条件必填已写入声明，声明表达不了的紧邻声明写出并标明字段

**反例**

```typescript
export const CancelOrderParamsSchema = z.object({
  order_no: z.string(),
  reason: z.string(),
});
```

> `order_no` 为 6 位字母或数字，`reason` 只能是 customer_request、out_of_stock、other

格式与枚举都能写进声明，却留在文字里，校验时不会生效

### 5.2 存在性语义不明

- [ ] 每个可省略或可为空的字段都写明省略、空值与空串各自的含义
- [ ] 解析时施加的默认值、归一化或转换已在字段处注明

**反例**

```typescript
/** 补充说明 */
note: z.string().optional(),
```

没有说明省略与空串是否同义

### 5.3 同一份数据有多个定义

- [ ] 每份数据只有一处定义
- [ ] 同一个契约名称在全部文档中只有一种形状

**反例**

订单模块的接口文档和取消命令的文档各自定义了一个 `CancelOrderParams`，一个有 `with_children`，另一个没有

两处都叫同一个名字，读者无法判断以哪份为准，修改时也只会改到其中一份

### 5.4 业务判定混入契约

- [ ] 契约只判定结构与取值是否合法，没有把业务上是否足够的判定写成必填或取值约束

**反例**

```typescript
/** 订单号，必填 */
order_no: z.string().regex(/^[A-Za-z0-9]{6}$/),
```

用户没有说订单号时应当引导补充，这份数据本身没有不合法，却被契约拒绝

### 5.5 文字复述了声明已表达的内容

- [ ] 字段说明与代码块外的文字没有重复声明已经表达的类型、必填性与取值

**反例**

```typescript
/** 布尔值，默认 false */
with_children: z.boolean().default(false),
```

注释复述了声明，没有说明这个字段的业务含义
