# Data Contract (Schema)

## 1 When to Use

Express the structure and validation contract for a set of data

**Prerequisite: The target language or data description specification has been confirmed**

## 2 Presentation Principles

All the following content is required, in the order shown in the table

| Content | Presentation rules |
| --- | --- |
| Contract declaration | [§2.1](#21-contract-declaration) |
| Field descriptions | [§2.2](#22-field-descriptions) |

### 2.1 Contract Declaration

Use a code block to show native validation declarations in the target language or the selected data description specification
Put all declarable constraints directly in the declaration, including types, required fields, enums, value ranges, formats, and defaults
Declare whether objects accept undeclared fields
Include cross-field rules and conditional requirements in the declaration, and place anything the declaration cannot express in adjacent text that identifies the fields
Place contracts before other contracts that reference them
Define the same data in only one place
Do not include decisions about structurally valid but insufficient business data in the contract
When a contract needs derived variants, define them next to the original contract and state the differences
Criterion: Any party can determine whether data is valid from the declaration alone

### 2.2 Field Descriptions

Write field descriptions in documentation comments or description fields at the field declaration
Describe the business meaning of each field without taking any party's perspective or explaining how the data is produced or processed
For fields that can be omitted or null, state what omission, null, and an empty string each mean
For fields with defaults, normalization, or conversion applied during parsing, state how the parsed result differs from the input
Do not repeat types and constraints already expressed in the declaration

## 3 Target Language Example: Order Cancellation Parameters (TypeScript & zod)

```typescript
import { z } from "zod";

/** Cancellation reason */
export const CancelReasonSchema = z.enum([
  "customer_request", // Customer-requested cancellation
  "out_of_stock", // Out of stock
  "other", // Other
]);

/** Parameters for canceling an order */
export const CancelOrderParamsSchema = z
  .object({
    /** Order number; an empty string means the user did not specify one */
    order_no: z.union([z.literal(""), z.string().regex(/^[A-Za-z0-9]{6}$/)]).default(""),
    /** Cancellation reason; omission means customer-requested cancellation */
    reason: CancelReasonSchema.default("customer_request"),
    /** Additional details, with leading and trailing whitespace removed during parsing; must not be empty when reason is other, but may be an empty string otherwise */
    note: z.string().trim().default(""),
    /** Whether to cancel child orders as well; omission means cancel only this order */
    with_children: z.boolean().default(false),
  })
  .strict()
  .refine((p) => p.reason !== "other" || p.note !== "", {
    message: "note is required when reason is other",
    path: ["note"],
  });

export type CancelOrderParams = z.infer<typeof CancelOrderParamsSchema>;
```

## 4 Data Description Specification Example: Order Cancellation Parameters (JSON Schema 2020-12)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "CancelOrderParams",
  "description": "Parameters for canceling an order",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "order_no": {
      "description": "Order number; an empty string means the user did not specify one",
      "type": "string",
      "pattern": "^([A-Za-z0-9]{6})?$",
      "default": ""
    },
    "reason": {
      "description": "Cancellation reason; omission means customer-requested cancellation",
      "enum": ["customer_request", "out_of_stock", "other"],
      "default": "customer_request"
    },
    "note": {
      "description": "Additional details; must not be empty when reason is other, but may be an empty string otherwise",
      "type": "string",
      "default": ""
    },
    "with_children": {
      "description": "Whether to cancel child orders as well; omission means cancel only this order",
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

## 5 Checklist

### 5.1 Constraints Outside Declarations

- [ ] All declarable constraints are in the declaration, including types, required fields, enums, value ranges, formats, and defaults
- [ ] The declaration states whether objects accept undeclared fields
- [ ] Cross-field rules and conditional requirements are in the declaration, and anything it cannot express is written next to it with the fields identified

**Counterexample**

```typescript
export const CancelOrderParamsSchema = z.object({
  order_no: z.string(),
  reason: z.string(),
});
```

> `order_no` consists of 6 letters or digits, and `reason` can only be customer_request, out_of_stock, or other

The format and enum can both be declared, but leaving them in text means they have no effect during validation

### 5.2 Unclear Presence Semantics

- [ ] Every field that can be omitted or null states what omission, null, and an empty string each mean
- [ ] Defaults, normalization, or conversion applied during parsing are documented at the field

**Counterexample**

```typescript
/** Additional details */
note: z.string().optional(),
```

There is no explanation of whether omission and an empty string mean the same thing

### 5.3 Multiple Definitions for the Same Data

- [ ] Each set of data is defined in only one place
- [ ] Each contract name has only one shape across all docs

**Counterexample**

The order module's interface doc and the cancellation command's doc each define a `CancelOrderParams`, one with `with_children` and the other without it

Both definitions use the same name, so readers cannot tell which is authoritative, and changes will reach only one of them

### 5.4 Business Decisions Mixed into Contracts

- [ ] The contract only determines whether the structure and values are valid, without encoding business sufficiency decisions as required fields or value constraints

**Counterexample**

```typescript
/** Order number, required */
order_no: z.string().regex(/^[A-Za-z0-9]{6}$/),
```

When the user does not provide an order number, they should be prompted to supply it, but the contract rejects data that is not itself invalid

### 5.5 Text Repeats Declaration Content

- [ ] Field descriptions and text outside code blocks do not repeat types, required fields, or values already expressed in the declaration

**Counterexample**

```typescript
/** Boolean, defaults to false */
with_children: z.boolean().default(false),
```

The comment repeats the declaration without explaining the field's business meaning
