const std = @import("std");
const ArrayList = std.ArrayList;
pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_allocator.allocator();
    //defer _ = gpa.deinit();

    var timer = try std.time.Timer.start();
    defer std.debug.print("{}", .{std.fmt.fmtDuration(timer.read())});

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [2048]u8 = undefined;

    var reports = ArrayList([]i32).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var slices = ArrayList(i32).init(allocator);
        // Split values
        var iter = std.mem.splitSequence(u8, line, " ");
        //var count: u32 = 0;
        while (iter.next()) |slice| {
            const trimmed_slice = std.mem.trim(u8, slice, &std.ascii.whitespace);
            try slices.append(std.fmt.parseInt(i32, trimmed_slice, 10) catch |err| {
                std.debug.print("{}\n", .{err});
                return;
            });
        }
        // Use a copy because slices itself will be deallocated
        const owned = try slices.toOwnedSlice();
        try reports.append(owned);
    }
    // Input loaded and split

    // Count levels per report
    //const levels = reports.items[0].len;
    var safe: u32 = 0;
    ////std.debug.print("Reports: {d}\n", .{reports.items.len});

    // Count how many reports are safe
    for (reports.items) |report| {
        ////std.debug.print("Checking report: ", .{});
        //for (report) |level| {
        //std.debug.print("{d} ", .{level});
        //}
        ////std.debug.print("\n", .{});

        // Check if this report is safe
        // Satisfy two conditions to be safe:
        // 1. strictly increasing xor decreasing values (trend)
        // 2. a change of no more than 3 (stable)
        var trend: i32 = 0;
        var prev = report[0];
        var badLevels: i32 = 0;
        //skip first item
        for (report[1..], 0..) |level, idx| {

            // Calculate current trend vs previous trend
            const c_trend = prev - level;
            // Skip this check on the first iteration because there is no trend set yet!
            // As long as the difference between the previous level and the current level is not 0,
            // the data is trending either positive or negative.
            // Changes in polarity between the previous trend and the current trend
            // means the levels are no longer strictly increasing or decreasing, making it an 'unsafe' report.
            var badLevel: bool = false;
            if (idx != 0 and (c_trend == 0 or (c_trend < 0) != (trend < 0))) {
                // No change, meaning no trend
                // or
                // The trend has differed.
                // This report is not safe.
                badLevel = true;
            }
            // Ensure the absolute value in the difference between levels is never greater than 3.
            const diff = @abs(c_trend);
            if (diff < 1 or diff > 3) {
                // A change of more than 3 has happened, this report is not safe.
                badLevel = true;
            }
            if (badLevel) {
                badLevels += 1;
            }
            trend = c_trend;
            prev = level;
        }

        if (badLevels <= 1) {
            // This report is safe
            safe += 1;
        }
    }
    std.debug.print("Safe: {d}\n", .{safe});
}
