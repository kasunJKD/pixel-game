pub const packages = struct {
    pub const @"122043ae5d7dc535006aca53271bf37b64fcbb66851a7982f5914fa6166747884f60" = struct {
        pub const build_root = "C:\\Users\\kasun\\AppData\\Local\\zig\\p\\122043ae5d7dc535006aca53271bf37b64fcbb66851a7982f5914fa6166747884f60";
        pub const build_zig = @import("122043ae5d7dc535006aca53271bf37b64fcbb66851a7982f5914fa6166747884f60");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "raylib", "12208edb6d35c0aa5f57262014b02392c6ccfd0685a8eff1d961b42a612d3418fa89" },
        };
    };
    pub const @"12208edb6d35c0aa5f57262014b02392c6ccfd0685a8eff1d961b42a612d3418fa89" = struct {
        pub const build_root = "C:\\Users\\kasun\\AppData\\Local\\zig\\p\\12208edb6d35c0aa5f57262014b02392c6ccfd0685a8eff1d961b42a612d3418fa89";
        pub const build_zig = @import("12208edb6d35c0aa5f57262014b02392c6ccfd0685a8eff1d961b42a612d3418fa89");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "raylib-zig", "122043ae5d7dc535006aca53271bf37b64fcbb66851a7982f5914fa6166747884f60" },
};
