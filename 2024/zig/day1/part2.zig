const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [2048]u8 = undefined;

    var list_a = ArrayList(i32).init(allocator);
    var list_b = ArrayList(i32).init(allocator);
    var dist = ArrayList(u32).init(allocator);

    defer list_a.deinit();
    defer list_b.deinit();
    defer dist.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // Parse List A & List B values
        var iter = std.mem.splitSequence(u8, line, "   ");
        //var count: u32 = 0;
        while (iter.next()) |x| {
            //std.debug.print("Observing slice: {s}\n", .{x});
            //std.debug.print("Slice length: {d}\n", .{x.len});
            //std.debug.print("Converting {s} to i32...\n", .{x});
            if (std.ascii.isWhitespace(x[x.len - 1])) {
                //std.debug.print("Removing whitespace char...\n", .{});
                const trimmed = x[0 .. x.len - 1];
                try list_b.append(std.fmt.parseInt(i32, trimmed, 10) catch |err| {
                    std.debug.print("{}\n", .{err});
                    return;
                });
            } else {
                try list_a.append(std.fmt.parseInt(i32, x, 10) catch |err| {
                    std.debug.print("{}\n", .{err});
                    return;
                });
            }
        }
    }

    std.mem.sort(i32, list_a.items[0..], {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list_b.items[0..], {}, comptime std.sort.asc(i32));

    var map = std.AutoHashMap(i32, u32).init(allocator);
    defer map.deinit();
    var itr = map.keyIterator();
    // take each number from list_a and find # of occurrences

    for (list_a.items) |a_item| {
        for (list_b.items) |b_item| {
            if (b_item == a_item) {
                const c = try map.getOrPut(a_item);
                if (!c.found_existing) {
                    c.value_ptr.* = 0;
                }
                const count = c.value_ptr.* + 1;
                try map.put(a_item, count);
            }
        }
    }
    itr = map.keyIterator();
    var sum: u32 = 0;
    while (itr.next()) |a_item| {
        const multiplier = map.get(a_item.*) orelse 1;
        sum += @as(u32, @intCast(a_item.*)) * multiplier;
    }
    std.debug.print("{d}", .{sum});
}
