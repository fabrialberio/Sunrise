const std = @import("std");
const config = @import("config");
const gobject = @import("gobject");
const gtk = @import("gtk");
const libintl = @import("libintl");

const libc = @cImport({
    @cInclude("locale.h");
});

pub fn setupLocale() !void {
    // In order to load the locale files, the directory needs to be determined.
    // Usually, people use /usr/share/locale (which is the regular location) or
    // a local build directory specified at compile time, but that does not
    // allow for portable installations. Instead, we determine the location
    // relative to the application's binary location. When the application is in
    // /prefix/bin, the translation files are located in /prefix/share/locale.
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const locale_dir = getRelativeExeDir("share/locale", &buf);

    _ = libc.setlocale(libc.LC_ALL, null);
    _ = libintl.bindTextDomain(config.app_name, locale_dir);
    _ = libintl.setTextDomain(config.app_name);
}

pub fn getRelativeExeDir(path: [:0]const u8, buf: []u8) [:0]const u8 {
    return tryGetRelativeExeDir(path, buf) catch {
        return std.fmt.bufPrintZ(buf, "/usr/{s}", .{path}) catch {
            return path;
        };
    };
}

pub fn tryGetRelativeExeDir(path: []const u8, buf: []u8) ![:0]u8 {
    const self_exe = try std.fs.selfExeDirPath(buf);
    const bin_pos = std.mem.indexOf(u8, self_exe, "/bin") orelse return error.FileNotFound;
    const len = try std.fmt.bufPrintZ(buf[(bin_pos + 1)..], "{s}", .{path});
    return @ptrCast(buf[0..(bin_pos + len.len)]);
}

pub fn gettext(msgid: [*:0]const u8) [*:0]u8 {
    return libc.gettext(msgid);
}

pub fn ref(x: anytype) @TypeOf(x) {
    x.ref();
    return x;
}

pub fn getObjectFromBuilder(comptime T: type, comptime resource: []const u8, object_name: [*:0]const u8) *T {
    const builder = gtk.Builder.newFromResource(config.data_namespace ++ "/" ++ resource);
    defer builder.unref();
    const object = builder.getObject(object_name).?;
    return gobject.ext.cast(T, object).?;
}
