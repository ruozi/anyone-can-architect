# Doc Design: testcase

## 1 Purpose

A black-box test plan for a unit, driven through external entry points to verify the behavior defined by its external contract
A unit is a test subject with a clear external boundary and can be the entire project or a module within the project

Interface behavior is based on the external contract in [interface](interface.md)
User interaction behavior is based on the corresponding interaction design
Black-box and white-box tests for commands and events belong in the specific design files for [command](command.md) and [event](event.md)
White-box tests for a module's internal mechanisms belong in [class-design](class-design.md)

## 2 Structure

Organize the entire doc using the [test case](../patterns/testcase.md) pattern

```text
## 1 Fixtures
## 2 Test Scenarios
## 3 Test Cases
```

## 3 Writing Steps

1. Define the test unit and its external boundary, and list the external contracts and interaction behaviors to verify
2. Define the execution environment, entry points for driving tests, and result observation points based on how the test subject is used externally
3. Derive test points for normal behavior, failures, boundaries, state changes, and side effects from the sources above
4. Write using the [test case](../patterns/testcase.md) pattern

## 4 Example

See the [order testing example](../patterns/testcase.md#3-order-test-example) and [intent recognition evaluation example](../patterns/testcase.md#4-intent-recognition-evaluation-example) in the test case pattern

## 5 Checklist

- [ ] Tests are based on external contracts and interaction designs, not derived from internal implementation branches or private state
- [ ] Tests are driven through external entry points and assert the results, side effects, and prohibited behavior defined by the contract
- [ ] The execution environment, entry points for driving tests, and result observation points are clear enough to execute test cases and determine their results
- [ ] Meets the [test case checklist](../patterns/testcase.md#5-checklist)
