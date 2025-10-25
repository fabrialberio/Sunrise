const std = @import("std");
const config = @import("config");
const gobject = @import("gobject");
const gtk = @import("gtk");

pub fn Common(comptime Self: type) type {
    return struct {
        pub fn as(self: *Self, comptime T: type) *T {
            return gobject.ext.as(T, self);
        }

        pub const Class = extern struct {
            pub fn as(class: *Self.Class, comptime T: type) *T {
                return gobject.ext.as(T, class);
            }

            pub fn bindTemplate(class: *Self.Class, comptime resource: []const u8) void {
                const widget = Self.Class.as(class, gtk.Widget.Class);
                widget.setTemplateFromResource(config.data_namespace ++ "/" ++ resource);
                inline for (std.meta.fields(Self)) |private_field| {
                    if (comptime std.mem.eql(u8, private_field.name, "private")) {
                        inline for (std.meta.fields(private_field.type)) |children_field| {
                            if (comptime std.mem.eql(u8, children_field.name, "children")) {
                                const offset = @offsetOf(Self, "private") + @offsetOf(private_field.type, "children");
                                inline for (std.meta.fields(children_field.type)) |child| {
                                    const widget_class: *gtk.WidgetClass = @ptrCast(@alignCast(class));
                                    widget_class.bindTemplateChildFull(child.name, @intFromBool(false), offset + @offsetOf(children_field.type, child.name));
                                }
                            }
                        }
                    }
                }
            }

            pub fn registerProperties(class: *Self.Class) void {
                if (!@hasDecl(Self, "properties"))
                    return;

                const properties = comptime getPropertyArray();
                gobject.ext.registerProperties(class, &properties);
            }

            fn getPropertyArray() [std.meta.declarations(Self.properties).len]type {
                const properties = std.meta.declarations(Self.properties);
                var array: [properties.len]type = undefined;

                for (properties, 0..properties.len) |prop, idx| {
                    array[idx] = @field(Self.properties, prop.name).impl;
                }
                return array;
            }
        };
    };
}
