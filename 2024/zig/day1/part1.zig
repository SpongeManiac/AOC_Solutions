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
    var slices = ArrayList(i32).init(allocator);

    defer list_a.deinit();
    defer list_b.deinit();
    defer dist.deinit();
    defer slices.deinit();

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

    for (list_a.items, 0..) |item, idx| {
        try dist.append(@abs(item - list_b.items[idx]));
    }

    //std.debug.print("Distances:\n", .{});
    var sum: u32 = 0;
    for (dist.items) |val| {
        sum += val;
        //std.debug.print("{d}", .{val});
        //std.debug.print("\n", .{});
    }
    std.debug.print("Sum: {d}", .{sum});
}
