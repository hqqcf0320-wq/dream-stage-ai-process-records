# The Room That Remembers — throwaway playable prototype

Design question: **在还没有摄像头、麦克风和 VR 时，游戏式交互能否最大程度传达“演员与观众共同改写梦境空间”？**

## Run

On Windows, the simplest option is to double-click `START_GAME.cmd`. Do not
double-click `index.html`; ES modules and assets require a local server.

```powershell
npm install
npm run dev
```

Open the URL printed by Vite. Recommended:

- `?variant=A&seed=sarah` — performer / first-person view
- `?variant=B&seed=sarah` — director / overhead view
- `?variant=C&seed=sarah` — witness / drifting view

Controls: WASD, mouse, `E` interact, `F` freeze, `R` reject, `1/2/3` perspectives.

Each `seed` creates a slightly different fog, furniture layout and architecture. The order in which the player touches the three memories changes the ending. This is the browser-only stand-in for the future audience-specific experience.

## Why this stack

- Three.js gives a real 3D world, shaders/post-processing and a migration path to WebXR.
- Current input is a small `KeyboardAdapter` boundary. Later it can be replaced by MediaPipe pose, Web Audio features, or WebXR controllers without rewriting the world.
- The AI-generated stage image is used as a scenographic portal inside the world, while the spatial response stays deterministic and playable.

This is deliberately throwaway code. It validates the interaction and artistic hypothesis; it is not a production game architecture.
