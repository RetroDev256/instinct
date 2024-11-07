const std = @import("std");
const assert = std.debug.assert;

/// For simple distinct ints; where you want to make sure
/// you do not accidentally use one type of index when you
/// should actually be using a different type of index.
/// - T is the type of integer
/// - type_id makes it distinct
pub fn Int(
    comptime T: type,
    comptime type_id: u32,
) type {
    return enum(T) {
        _,

        pub const id: u32 = type_id;
        pub fn init(value: T) @This() {
            return @enumFromInt(value);
        }
        pub fn set(self: *@This(), value: T) void {
            self.* = init(value);
        }
        pub fn val(self: @This()) T {
            return @intFromEnum(self);
        }
        pub fn cast(self: @This(), comptime Other: type) Other {
            return .init(self.val());
        }
    };
}

test Int {
    const A = Int(u32, 0);
    const B = Int(u32, 1);
    const C = Int(u32, 0);
    const D = Int(u64, 0);
    comptime assert(A != B); // Different ID
    comptime assert(A == C); // Same integer type and ID
    comptime assert(A != D); // Different integer type
}

/// For ranged distinct ints; where you want to make sure
/// you do not use the wrong type, as well as want to make
/// sure the value is never outside of certain bounds.
/// - T is the type of integer
/// - type_id makes it distinct
/// - range is inclusive on what is possible for the int
pub fn RangedInt(
    comptime T: type,
    comptime type_id: u32,
    comptime range: Range(T),
) type {
    return enum(T) {
        _,

        pub const id: u32 = type_id;
        pub fn init(value: T) @This() {
            assert(value >= range.low);
            assert(value < range.high);
            return @enumFromInt(value);
        }
        pub fn set(self: *@This(), value: T) void {
            self.* = init(value);
        }
        pub fn val(self: @This()) T {
            const value: T = @intFromEnum(self);
            assert(value >= range.low);
            assert(value < range.high);
            return value;
        }
        pub fn cast(self: @This(), comptime Other: type) Other {
            return .init(self.val());
        }
    };
}

test RangedInt {
    const A = RangedInt(u32, 0, .{ .low = 0, .high = 99 });
    const B = RangedInt(u32, 0, .{ .low = 0, .high = 99 });
    const C = RangedInt(u32, 1, .{ .low = 0, .high = 99 });
    const D = RangedInt(u32, 1, .{ .low = 1, .high = 10 });
    comptime assert(A == B); // Same integer type, ID, and range
    comptime assert(A != C); // Different ID
    comptime assert(C != D); // Different range
}

/// For nullable distinct ints; where you want a distinct packed
/// optional integer where you know a certain value is impossible.
/// - T is the type of integer
/// - type_id makes it distinct
/// - null_value is the enum value for representing "null"
pub fn OptionalInt(
    comptime T: type,
    comptime type_id: u32,
    comptime null_value: T,
) type {
    return enum(T) {
        _,

        pub const id: u32 = type_id;
        pub fn init(value: ?T) @This() {
            if (value) |real| {
                assert(real != null_value);
                return @enumFromInt(real);
            } else {
                return @enumFromInt(null_value);
            }
        }
        pub fn set(self: *@This(), value: ?T) void {
            self.* = init(value);
        }
        pub fn val(self: @This()) ?T {
            const value: T = @intFromEnum(self);
            if (value == null_value) {
                return null;
            } else {
                return value;
            }
        }
        pub fn cast(self: @This(), comptime Other: type) Other {
            return .init(self.val());
        }
    };
}

test OptionalInt {
    const A = OptionalInt(u32, 0, 0);
    const B = OptionalInt(u32, 0, 0xFFFF_FFFF);
    const C = OptionalInt(u32, 1, 2319);
    const D = OptionalInt(u32, 1, 0);
    comptime assert(A != B); // Different null value
    comptime assert(A != C); // Different null value and ID
    comptime assert(A != D); // Different ID
}

/// For distinct ranged nullable ints; where you want a packed
/// distinct integer with a asserted range, for example in
/// indexing a fixed size array for some additional data.
/// - T is the type of integer
/// - type_id makes it distinct
/// - null_value is the enum value for representing "null"
/// - range is inclusive on what is possible for the int
pub fn OptionalRangedInt(
    comptime T: type,
    comptime type_id: u32,
    comptime range: Range(T),
    comptime null_value: T,
) type {
    return enum(T) {
        _,

        pub const id: u32 = type_id;
        pub fn init(value: ?T) @This() {
            if (value) |real| {
                assert(real >= range.low);
                assert(real < range.high);
                assert(real != null_value);
                return @enumFromInt(real);
            } else {
                return @enumFromInt(null_value);
            }
        }
        pub fn set(self: *@This(), value: ?T) void {
            self.* = init(value);
        }
        pub fn val(self: @This()) ?T {
            const value: T = @intFromEnum(self);
            if (value == null_value) {
                return null;
            } else {
                assert(value >= range.low);
                assert(value < range.high);
                return value;
            }
        }
        pub fn cast(self: @This(), comptime Other: type) Other {
            return .init(self.val());
        }
    };
}

test OptionalRangedInt {
    const A = OptionalRangedInt(u32, 0, .{ .low = 0, .high = 100 }, 0);
    const B = OptionalRangedInt(u32, 0, .{ .low = 0, .high = 100 }, 0xFFFF_FFFF);
    const C = OptionalRangedInt(u32, 1, .{ .low = 0, .high = 100 }, 2319);
    const D = OptionalRangedInt(u32, 1, .{ .low = 0, .high = 100 }, 0);
    const E = OptionalRangedInt(u32, 1, .{ .low = 0, .high = 16 }, 2319);
    const F = OptionalRangedInt(u32, 1, .{ .low = 16, .high = 100 }, 2319);
    comptime assert(A != B); // Different null value
    comptime assert(A != C); // Different null value and ID
    comptime assert(A != D); // Different ID
    comptime assert(C != E); // Different range high bound
    comptime assert(C != F); // Different range low bound
}

/// low is inclusive
/// high is exclusive
fn Range(comptime T: type) type {
    return struct { low: T = 0, high: T };
}
