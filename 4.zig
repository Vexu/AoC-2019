const std = @import("std");
const mem = std.mem;
const math = std.math;

fn split() [2][]const u8 {
    var arr: [2][]const u8 = undefined;
    var it = mem.separate(RANGE, "-");
    arr[0] = it.next().?;
    arr[1] = it.next().?;
    std.debug.assert(it.next() == null);
    return arr;
}

const RANGE = "108457-562041";

fn toInt(char: u8) u8 {
    return char - '0';
}

fn incr(num: *[6]u8) void {
    var i: u8 = 5;
    while (i >= 0) : (i -= 1) {
        var res = num[i] + 1;
        if (res > 9) {
            num[i] = 0;
        } else {
            num[i] = res;
            return;
        }
        if (i == 0) {
            return;
        }
    }
}

fn puzzle1() void {
    var s = split();

    var num: [6]u8 = undefined;
    for (s[0]) |c, i| {
        num[i] = toInt(c);
    }

    var count: usize = 0;
    var i = std.fmt.parseInt(usize, s[0], 10) catch unreachable;
    const end = std.fmt.parseInt(usize, s[1], 10) catch unreachable;
    outer: while (i <= end) : ({
        i += 1;
        incr(&num);
    }) {
        var double = false;
        var j: usize = 0;
        while (j < 5) : (j += 1) {
            if (num[j] == num[j + 1])
                double = true
            else if (num[j] > num[j + 1])
                continue :outer;
        }
        if (double)
            count += 1;
    }
    std.debug.warn("valid passwords: {}\n", count);
}

fn puzzle2() void {
    var s = split();

    var num: [6]u8 = undefined;
    for (s[0]) |c, i| {
        num[i] = toInt(c);
    }

    var count: usize = 0;
    var i = std.fmt.parseInt(usize, s[0], 10) catch unreachable;
    const end = std.fmt.parseInt(usize, s[1], 10) catch unreachable;
    outer: while (i <= end) : ({
        i += 1;
        incr(&num);
    }) {
        var valid = false;
        var double: u8 = 0;
        var dc: ?u8 = null;
        var j: usize = 0;
        while (j < 5) : (j += 1) {
            if (num[j] == num[j + 1]) {
                if (dc != null and dc.? == num[j]) {
                    double -= 1;
                    while (j < 4 and num[j + 1] == dc.?) : (j += 1) {}
                    dc = null;
                } else {
                    dc = num[j];
                    double += 1;
                    valid = true;
                }
            }
            if (num[j] > num[j + 1]) {
                continue :outer;
            }
        }
        if (valid and double > 0) {
            count += 1;
        }
    }
    std.debug.warn("valid passwords: {}\n", count);
}

pub fn main() void {
    puzzle1();
    puzzle2();
}
