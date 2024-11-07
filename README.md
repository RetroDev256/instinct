# Instinct

An ultra simple set of distinct integer types.

### Use cases:
- You don't want to mix up array index types
- You want safety checks on an integer that must have a range
- You want the above, but with a value that represents null

### Types:
```zig
pub fn OptionalRangedInt(
    comptime T: type,
    comptime type_id: u32,
    comptime range: Range(T),
    comptime null_value: T,
) type { ... }

pub fn OptionalInt(
    comptime T: type,
    comptime type_id: u32,
    comptime null_value: T,
) type { ... }

pub fn RangedInt(
    comptime T: type,
    comptime type_id: u32,
    comptime range: Range(T),
) type { ... }

pub fn Int(
    comptime T: type,
    comptime type_id: u32,
) type { ... }
```

### Methods:
Each type provides the following methods:
- `init` creates a new distinct type
- `set` changes the value of the distinct type
- `val` fetches the value of the distinct type
- `cast` converts the distinct type to another distinct type
Limitation: you can't directly cast from an optional to non-optional type