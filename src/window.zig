const std = @import("std");
const builtin = @import("builtin");
const adw = @import("adw");
const gobject = @import("gobject");
const gtk = @import("gtk");
const config = @import("config");
const common = @import("common.zig");

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

    const Common = common.Common(Self);
    pub const as = Common.as;
    pub const virtualCall = Common.virtualCall;

    pub const Class = extern struct {
        parent_class: Parent.Class,

        fn init(class: *Class) callconv(.c) void {
            class.initMeta();
            class.override(gobject.Object, "dispose");
            class.bindTemplate("window.ui");
        }

        pub const Instance = Common.Class.Instance;
        pub const meta = Common.Class.meta;
        pub const as = Common.Class.as;
        pub const bindTemplate = Common.Class.bindTemplate;
        pub const initMeta = Common.Class.initMeta;
        pub const override = Common.Class.override;
    };
};
