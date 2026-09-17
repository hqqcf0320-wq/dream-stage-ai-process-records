const variants = {
  A: { name: 'Memory Flood', description: '一整块梦境图像像记忆一样呼吸；演员的位置成为光源。' },
  B: { name: 'Fractured Rooms', description: '梦不是背景，而是彼此断裂、可被身体重新排列的空间碎片。' },
  C: { name: 'Living Field', description: '不用固定图像，让声音与移动直接生成一个实时、有机的光场。' }
};

const state = { movement: 42, voice: 35, intensity: 58, frozen: false, rejected: 0, history: [] };
const app = document.querySelector('#app');
const root = document.documentElement;
let animationId;

function currentVariant() {
  const key = new URLSearchParams(location.search).get('variant')?.toUpperCase();
  return variants[key] ? key : 'A';
}

function shell(key, content) {
  return `<section class="stage variant-${key.toLowerCase()}">
    ${content}
    <header class="title"><p class="eyebrow">THROWAWAY DREAM STAGE / ${key}</p><h1>${variants[key].name}</h1><p>${variants[key].description}</p></header>
  </section>`;
}

function render() {
  cancelAnimationFrame(animationId);
  const key = currentVariant();
  if (key === 'A') app.innerHTML = shell(key, '<div class="backdrop"></div><div class="memory-light"></div><div class="veil"></div><div class="ghost"></div>');
  if (key === 'B') app.innerHTML = shell(key, '<div class="chamber"><div class="fragment f1"></div><div class="fragment f2"></div><div class="fragment f3"></div><div class="portal"></div></div>');
  if (key === 'C') {
    app.innerHTML = shell(key, '<canvas id="field"></canvas><div class="horizon"></div>');
    startField();
  }
  document.querySelector('#variantLabel').textContent = `${key} — ${variants[key].name}`;
  sync();
}

function sync(record = false) {
  root.style.setProperty('--movement', state.movement / 100);
  root.style.setProperty('--voice', state.voice / 100);
  root.style.setProperty('--intensity', state.intensity / 100);
  app.classList.toggle('frozen', state.frozen);
  document.querySelector('#freeze').classList.toggle('active', state.frozen);
  document.querySelector('#state').textContent = JSON.stringify(state, null, 0);
  if (record) state.history.push({ movement: state.movement, voice: state.voice, intensity: state.intensity });
}

function go(offset) {
  const keys = Object.keys(variants), i = keys.indexOf(currentVariant());
  const next = keys[(i + offset + keys.length) % keys.length];
  const url = new URL(location.href); url.searchParams.set('variant', next); history.replaceState({}, '', url); render();
}

['movement', 'voice', 'intensity'].forEach(id => {
  document.querySelector(`#${id}`).addEventListener('input', e => { state[id] = Number(e.target.value); sync(true); });
});
document.querySelector('#freeze').addEventListener('click', () => { state.frozen = !state.frozen; sync(); });
document.querySelector('#reject').addEventListener('click', () => { state.rejected++; app.classList.remove('rejected'); void app.offsetWidth; app.classList.add('rejected'); state.intensity = Math.max(8, 100 - state.intensity); document.querySelector('#intensity').value = state.intensity; sync(true); });
document.querySelector('#replay').addEventListener('click', () => { const past = state.history.at(-8) || { movement: 42, voice: 35, intensity: 58 }; Object.assign(state, past); for (const k of ['movement','voice','intensity']) document.querySelector(`#${k}`).value = state[k]; sync(); });
document.querySelector('#previous').addEventListener('click', () => go(-1));
document.querySelector('#next').addEventListener('click', () => go(1));
window.addEventListener('keydown', e => { if (['INPUT','TEXTAREA'].includes(document.activeElement.tagName) || document.activeElement.isContentEditable) return; if (e.key === 'ArrowLeft') go(-1); if (e.key === 'ArrowRight') go(1); });
window.addEventListener('pointermove', e => { root.style.setProperty('--mx', `${e.clientX / innerWidth * 100}%`); root.style.setProperty('--my', `${e.clientY / innerHeight * 100}%`); });
window.addEventListener('popstate', render);

function startField() {
  const canvas = document.querySelector('#field'), ctx = canvas.getContext('2d');
  const particles = Array.from({ length: 180 }, (_, i) => ({ seed: i * 13.71, x: Math.random(), y: Math.random(), r: Math.random() * 2 + .3 }));
  function frame(t) {
    canvas.width = innerWidth * devicePixelRatio; canvas.height = innerHeight * devicePixelRatio; ctx.scale(devicePixelRatio, devicePixelRatio);
    ctx.fillStyle = 'rgba(2,6,5,.18)'; ctx.fillRect(0,0,innerWidth,innerHeight);
    const speed = .00004 + state.movement * .000003;
    for (const p of particles) {
      const angle = p.seed + t * speed; const wave = Math.sin(angle * 2.1 + p.seed) * (18 + state.voice * .9);
      const x = p.x * innerWidth + Math.cos(angle) * 90; const y = p.y * innerHeight + wave;
      const hue = 130 + state.intensity * .8 + Math.sin(angle) * 35;
      ctx.beginPath(); ctx.arc(x, y, p.r + state.voice / 80, 0, Math.PI*2); ctx.fillStyle = `hsla(${hue},55%,72%,${.15 + state.intensity/180})`; ctx.fill();
      if (state.voice > 52) { ctx.strokeStyle = `hsla(${hue},60%,70%,.06)`; ctx.beginPath(); ctx.moveTo(x,y); ctx.lineTo(innerWidth/2,innerHeight*.62); ctx.stroke(); }
    }
    if (!state.frozen) animationId = requestAnimationFrame(frame);
  }
  animationId = requestAnimationFrame(frame);
}

render();
