# Dream Stage — throwaway prototype

Question: **哪种视觉结构最适合把演员的动作、声音和记忆变成梦境舞台，同时保留演员控制权？**

This is disposable code for comparing three directions:

- `?variant=A` — Memory Flood：完整的电影感梦境投影。
- `?variant=B` — Fractured Rooms：可重排的记忆空间碎片。
- `?variant=C` — Living Field：由动作与声音实时生成的抽象光场。

Run from the workspace root:

```powershell
python -m http.server 4173 --directory outputs/dream-stage-prototype
```

Then open `http://localhost:4173/?variant=A`. Use the bottom arrows or keyboard left/right arrows. Move the pointer to simulate performer position; adjust movement, voice, and intensity. `Freeze`, `Reject`, and `Replay` expose performer agency rather than hiding it inside the AI system.

No model API is connected yet. The prototype answers a visual/interaction question before choosing a paid generation stack.
