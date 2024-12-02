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

    std.mem.sort(i32, list_a.items[0..], {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list_b.items[0..], {}, comptime std.sort.asc(i32));

    var map = std.StringHashMap(u32).init(allocator);

    for (list_a) |a_item| {
        for (list_b) |b_item| {
            if (a_item == b_item) {
                const c = try map.getOrPut(item);
                if (!c.found_existing) {
                    c.value_ptr.* = 0;
                }
                const count = c.value_ptr.* + 1;
                map.put(item, count);
            }
        }
    }

    // take each number from list_a and multiply it by # of occurrences
    // Sum all products

    list_a.deinit();
    list_b.deinit();
}
