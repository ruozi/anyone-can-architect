# Module Interface

## 1 When to Use

Express the public interface contract that a software unit provides to external callers

Applies to the public API of an entire SDK or service, and to the public interfaces of internal technical modules in a project

**Prerequisite: The language or protocol used by the target interface has been confirmed**

## 2 Presentation Principles

| Content | Required When | Presentation Rules |
| --- | --- | --- |
| Interface definition | Always required | [§2.1](#21-interface-definition) |
| Data structure descriptions | Always required | [§2.2](#22-data-structure-descriptions) |
| Business explanation | Required when declarations and their associated descriptions cannot accommodate it | [§2.3](#23-business-explanation) |

### 2.1 Interface Definition

Choose the expression according to the language or protocol that callers use, as shown for common interfaces below

| Interface object | Expression | Contract content |
| --- | --- | --- |
| Language method | Original declaration and documentation mechanism of the corresponding language | Method signature, parameters, return, and exceptions |
| HTTP interface | Selected interface description specification, such as OpenAPI | HTTP method, path, authentication, request, and response |
| Event interface | Event contract of the selected protocol | Connection entry point, event name, sending direction, message structure, and acknowledgement method |

Define other protocols with the interface description method of the selected protocol
In the documentation associated with the declaration, specify the call purpose, business capabilities, result delivery method, exceptions, and their triggering conditions
Describe ordering, scope, empty results, failures, timeouts, and business side effects as needed
If the interface is idempotent, explain the business meaning of repeated calls
Sessions, identity, and transactions are part of the contract when they affect caller obligations or results, while their internal implementation mechanisms belong in Class Design
Describe only capability contracts that callers can observe and verify, without describing the provider's implementation mechanisms
Criterion: Does this statement still hold when capability behavior stays the same but the internal implementation changes

### 2.2 Data Structure Descriptions

Use type declarations of the corresponding language or the selected data description specification, and write descriptions in documentation comments, docstrings, or description fields
Reference existing definitions directly
Place dependency types before the types that reference them
Describe business meaning, value constraints, and applicable defaults at parameter, return type, and field declarations
Put declarable constraints such as types, required fields, and enumerations directly in declarations, and put the business meaning of each result in its corresponding documentation
Follow type dependencies recursively until reaching the primitive data types of the language or description specification in use
Reference existing public, standard library, or third-party types and their documentation directly, and fill any gaps in the current interface
Define data structures that need runtime validation or are shared in multiple places according to [Data Contract](schema.md), and reference them here

### 2.3 Business Explanation

Use text or tables outside code blocks only to supplement business meaning and constraints not expressed by declarations and their associated descriptions
Identify the corresponding interface, field, or result for each business explanation

## 3 Module Method Example: Cancel an Order (TypeScript)

```typescript
export type OrderStatus =
  | "pending_payment" // Awaiting payment
  | "paid" // Paid
  | "cancelled"; // Cancelled

/** Order summary confirmed by this operation */
export interface OrderSummary {
  /** Unique order identifier, matching the input orderId */
  readonly id: string;
  /** Order status confirmed by this operation */
  readonly status: OrderStatus;
}

export type CancelOrderResult =
  /** This order cancellation is complete */
  | { readonly outcome: "cancelled"; readonly order: OrderSummary }
  /** The order was already cancelled */
  | { readonly outcome: "already_cancelled"; readonly order: OrderSummary }
  /** The order has been paid and cannot be cancelled */
  | { readonly outcome: "not_allowed"; readonly order: OrderSummary }
  /** The specified order does not exist */
  | { readonly outcome: "not_found" };

/**
 * Request cancellation of the specified order
 * Repeated calls for the same order produce no additional cancellation effects
 * @param orderId Order identifier, which must not be empty or contain only whitespace
 * @returns Delivers the cancellation result asynchronously through a Promise, with no separate callback
 * @remarks The Promise rejects with a TypeError if the order identifier is invalid;
 * it rejects with a regular Error if the cancellation result cannot be obtained
 * @see https://tc39.es/ecma262/multipage/control-abstraction-objects.html#sec-promise-objects
 * @see https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-error-objects
 */
export declare function cancelOrder(
  orderId: string
): Promise<CancelOrderResult>;
```

## 4 HTTPS Interface Example: Cancel an Order (OpenAPI 3.1)

```json
{
  "openapi": "3.1.1",
  "info": {
    "title": "Order cancellation interface",
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
        "description": "Unique order identifier, which must not be empty or contain only whitespace"
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
            "description": "Identifier of the order requested for cancellation, matching orderId in the path"
          },
          "outcome": {
            "description": "Identifier of the processing outcome for this request",
            "oneOf": [
              {
                "const": "cancelled",
                "description": "This order cancellation is complete"
              },
              {
                "const": "already_cancelled",
                "description": "The order was already cancelled"
              }
            ]
          }
        },
        "description": "Cancellation result for this request"
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
            "description": "Unique identifier of the order to cancel"
          }
        ],
        "responses": {
          "200": {
            "description": "Cancellation result for this request",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/CancelOrderResult"
                }
              }
            }
          },
          "400": {
            "description": "Invalid order identifier; no response body"
          },
          "404": {
            "description": "The specified order does not exist; no response body"
          },
          "409": {
            "description": "The order has been paid and cannot be cancelled; no response body"
          },
          "500": {
            "description": "The cancellation result could not be obtained; no response body"
          }
        },
        "summary": "Request cancellation of the specified order",
        "description": "Repeated calls for the same order produce no additional cancellation effects; the result is returned in this HTTPS response, with no separate callback; the request has no request body"
      }
    }
  }
}
```

## 5 Socket.IO Event Example: Cancel an Order and Status Notification

Use Socket.IO 4.x, and express the event maps according to the [official type declarations](../../SSOT.md#6-api-design)
Use a zod [data contract](schema.md#21-contract-declaration) for payloads, and derive event parameter types from the validation declarations

### 5.1 Connection and Authentication

The two events in this chapter share the following conventions

| Item | Convention |
| --- | --- |
| Server URL | `https://api.example.com` |
| Connection path | `/socket.io/` |
| Namespace | `/orders` |
| Connection authentication | `auth.token` carries the order access token, with the structure in `OrderAuthSchema` |
| Authentication failure | Connection rejected, and the client receives `connect_error` with `message` set to `UNAUTHORIZED` |

### 5.2 Message Data

```typescript
import { z } from "zod";

/** Unique order identifier, which must not be empty or contain only whitespace */
const OrderIdSchema = z.string().regex(/\S/);

export const OrderAuthSchema = z.object({
  /** Order access token already obtained */
  token: z.string().min(1),
}).strict();

export const OrderSchema = z.object({
  id: OrderIdSchema,
  /** Current business status of the order */
  status: z.enum([
    "pending_payment", // Awaiting payment
    "paid", // Paid
    "cancelled", // Cancelled
  ]),
}).strict();

export const CancelRequestSchema = z.object({
  /** Order requested for cancellation */
  orderId: OrderIdSchema,
}).strict();

const CancelledOrderSchema = OrderSchema.extend({ status: z.literal("cancelled") });
const PaidOrderSchema = OrderSchema.extend({ status: z.literal("paid") });

export const CancelAckSchema = z.discriminatedUnion("outcome", [
  // This cancellation is complete; returns the cancelled order
  z.object({ outcome: z.literal("cancelled"), order: CancelledOrderSchema }).strict(),
  // The order was already cancelled; returns the current order
  z.object({ outcome: z.literal("already_cancelled"), order: CancelledOrderSchema }).strict(),
  // The order has been paid; returns the current order
  z.object({ outcome: z.literal("not_allowed"), order: PaidOrderSchema }).strict(),
  // The specified order does not exist
  z.object({ outcome: z.literal("not_found") }).strict(),
  // The request does not match CancelRequestSchema
  z.object({ outcome: z.literal("invalid_request") }).strict(),
  // The current identity has no permission to operate on the order
  z.object({ outcome: z.literal("forbidden") }).strict(),
  // This processing could not confirm the cancellation result
  z.object({ outcome: z.literal("failed") }).strict(),
]);

/** The client has received this order status notification */
export const StatusAckSchema = z.object({
  outcome: z.literal("received"),
}).strict();

export type Order = z.infer<typeof OrderSchema>;
export type CancelRequest = z.infer<typeof CancelRequestSchema>;
export type CancelAck = z.infer<typeof CancelAckSchema>;
export type StatusAck = z.infer<typeof StatusAckSchema>;
```

### 5.3 Event Declarations by Direction

Combine the following declarations with the [message data](#52-message-data) into one TypeScript file

```typescript
import type { Socket } from "socket.io-client";

export interface ClientToServerEvents {
  /**
   * The client requests the server to cancel an order
   * The order must be within the scope that the current identity can operate on
   * @param request Cancellation request, validated against CancelRequestSchema
   * @param ack Delivers the business result of this cancellation, validated against CancelAckSchema
   * @remarks If no acknowledgement arrives within 5 seconds or the connection drops, the client can resend the same orderId;
   * an already cancelled order returns already_cancelled and produces no additional cancellation effects
   */
  "order.cancel": (request: CancelRequest, ack: (result: CancelAck) => void) => void;
}

export interface ServerToClientEvents {
  /**
   * The server pushes to the client the latest status of an order that the current identity can access
   * @param order Order status, validated against OrderSchema
   * @param ack The client acknowledges receipt of this notification, validated against StatusAckSchema
   * @remarks The server waits 5 seconds for the acknowledgement, and in this example does not resend the notification after a timeout;
   * after reconnection, the server pushes the latest status of the orders currently accessible
   */
  "order.status": (order: Order, ack: (result: StatusAck) => void) => void;
}

/** The client receives ServerToClientEvents and sends ClientToServerEvents */
export type OrderSocket = Socket<ServerToClientEvents, ClientToServerEvents>;
```

## 6 Checklist

### 6.1 Implementation Mechanisms Mixed into Interface Contracts

- [ ] The interface description still holds when capability behavior stays the same but the internal implementation changes
- [ ] Implementation mechanisms do not replace behavioral constraints that callers can verify

**Counterexamples**

| Implementation perspective (belongs in Class Design) | Caller perspective (belongs in Interface) |
| --- | --- |
| Acquire a row lock on the order before cancellation, then update its status | Concurrent cancellations of the same order take effect only once, and all other calls return already cancelled |
| Query inventory and logistics in parallel, and cancel in-flight requests on timeout | On timeout, return the information already retrieved and mark the unretrieved portions as timed out |
| Query a read-only replica without participating in a transaction | The query does not modify the order |

### 6.2 Descriptions Separate from Declarations

- [ ] Interfaces and data structures are declared in the language or protocol that callers use, with descriptions in the corresponding documentation mechanism or description fields
- [ ] Separate business explanations only supplement content that declarations and their associated descriptions cannot accommodate, and identify the corresponding declarations

**Counterexample**

The target language supports documentation comments, but method declarations have no comments, and all parameter constraints and output meanings are listed separately in a table outside the code block

Callers must cross-reference the declarations and the table because the interface contract is not fully expressed at the declarations

### 6.3 Nonstandard Interface Definitions or Type Order Mismatch

- [ ] Module methods use the original declarations of the corresponding language, and network interfaces follow the selected interface description specification
- [ ] The connection entry point of a network interface is locatable, and event contracts specify the event name and sending direction
- [ ] When an acknowledgement mechanism is used, the business meaning of each acknowledgement result is clear
- [ ] Data structures use type declarations of the corresponding language or definitions in the selected interface description specification
- [ ] Data structure declarations place dependency types before the types that reference them

**Counterexamples**

The target technology stack is TypeScript, but the following content replaces declarations

```text
Cancel order (order number) → Cancellation result
Order summary: Contains order number and order status
```

This is only a natural-language description and cannot replace method signatures and type declarations

The interface uses OpenAPI, but only the following sample JSON response replaces the data structure definition

```json
{
  "orderId": "order-001",
  "outcome": "cancelled"
}
```

This sample defines neither whether fields are required nor the complete set of allowed values for `outcome`

### 6.4 Incomplete Data Structure Descriptions

- [ ] Each input, output, and data field has descriptions of its business meaning, value constraints, and applicable defaults
- [ ] Descriptions follow type dependencies recursively until reaching the primitive data types of the language or description specification in use
- [ ] References to existing public, standard library, or third-party types identify their definitions and documentation, and any gaps are filled in the current interface

**Counterexample**

```typescript
export interface OrderSummary {
  readonly status: OrderStatus;
}
```

> `status`: Order status, see the public type

Neither the definition and value meanings of `OrderStatus` nor a specific reference location is provided, so the complete description cannot be found

### 6.5 Unclear Interface Capabilities or Output Meaning

- [ ] Describe the call purpose, the business capabilities provided by the interface, and the business meaning and delivery method of each agreed output result
- [ ] Applicable ordering, scope, empty results, failures, timeouts, and business side effects are explicitly specified
- [ ] If the interface is idempotent, explain the business meaning of repeated calls

**Counterexample**

```typescript
/** Cancel an order */
export declare function cancelOrder(orderId: string): Promise<CancelOrderResult>;
```

The results for repeated calls, nonexistent orders, and paid orders are not explained, so callers cannot use this description to handle any of these exceptional cases

### 6.6 Text Repeats Declaration Content

- [ ] Descriptions associated with declarations supplement business meaning and constraints without repeating information already explicit in declarations, such as types and read-only properties

**Counterexample**

```typescript
export interface OrderSummary {
  /** Read-only string type */
  readonly id: string;
}
```

The field description repeats the code declaration without adding business meaning

