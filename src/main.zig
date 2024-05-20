const std = @import("std");

const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Vec2 = rl.Vector2;

//main states
const State = enum {
    EDITOR,
    GAME,
};

//game states
const GameState = enum {
    PAUSE,
    PLAY,
};

const Camera2D = rl.Camera2D;

fn initCamera() Camera2D {
    return Camera2D{
        .offset = Vec2{
            .x = 320,
            .y = 180,
        }, // Center of the screen
        .target = Vec2{
            .x = 320,
            .y = 180,
        }, // Initial target position
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
    //const currentGameState = GameState.PLAY;

    const screenWidth = 640;
    const screenHeight = 360;

    var camera = initCamera();

    const playerPos = Vec2{ .x = 320, .y = 180 };

    rl.initWindow(screenWidth, screenHeight, "pixel template");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    //const player = rl.loadTexture("assets/game_player.png");
    //defer player.unload();

    // const position = Vec2.init(
    //     @as(f32, @floatFromInt(@divTrunc((screenWidth - player.width), 2))),
    //     @as(f32, @floatFromInt(@divTrunc((screenHeight - player.height), 2))),
    // );

    while (!rl.windowShouldClose()) {
        updateCamera(&camera, playerPos, currentGlobalState);

        // Toggle between windowed and full-screen mode
        if (rl.isKeyPressed(.key_f)) {
            if (rl.isWindowFullscreen()) {
                rl.toggleFullscreen();
                rl.setWindowSize(640, 360);
            } else {
                rl.toggleFullscreen();
                // Update camera offset for fullscreen
                const screenWidthr = rl.getScreenWidth();
                const screenHeightr = rl.getScreenHeight();
                camera.offset = Vec2{
                    .x = @as(f32, @floatFromInt(@divTrunc((screenWidthr), 2))),
                    .y = @as(f32, @floatFromInt(@divTrunc((screenHeightr), 2))),
                };
            }
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
            currentGlobalState = if (currentGlobalState == State.EDITOR) State.GAME else State.EDITOR;
        }

        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        defer rl.endDrawing();

        //rl.drawTextureV(player, position, rl.Color.white);

        rl.beginMode2D(camera);
        // Draw map and player or editor elements
        rl.drawRectangle(0, 0, 1920, 1080, rl.Color.light_gray); // Example map
        rl.drawRectangle(playerPos.x - 16, playerPos.y - 16, 32, 32, rl.Color.blue); // Example player

        // Draw the grid chunks
        drawChunks();

        rl.endMode2D();

        rl.drawText(if (currentGlobalState == State.EDITOR) "Editor Mode" else "Game Mode", 10, 10, 20, rl.Color.black);
        rl.drawText("Press SPACE to toggle mode", 10, 40, 20, rl.Color.dark_gray);
    }
}
