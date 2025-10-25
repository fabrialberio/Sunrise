const std = @import("std");
const builtin = @import("builtin");
const adw = @import("adw");
const gio = @import("gio");
const gobject = @import("gobject");
const gtk = @import("gtk");
const config = @import("config");
const common = @import("common.zig");
const util = @import("util.zig");

const Window = @import("window.zig").Window;

pub const PreferencesDialog = extern struct {
    const Self = @This();

    pub const Parent = adw.PreferencesDialog;

    parent: Parent,
    private: Private,

    const Private = extern struct {
        children: extern struct {
            color_scheme: *adw.ComboRow,
        },
        settings: *gio.Settings,
    };

    pub const getGObjectType = gobject.ext.defineClass(Self, .{
        .flags = .{ .final = true },
        .instanceInit = &init,
        .classInit = &Class.init,
        .parent_class = &Class.parent,
    });

    pub fn init(self: *Self, _: *Class) callconv(.c) void {
        self.as(gtk.Widget).initTemplate();
    }

    pub fn new(settings: *gio.Settings) *Self {
        const self = gobject.ext.newInstance(Self, .{});
        self.private.settings = util.ref(settings);
        self.private.settings.bind("color-scheme", self.private.children.color_scheme.as(gobject.Object), "selected", .{});
        return self;
    }

    pub fn dispose(self: *Self) callconv(.c) void {
        self.as(gtk.Widget).disposeTemplate(getGObjectType());
        self.private.settings.unref();

        gobject.Object.virtual_methods.dispose.call(
            Class.parent,
            self.as(Parent),
        );
    }

    const Common = common.Common(Self);
    pub const as = Common.as;

    pub const Class = extern struct {
        parent_class: Parent.Class,
        var parent: *Parent.Class = undefined;
        pub const Instance = Self;

        fn init(class: *Class) callconv(.c) void {
            gobject.Object.virtual_methods.dispose.implement(class, &dispose);
            class.bindTemplate("prefs.ui");
        }

        pub const as = Common.Class.as;
        pub const bindTemplate = Common.Class.bindTemplate;
    };
};
