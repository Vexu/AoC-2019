const std = @import("std");
const Orbits = std.ArrayList(*Orbit);
const mem = std.mem;
const Allocator = mem.Allocator;

const Orbit = struct {
    name: []const u8,
    parent: ?*Orbit,
    children: Orbits,

    fn init(allocator: *Allocator, name: []const u8) !*Orbit {
        var orb = try allocator.create(Orbit);
        orb.* = .{
            .name = name,
            .parent = null,
            .children = Orbits.init(allocator),
        };
        return orb;
    }

    fn addChild(orbit: *Orbit, child: *Orbit) !void {
        try orbit.children.append(child);
        child.parent = orbit;
    }

    fn traverse(orbit: *Orbit) u32 {
        var total: u32 = 0;
        for (orbit.children.toSliceConst()) |o| {
            total += o.traverse();
        }
        total += orbit.countOrbits();
        return total;
    }

    fn countOrbits(orbit: *Orbit) u32 {
        var total: u32 = 0;
        var parent = orbit.parent;
        while (parent) |p| {
            total += 1;
            parent = p.parent;
        }
        return total;
    }

    fn toSanta(orbit: *Orbit) u32 {
        var total: u32 = 0;
        var next = orbit.parent.?;
        while (true) {
            if (mem.eql(u8, "SAN", next.name)) {
                break;
            }
            next = for (next.children.toSliceConst()) |o| {
                if (o.hasSanta())
                    break o;
            } else
                next.parent.?;
            total += 1;
        }
        return total - 1; // first and last don't count
    }

    fn hasSanta(orbit: *Orbit) bool {
        if (mem.eql(u8, "SAN", orbit.name)) {
            return true;
        }
        for (orbit.children.toSliceConst()) |o| {
            if (o.hasSanta()) {
                return true;
            }
        }
        return false;
    }
};

const Map = std.StringHashMap(*Orbit);
var all: Map = undefined;

fn parseOrbits(allocator: *Allocator, list: []const u8) !*Orbit {
    all = Map.init(allocator);

    var it = std.mem.tokenize(list, "\n");
    var root: ?*Orbit = null;
    while (it.next()) |o| {
        if (o.len == 0)
            break;

        const parent_name = o[0..3];
        const child_name = o[4..];
        var parent = if (all.get(parent_name)) |p|
            p.value
        else
            try Orbit.init(allocator, parent_name);
        _ = try all.put(parent_name, parent);

        var child = if (all.get(child_name)) |p|
            p.value
        else
            try Orbit.init(allocator, child_name);
        _ = try all.put(child_name, child);

        try parent.addChild(child);

        if (root == null) {
            root = parent;
        } else while (root.?.parent) |p| {
            root = p;
        }
    }
    return root.?;
}

fn puzzle1(root: *Orbit) void {
    std.debug.warn("checksum: {}\n", root.traverse());
}

fn puzzle2() void {
    const you = all.get("YOU").?.value;
    std.debug.warn("to santa: {}\n", you.toSanta());
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var file = try std.fs.cwd().openFile("6.in", .{});
    var list = try file.inStream().stream.readAllAlloc(alloc, 10000);
    file.close();

    var root = try parseOrbits(alloc, list);

    puzzle1(root);
    puzzle2();
}
