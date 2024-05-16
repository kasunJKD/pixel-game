const std = @import("std");

const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Vec2 = rl.Vector2;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "pixel template");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    const player = rl.loadTexture("assets/game_player.png");
    defer player.unload();

    const position = Vec2.init(
        @as(f32, @floatFromInt(@divTrunc((screenWidth - player.width), 2))),
        @as(f32, @floatFromInt(@divTrunc((screenHeight - player.height), 2))),
    );
    //--------------------------------------------------------------------------------------
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawTextureV(player, position, rl.Color.white);

        rl.clearBackground(rl.Color.white);
    }
}
