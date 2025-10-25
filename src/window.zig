const std = @import("std");
const builtin = @import("builtin");
const adw = @import("adw");
const gobject = @import("gobject");
const gtk = @import("gtk");
const config = @import("config");
const common = @import("common.zig");

const Application = @import("application.zig").Application;

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
        .parent_class = &Class.parent,
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
            class.bindTemplate("window.ui");
        }

        pub const as = Common.Class.as;
        pub const bindTemplate = Common.Class.bindTemplate;
    };
};
