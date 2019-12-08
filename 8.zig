const std = @import("std");

const Img = std.ArrayList([]const u8);

fn readImage(alloc: *std.mem.Allocator, data: []const u8, height: u32, width: u32) !Img {
    var img = Img.init(alloc);
    var i: u32 = 0;
    while (i < data.len) : (i+= width * height) {
        try img.append(data[i..i + width * height]);
    }
    return img;
}

fn puzzle1(img: Img) void {
    var minzeroes: ?u32 = null;
    var maxones: u32 = 0;
    var maxtwos: u32 = 0;
    var layer: usize = 0;
    for (img.toSliceConst()) |l, i| {
        var zeros: u32 = 0;
        var ones: u32 = 0;
        var twos: u32 = 0;
        for (l) |c| {
            switch (c) {
                '0' => zeros += 1,
                '1' => ones += 1,
                '2' => twos += 1,
                else => {}
            }
        }
        if (minzeroes == null or zeros < minzeroes.?) {
            minzeroes = zeros;
            maxones = ones;
            maxtwos = twos;
        }
    }
    std.debug.warn("ans: {}\n", maxones * maxtwos);
}

fn toppm(alloc: *std.mem.Allocator, img: []const u8, width: u32, height: u32) !void {
    var ppm = try alloc.alloc(u8, 26 + width*height * 3);
    var out = &std.io.SliceOutStream.init(ppm).stream;
    try out.print("P6\n{} {}\n225\n", width, height);
    for (img) |c| {
        if (c == '0') {
            try out.writeIntLittle(u24, 0x000000);
        } else {
            try out.writeIntLittle(u24, 0xFFFFFF);
        }
    }

    var file = try std.fs.cwd().createFile("8.ppm", .{});
    try file.write(ppm);
    file.close();
}

fn puzzle2(alloc: *std.mem.Allocator, img: Img, width: u32) !void {
    var final = try alloc.alloc(u8, img.at(0).len);
    std.mem.set(u8, final, '2');
    for (img.toSliceConst()) |l| {
        for (l) |c, i| {
            if (final[i] == '2') {
                final[i] = c;
            }
        }
    }
    try toppm(alloc, final, width, @intCast(u32, @divExact(final.len, width)));
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var file = try std.fs.cwd().openFile("8.in", .{});
    var list = try file.inStream().stream.readAllAlloc(alloc, 20000);
    file.close();

    var img = try readImage(alloc, list, 6, 25);
    puzzle1(img);
    try puzzle2(alloc, img, 25);
}