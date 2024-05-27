const std = @import("std");
const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Vec2 = rl.Vector2;

// Main states
const State = enum {
    EDITOR,
    GAME,
};

// Game states
const GameState = enum {
    PAUSE,
    PLAY,
};

const Camera2D = rl.Camera2D;

fn initCamera() Camera2D {
    return Camera2D{
        .offset = Vec2{ .x = 320, .y = 180 }, // Center of the screen
        .target = Vec2{ .x = 320, .y = 180 }, // Initial target position
        .rotation = 0,
        .zoom = 1,
    };
}

fn updateCamera(camera: *Camera2D, playerPos: Vec2, mainState: State) void {
    switch (mainState) {
        State.EDITOR => {
            // Allow zooming in and out
            if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
                camera.zoom += 0.1;
            } else if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
                camera.zoom -= 0.1;
            }

            // Limit the zoom levels
            if (camera.zoom < 0.1) {
                camera.zoom = 0.1;
            } else if (camera.zoom > 2) {
                camera.zoom = 2;
            }

            // Allow panning
            if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
                camera.target.y -= 10;
            } else if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
                camera.target.y += 10;
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
                camera.target.x -= 10;
            } else if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
                camera.target.x += 10;
            }
        },
        State.GAME => {
            camera.target = playerPos; // Focus on the player during game mode
            camera.zoom = 1; // Set zoom to 1 in game mode for 640x360 view
        },
    }
}

fn drawChunks() void {
    const chunkWidth: i32 = 640;
    const chunkHeight: i32 = 360;
    const mapWidth: i32 = 1920;
    const mapHeight: i32 = 1080;

    var x: i32 = 0;
    while (x < mapWidth) {
        var y: i32 = 0;
        while (y < mapHeight) {
            rl.drawRectangleLines(x, y, chunkWidth, chunkHeight, rl.Color.red);
            y += chunkHeight;
        }
        x += chunkWidth;
    }
}

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    var currentGlobalState = State.GAME;
    // const currentGameState = GameState.PLAY;

    const screenWidth = 1280;
    const screenHeight = 720;
    const gameWidth = 640;
    const gameHeight = 360;

    var camera = initCamera();

    const playerPos = Vec2{ .x = 320, .y = 180 };

    rl.initWindow(screenWidth, screenHeight, "pixel template");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    // const player = rl.loadTexture("assets/game_player.png");
    // defer player.unload();

    // const position = Vec2.init(
    //     @as(f32, @floatFromInt(@divTrunc((screenWidth - player.width), 2))),
    //     @as(f32, @floatFromInt(@divTrunc((screenHeight - player.height), 2))),
    // );
    const target = rl.loadRenderTexture(gameWidth, gameHeight);
    defer rl.unloadRenderTexture(target);

    while (!rl.windowShouldClose()) {
        updateCamera(&camera, playerPos, currentGlobalState);

        // Toggle between windowed and full-screen mode
        if (rl.isKeyPressed(.key_f)) {
            rl.toggleFullscreen();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
            currentGlobalState = if (currentGlobalState == State.EDITOR) State.GAME else State.EDITOR;
        }

        // Begin drawing to the render texture
        rl.beginTextureMode(target);
        rl.clearBackground(rl.Color.black);

        // 2D mode drawing with camera
        rl.beginMode2D(camera);
        rl.drawRectangle(0, 0, 1920, 1080, rl.Color.light_gray); // Example map
        rl.drawRectangle(playerPos.x - 16, playerPos.y - 16, 32, 32, rl.Color.blue); // Example player
        drawChunks();
        rl.endMode2D();

        rl.endTextureMode();

        // Begin drawing to the window
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        rl.drawTexturePro(target.texture, rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(target.texture.width), .height = @floatFromInt(-target.texture.height) }, // source
            rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(screenWidth), .height = @floatFromInt(screenHeight) }, // destination
            Vec2{ .x = 0, .y = 0 }, // origin
            0.0, // rotation
            rl.Color.white // tint
        );

        rl.drawText(if (currentGlobalState == State.EDITOR) "Editor Mode" else "Game Mode", 10, 10, 20, rl.Color.black);
        rl.drawText("Press SPACE to toggle mode", 10, 40, 20, rl.Color.dark_gray);
        rl.endDrawing();
    }
}
