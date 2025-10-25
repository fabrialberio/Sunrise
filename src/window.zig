const std = @import("std");
const builtin = @import("builtin");
const adw = @import("adw");
const gobject = @import("gobject");
const gtk = @import("gtk");
const config = @import("config");
const util = @import("util.zig");

const Application = @import("app.zig").Application;

pub const Window = extern struct {
    const Self = @This();

    pub const Parent = adw.ApplicationWindow;

    parent: Parent,
    private: Private,

    const Private = extern struct {
        children: extern struct {
            new_background_button: *adw.ButtonRow,
        },
    };

    pub const getGObjectType = gobject.ext.defineClass(Self, .{
        .flags = .{ .final = true },
        .instanceInit = &init,
        .classInit = &Class.init,
        .parent_class = &Class.meta.parent_class,
    });

    pub fn init(self: *Self, _: *Class) callconv(.c) void {
        var self_widget = self.as(gtk.Widget);
        self_widget.initTemplate();

        if (builtin.mode == .Debug) {
            self_widget.addCssClass("devel");
        }
    }

    pub fn new(app: *Application) *Self {
        return gobject.ext.newInstance(Self, .{
            .application = app,
        });
    }

    pub fn dispose(self: *Self) callconv(.c) void {
        self.as(gtk.Widget).disposeTemplate(getGObjectType());
        self.virtualCall(gobject.Object, "dispose", .{});
    }

    const Commmon = util.Common(Self);
    pub const as = Commmon.as;
    pub const virtualCall = Commmon.virtualCall;

    pub const Class = extern struct {
        parent_class: Parent.Class,

        fn init(class: *Class) callconv(.c) void {
            class.initMeta();
            class.override(gobject.Object, "dispose");
            class.bindTemplate("window.ui");
        }

        pub const Instance = C.Class.Instance;
        pub const meta = C.Class.meta;
        pub const as = C.Class.as;
        pub const bindTemplate = C.Class.bindTemplate;
        pub const initMeta = C.Class.initMeta;
        pub const override = C.Class.override;
    };
};
