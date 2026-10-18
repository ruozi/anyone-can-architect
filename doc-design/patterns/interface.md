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
| Business explanation | Required when native documentation mechanisms cannot accommodate it | [§2.3](#23-business-explanation) |

### 2.1 Interface Definition

Use the original declaration of a module method or an interface description specification for a network interface
In the documentation associated with the declaration, specify the call purpose, business capabilities, result delivery method, exceptions, and their triggering conditions
Describe ordering, scope, empty results, failures, timeouts, and business side effects as needed
If the interface is idempotent, explain the business meaning of repeated calls
Sessions, identity, and transactions are part of the contract when they affect caller obligations or results, while their internal implementation mechanisms belong in Class Design
Describe only capability contracts that callers can observe and verify, without describing the provider's implementation mechanisms
Criterion: Does this statement still hold when capability behavior stays the same but the internal implementation changes

### 2.2 Data Structure Descriptions

Use type declarations and their documentation comments, docstrings, or description fields, and reference existing definitions directly
Place dependency types before the types that reference them
Describe business meaning, value constraints, and applicable defaults at parameter, return type, and field declarations
Put declarable constraints such as types, required fields, and enumerations directly in declarations, and put the business meaning of each result in its corresponding documentation
Follow type dependencies recursively until reaching the primitive data types of the language or description specification in use
Reference existing public, standard library, or third-party types and their documentation directly, and fill any gaps in the current interface
Define data structures that need runtime validation or are shared in multiple places according to [Data Contract](schema.md), and reference them here

### 2.3 Business Explanation

Use text or tables outside code blocks only to supplement business meaning and constraints not expressed by native documentation mechanisms
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

## 5 Checklist

### 5.1 Implementation Mechanisms Mixed into Interface Contracts

- [ ] The interface description still holds when capability behavior stays the same but the internal implementation changes
- [ ] Implementation mechanisms do not replace behavioral constraints that callers can verify

**Counterexamples**

| Implementation perspective (belongs in Class Design) | Caller perspective (belongs in Interface) |
| --- | --- |
| Acquire a row lock on the order before cancellation, then update its status | Concurrent cancellations of the same order take effect only once, and all other calls return already cancelled |
| Query inventory and logistics in parallel, and cancel in-flight requests on timeout | On timeout, return the information already retrieved and mark the unretrieved portions as timed out |
| Query a read-only replica without participating in a transaction | The query does not modify the order |

### 5.2 Descriptions Separate from Declarations

- [ ] Interfaces and data structures both have declarations and descriptions, preferably using the target technology stack's native documentation mechanisms
- [ ] Separate business explanations only supplement content that native documentation mechanisms cannot accommodate, and identify the corresponding declarations

**Counterexample**

The target language supports documentation comments, but method declarations have no comments, and all parameter constraints and output meanings are listed separately in a table outside the code block

Callers must cross-reference the declarations and the table because the interface contract is not fully expressed at the declarations

### 5.3 Nonstandard Interface Definitions or Type Order Mismatch

- [ ] Module methods use the original declarations of the corresponding language, and network interfaces follow the selected interface description specification
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

### 5.4 Incomplete Data Structure Descriptions

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

### 5.5 Unclear Interface Capabilities or Output Meaning

- [ ] Describe the call purpose, the business capabilities provided by the interface, and the business meaning and delivery method of each agreed output result
- [ ] Applicable ordering, scope, empty results, failures, timeouts, and business side effects are explicitly specified
- [ ] If the interface is idempotent, explain the business meaning of repeated calls

**Counterexample**

```typescript
/** Cancel an order */
export declare function cancelOrder(orderId: string): Promise<CancelOrderResult>;
```

The results for repeated calls, nonexistent orders, and paid orders are not explained, so callers cannot use this description to handle any of these exceptional cases

### 5.6 Text Repeats Declaration Content

- [ ] Native documentation supplements business meaning and constraints without repeating information already explicit in declarations, such as types and read-only properties

**Counterexample**

```typescript
export interface OrderSummary {
  /** Read-only string type */
  readonly id: string;
}
```

The field description repeats the code declaration without adding business meaning

