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

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {

        // Parse List A & List B values
        var iter = std.mem.splitSequence(u8, line, "   ");
        var count: u32 = 0;
        while (iter.next()) |x| {
            if (count % 2 == 0) {
                const a_val = try std.fmt.parseInt(i32, x, 10);
                try list_a.append(a_val);
            } else {
                const b_val = try std.fmt.parseInt(i32, x, 10);
                try list_b.append(b_val);
            }
            count += 1;
        }
    }

    var dist = ArrayList(u32).init(allocator);

    std.mem.sort(i32, list_a.items[0..], {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list_b.items[0..], {}, comptime std.sort.asc(i32));

    for (list_a.items, 0..) |item, idx| {
        try dist.append(@abs(item - list_b.items[idx]));
    }

    std.debug.print("Distances:\n", .{});
    var sum: u32 = 0;
    for (dist.items) |val| {
        sum += val;
        //std.debug.print("{d}", .{val});
        //std.debug.print("\n", .{});
    }
    std.debug.print("{d}", .{sum});

    dist.deinit();
    list_a.deinit();
    list_b.deinit();
}
