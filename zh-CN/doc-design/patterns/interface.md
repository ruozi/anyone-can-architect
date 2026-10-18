# 模块接口（Interface）

## 1 适用场景

软件单元向外部提供的公共接口契约表达

适用于整个 SDK、服务的公开 API，也适用于项目内部技术模块的公共接口

**编写前提：已确认目标接口使用的语言或协议**

## 2 表达原则

| 内容 | 必需条件 | 表达规则 |
| --- | --- | --- |
| 接口定义 | 始终必需 | [§2.1](#21-接口定义) |
| 数据结构说明 | 始终必需 | [§2.2](#22-数据结构说明) |
| 业务解释 | 原生文档机制无法承载时必需 | [§2.3](#23-业务解释) |

### 2.1 接口定义

使用模块方法的原始声明或网络接口的接口描述规范
在声明关联的文档说明中写清调用目的、业务能力、结果交付方式、异常及触发条件
按需说明顺序、范围、空结果、失败、超时及业务副作用
接口具有幂等性时，说明重复调用的业务含义
会话、身份、事务等影响调用方义务或结果时属于契约，其内部实现机制归 Class Design
只描述调用方可观察、可验证的能力契约，不描述提供方的实现机制
判断标准：能力行为不变、内部实现更换后，这句话是否仍然成立

### 2.2 数据结构说明

使用类型声明及其文档注释、文档字符串或描述字段，已有定义直接引用
被依赖的类型在前，引用它的类型在后
在参数、返回类型与字段声明处说明业务含义、取值约束与适用的默认值
类型、必填性、枚举等可声明的约束直接写入声明，各类结果的业务含义写入对应的文档说明
沿类型依赖递归说明，直至所用语言或描述规范的基本数据类型
已有的公共、标准库或第三方类型及其说明直接引用，未覆盖的部分在当前接口补齐
需要运行时校验或被多处共用的数据结构按[数据契约](schema.md)定义，此处引用

### 2.3 业务解释

使用代码块外的文字或表格，仅补充原生文档机制未表达的业务含义与约束
每条业务解释标明对应的接口、字段或结果

## 3 模块方法示例：取消订单（TypeScript）

```typescript
export type OrderStatus =
  | "pending_payment" // 待付款
  | "paid" // 已付款
  | "cancelled"; // 已取消

/** 本次操作确认的订单摘要 */
export interface OrderSummary {
  /** 订单唯一标识，与输入的 orderId 一致 */
  readonly id: string;
  /** 本次操作确认的订单状态 */
  readonly status: OrderStatus;
}

export type CancelOrderResult =
  /** 本次订单取消已完成 */
  | { readonly outcome: "cancelled"; readonly order: OrderSummary }
  /** 订单此前已经取消 */
  | { readonly outcome: "already_cancelled"; readonly order: OrderSummary }
  /** 订单已经付款，不能取消 */
  | { readonly outcome: "not_allowed"; readonly order: OrderSummary }
  /** 指定订单不存在 */
  | { readonly outcome: "not_found" };

/**
 * 申请取消指定订单
 * 同一订单重复调用不会产生额外的取消效果
 * @param orderId 订单标识，不能为空或仅含空白字符
 * @returns 通过 Promise 异步交付取消结果，不另设回调
 * @remarks 订单标识不合法时 Promise 以 TypeError 拒绝；
 * 未能获得取消结果时以普通 Error 拒绝
 * @see https://tc39.es/ecma262/multipage/control-abstraction-objects.html#sec-promise-objects
 * @see https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-error-objects
 */
export declare function cancelOrder(
  orderId: string
): Promise<CancelOrderResult>;
```

## 4 HTTPS 接口示例：取消订单（OpenAPI 3.1）

```json
{
  "openapi": "3.1.1",
  "info": {
    "title": "订单取消接口",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "https://api.example.com"
    }
  ],
  "components": {
    "schemas": {
      "OrderId": {
        "type": "string",
        "pattern": "\\S",
        "description": "订单唯一标识，不能为空或仅含空白字符"
      },
      "CancelOrderResult": {
        "type": "object",
        "required": [
          "orderId",
          "outcome"
        ],
        "properties": {
          "orderId": {
            "$ref": "#/components/schemas/OrderId",
            "description": "本次申请取消的订单标识，与路径中的 orderId 一致"
          },
          "outcome": {
            "description": "本次请求的处理结果标识",
            "oneOf": [
              {
                "const": "cancelled",
                "description": "本次订单取消已完成"
              },
              {
                "const": "already_cancelled",
                "description": "订单此前已经取消"
              }
            ]
          }
        },
        "description": "本次请求的取消结果"
      }
    }
  },
  "paths": {
    "/orders/{orderId}/cancel": {
      "post": {
        "parameters": [
          {
            "name": "orderId",
            "in": "path",
            "required": true,
            "schema": {
              "$ref": "#/components/schemas/OrderId"
            },
            "description": "要取消的订单唯一标识"
          }
        ],
        "responses": {
          "200": {
            "description": "本次请求的取消结果",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CancelOrderResult"
                }
              }
            }
          },
          "400": {
            "description": "订单标识不合法；无响应体"
          },
          "404": {
            "description": "指定订单不存在；无响应体"
          },
          "409": {
            "description": "订单已经付款，不能取消；无响应体"
          },
          "500": {
            "description": "未能获得取消结果；无响应体"
          }
        },
        "summary": "申请取消指定订单",
        "description": "同一订单重复调用不会产生额外的取消效果；结果在本次 HTTPS 响应中返回，不另设回调；请求不携带请求体"
      }
    }
  }
}
```

## 5 检查条件

### 5.1 接口契约混入实现机制

- [ ] 能力行为不变、内部实现更换后，接口描述仍成立
- [ ] 实现机制未替代调用方可验证的行为约束

**反例**

| 实现视角（归 Class Design） | 调用方视角（归 Interface） |
| --- | --- |
| 取消前对订单加行锁，再更新状态 | 同一订单并发取消只生效一次，其余调用返回已取消 |
| 并行查询库存与物流，超时取消在途请求 | 超时时返回已查到的信息，未查到的部分标记为超时 |
| 查询走只读副本，不参与事务 | 查询不会修改订单 |

### 5.2 说明与声明分离

- [ ] 接口与数据结构均有声明及说明，优先使用目标技术栈的原生文档机制
- [ ] 独立业务解释仅补充原生文档机制无法承载的内容，且能定位对应声明

**反例**

目标语言支持文档注释，却将方法声明留空不注释，参数约束与输出含义全部另列在代码块外的表格中

调用方必须在声明与表格之间对照，接口契约未在声明处完整表达

### 5.3 接口定义不规范或类型顺序不符

- [ ] 模块方法使用对应语言的原始声明，网络接口按所选接口描述规范定义
- [ ] 数据结构使用对应语言的类型声明或所选接口描述规范定义
- [ ] 数据结构声明中，被依赖的类型在前，引用它的类型在后

**反例**

目标技术栈为 TypeScript，却用以下内容替代声明

```text
取消订单（订单编号）→ 取消结果
订单摘要：包含订单编号、订单状态
```

这只是自然语言描述，不能替代方法签名与类型声明

采用 OpenAPI 描述接口，却只用以下 JSON 响应样例替代数据结构定义

```json
{
  "orderId": "order-001",
  "outcome": "cancelled"
}
```

该样例未定义字段是否必填，也未定义 `outcome` 的完整允许取值

### 5.4 数据结构说明不完整

- [ ] 每个输入、输出及其数据字段均有业务含义、取值约束与适用的默认值说明
- [ ] 沿类型依赖递归说明，直至所用语言或描述规范的基本数据类型
- [ ] 已有公共、标准库或第三方类型引用能定位到对应定义与说明，未覆盖的部分在当前接口补齐

**反例**

```typescript
export interface OrderSummary {
  readonly status: OrderStatus;
}
```

> `status`：订单状态，见公共类型

既没有给出 `OrderStatus` 的定义与取值含义，也没有提供具体引用位置，无法继续查到完整说明

### 5.5 接口能力或输出含义不清

- [ ] 说明调用目的、接口提供的业务能力，以及已约定的各类输出结果的业务含义与交付方式
- [ ] 适用的顺序、范围、空结果、失败、超时及业务副作用均有明确约定
- [ ] 接口具有幂等性时，说明重复调用的业务含义

**反例**

```typescript
/** 取消订单 */
export declare function cancelOrder(orderId: string): Promise<CancelOrderResult>;
```

没有说明重复调用、订单不存在、订单已付款时各自得到什么结果，调用方无法据此处理任何一种非正常情况

### 5.6 文字复述了声明已表达的内容

- [ ] 原生文档说明补充业务含义与约束，不重复声明已经明确的类型、只读性等信息

**反例**

```typescript
export interface OrderSummary {
  /** 只读的 string 类型 */
  readonly id: string;
}
```

字段说明重复了代码声明，没有补充业务含义

