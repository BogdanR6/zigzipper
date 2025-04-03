const std = @import("std");

/// Compares two slices and returns whether they are equal.
pub fn eql(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    if (a.ptr == b.ptr) return true;
    for (a, b) |aElem, bElem| {
        if (aElem != bElem) return false;
    }
    return true;
}

fn compressNBytes(ch: u8, n: u16) u16 {
    return (n << 7) + ch;
}

fn decompressTwoBytes(allocator: std.mem.Allocator, compressedBytes: u16) ![]u8 {
    const ch: u8 = @truncate(compressedBytes & 0x7f);
    const len: usize = @as(usize, compressedBytes >> 7);

    const decodedStr = try allocator.alloc(u8, len);

    @memset(decodedStr, ch);

    return decodedStr;
}

fn unzip(readPath: []const u8, writePath: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit(); // Clean up allocator
    const allocator = gpa.allocator();

    const rfile = try std.fs.cwd().openFile(readPath, .{ .mode = .read_only });
    defer rfile.close();
    const reader = rfile.reader();

    const wfile = try std.fs.cwd().openFile(writePath, .{ .mode = .write_only });
    defer wfile.close();
    const writer = wfile.writer();

    var buf: [2]u8 = undefined;
    while (try reader.read(&buf) == 2) {
        // convert to u16 (little endien)
        const compressedBytes: u16 = @as(u16, buf[0]) | (@as(u16, buf[1]) << 8);
        const decompressedStr: []u8 = try decompressTwoBytes(allocator, compressedBytes);

        try writer.writeAll(decompressedStr);
        allocator.free(decompressedStr);
    }
}

fn zip(readPath: []const u8, writePath: []const u8) !void {
    const rfile = try std.fs.cwd().openFile(readPath, .{ .mode = .read_only });
    defer rfile.close();
    const reader = rfile.reader();

    const wfile = try std.fs.cwd().openFile(writePath, .{ .mode = .write_only });
    defer wfile.close();
    const writer = wfile.writer();

    var lastByte: u8 = 0;
    var count: u16 = 0;
    while (reader.readByte()) |byte| {
        if (lastByte != byte or count >= 511) {
            if (count > 0) {
                const compressed_bytes: u16 = compressNBytes(lastByte, count);
                const buffer = std.mem.toBytes(compressed_bytes);
                try writer.writeAll(&buffer);
            }
            lastByte = byte;
            count = 1;
        } else if (lastByte == byte) count += 1;
    } else |err| {
        if (err != error.EndOfStream) {
            std.log.err("Failed to read file: {s}", .{@errorName(err)});
            return err;
        }
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.debug;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len != 4) {
        stderr.print("Invalid Usage.\n Usage: zipper <zip/unzip> <input_file> <output_file>\n", .{});
        return;
    }

    if (eql(u8, args[2], args[3])) {
        stderr.print("Error: Can't use the same file for both input and output!\n", .{});
        return;
    }

    if (eql(u8, args[1], "zip")) {
        try stdout.print("Zip Zip Zipping..\n", .{});
        try zip(args[2], args[3]);
        try stdout.print("Zip Zip Zipped!\n", .{});
    } else if (eql(u8, args[1], "unzip")) {
        try stdout.print("Zip Zip UnZipping..\n", .{});
        try unzip(args[2], args[3]);
        try stdout.print("Zip Zip UnZipped!\n", .{});
    } else {
        stderr.print("Invalid option {s} for first argument.\n", .{args[1]});
        return;
    }
    return;
}
