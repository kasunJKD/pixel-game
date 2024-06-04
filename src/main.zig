const std = @import("std");
const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Vec2 = rl.Vector2;

const screenWidth = 1280;
const screenHeight = 720;
const gameWidth = 640;
const gameHeight = 320;

var playerPos = Vec2{ .x = 320.0, .y = 180.0 };

// Main states
const State = enum {
    EDITOR,
    GAME,
};

// Game states
const GameState = enum {
    PAUSE,
    PLAY,
    DEATH,
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

const PlayerMoveSpeed = 10.0;

pub fn updateCamera(camera: *Camera2D, playerpos: Vec2, mainState: State) void {
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
            camera.target = playerpos; // Focus on the player during game mode
            camera.zoom = 1; // Set zoom to 1 in game mode for 640x360 view
        },
    }
}

// Debug function to draw chunks
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

pub fn playerMovement(playerpos: *Vec2, state: State) void {
    if (state == State.GAME) {
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            playerpos.y -= PlayerMoveSpeed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            playerpos.y += PlayerMoveSpeed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
            playerpos.x -= PlayerMoveSpeed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
            playerpos.x += PlayerMoveSpeed;
        }
    }
}

pub fn main() anyerror!void {
    rl.setConfigFlags(rl.ConfigFlags.flag_window_resizable);
    // Initialization
    //--------------------------------------------------------------------------------------
    var currentGlobalState = State.GAME;

    var camera = initCamera();

    rl.initWindow(screenWidth, screenHeight, "pixel template");
    rl.setWindowMinSize(320, 180);
    defer rl.closeWindow();

    const target = rl.loadRenderTexture(gameWidth, gameHeight);
    //rl.setTextureFilter(target.texture, rl.TextureFilter.TEXTURE_FILTER_POINT);

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        updateCamera(&camera, playerPos, currentGlobalState);

        // Toggle between windowed and full-screen mode
        if (rl.isKeyPressed(rl.KeyboardKey.key_f)) {
            rl.toggleFullscreen();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
            currentGlobalState = if (currentGlobalState == State.EDITOR) State.GAME else State.EDITOR;
        }

        {
            rl.beginTextureMode(target);
            defer rl.endTextureMode();

            rl.clearBackground(rl.Color.white);

            // 2D mode drawing with camera
            rl.beginMode2D(camera);
            defer rl.endMode2D();
            rl.drawRectangleV(Vec2{ .x = playerPos.x - 16, .y = playerPos.y - 16 }, Vec2{ .x = 32, .y = 32 }, rl.Color.blue); // Example player

            playerMovement(&playerPos, currentGlobalState);

            // Debug line
            drawChunks();
        }

        // Begin drawing to the window
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        rl.drawTexturePro(target.texture, rl.Rectangle{ .x = 0, .y = 0, .width = gameWidth, .height = -gameHeight }, rl.Rectangle{ .x = 0, .y = 0, .width = screenWidth, .height = screenHeight }, Vec2{ .x = 0, .y = 0 }, 0.0, rl.Color.white);

        rl.drawText(if (currentGlobalState == State.EDITOR) "Editor Mode" else "Game Mode", 10, 10, 20, rl.Color.black);
        rl.drawText("Press SPACE to toggle mode", 10, 40, 20, rl.Color.dark_gray);
    }
}
