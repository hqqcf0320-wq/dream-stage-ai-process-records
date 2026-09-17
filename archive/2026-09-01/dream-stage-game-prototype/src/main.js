import * as THREE from 'three';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import './style.css';

// THROWAWAY PROTOTYPE — question: can a game-like journey communicate performer agency
// and an audience-specific dream world before camera, microphone, or VR are connected?

const params = new URLSearchParams(location.search);
const seedText = params.get('seed') || Math.random().toString(36).slice(2, 8);
const seed = [...seedText].reduce((n, c) => (n * 31 + c.charCodeAt(0)) >>> 0, 2166136261);
const variant = (params.get('variant') || 'A').toUpperCase();
const rng = mulberry32(seed);

document.querySelector('#app').innerHTML = `
  <div id="mount"></div>
  <div class="layer hud">
    <div class="brand"><p class="eyebrow">THROWAWAY PLAYABLE PROTOTYPE · ${variant}</p><h1>The Room<br>That Remembers</h1><p class="objective" id="objective">找到三段记忆。接近发光物体并按 E。你的顺序和选择会改变这个世界。</p></div>
    <div class="memory-meter">${[0,1,2].map(i=>`<i class="memory-dot" data-dot="${i}"></i>`).join('')}</div>
  </div>
  <div class="crosshair"></div><div class="prompt" id="prompt"></div>
  <div class="lens" id="lens">VIEW · ${lensName(variant)} · SEED ${seedText.toUpperCase()}</div>
  <pre class="state" id="state"></pre>
  <div class="move-pad" aria-label="移动控制">
    <button data-move="KeyW" aria-label="前进">▲</button>
    <button data-move="KeyA" aria-label="向左">◀</button>
    <button data-move="KeyS" aria-label="后退">▼</button>
    <button data-move="KeyD" aria-label="向右">▶</button>
  </div>
  <div class="help">WASD 移动 · 鼠标环顾 · E 触碰记忆<br>F 冻结梦境 · R 拒绝当前变化 · 1/2/3 切换观看方式</div>
  <div class="start" id="start"><div class="panel"><p class="eyebrow">AN INTERACTIVE MEMORY</p><h2>房间记得你</h2><p>你不是在观看一段AI视频。你将进入一段记忆，并决定它如何出现、停留与消失。</p><p>每个链接的 <code>seed</code> 都会生成稍微不同的空间；这模拟未来每位观众独一无二的观看版本。</p><button id="enter">进入梦境</button></div></div>
  <div class="ending hidden" id="ending"><div class="panel"><p class="eyebrow">THE WORLD YOU CO-AUTHORED</p><h2 id="endingTitle"></h2><p id="endingCopy"></p><div class="choice"><button id="remember">让它留下</button><button id="release">让它离开</button></div></div></div>`;

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x07100c);
scene.fog = new THREE.FogExp2(0x9ab49b, 0.028 + rng() * .015);
const camera = new THREE.PerspectiveCamera(66, innerWidth/innerHeight, .1, 200);
camera.position.set(0, 1.72, 9);
const renderer = new THREE.WebGLRenderer({ antialias:true, powerPreference:'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2)); renderer.setSize(innerWidth,innerHeight);
renderer.domElement.tabIndex=0;
renderer.toneMapping = THREE.ACESFilmicToneMapping; renderer.toneMappingExposure = 1.05;
renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;
document.querySelector('#mount').appendChild(renderer.domElement);
const composer = new EffectComposer(renderer); composer.addPass(new RenderPass(scene,camera));
const bloom = new UnrealBloomPass(new THREE.Vector2(innerWidth,innerHeight), .55, .8, .72); composer.addPass(bloom);

const world = new THREE.Group(); scene.add(world);
const impossibleLayer = new THREE.Group(); world.add(impossibleLayer);
const hemi = new THREE.HemisphereLight(0xbddbd1,0x1c261d,1.2); scene.add(hemi);
const sun = new THREE.DirectionalLight(0xffd993,4.2); sun.position.set(-8,12,6); sun.castShadow=true; scene.add(sun);

// Reflective stage floor
const floor = new THREE.Mesh(new THREE.PlaneGeometry(70,70), new THREE.MeshStandardMaterial({color:0x203329,roughness:.4,metalness:.18,transparent:true,opacity:.92}));
floor.rotation.x=-Math.PI/2; floor.receiveShadow=true; world.add(floor);
const grid = new THREE.GridHelper(60,60,0x476d58,0x1e3529); grid.material.opacity=.13; grid.material.transparent=true; world.add(grid);

// The generated image becomes a scenographic portal, not a flat full-screen background.
new THREE.TextureLoader().load('/assets/memory-stage.png', texture => {
  texture.colorSpace = THREE.SRGBColorSpace;
  const portal = new THREE.Mesh(new THREE.PlaneGeometry(12.8,7.2), new THREE.MeshBasicMaterial({map:texture,transparent:true,opacity:.82}));
  portal.position.set(0,4,-10); world.add(portal);
  const veil = portal.clone(); veil.scale.set(1.08,1.08,1); veil.material = portal.material.clone(); veil.material.opacity=.12; veil.position.z=-9.7; world.add(veil);
});

const portalState = { city: 0, window: 0 };
const portalPlanes = {};
loadDreamPortal('city','/assets/vertical-memory-city.png',new THREE.Vector3(-12,5,-17),10,5.625,-.3);
loadDreamPortal('window','/assets/impossible-window.png',new THREE.Vector3(12,4,-14),9,5.06,.35);
function loadDreamPortal(key,url,pos,w,h,rot){new THREE.TextureLoader().load(url,texture=>{texture.colorSpace=THREE.SRGBColorSpace;const mat=new THREE.MeshBasicMaterial({map:texture,transparent:true,opacity:0,depthWrite:false});const mesh=new THREE.Mesh(new THREE.PlaneGeometry(w,h),mat);mesh.position.copy(pos);mesh.rotation.y=rot;impossibleLayer.add(mesh);portalPlanes[key]=mesh})}

// Minimal green furniture as spatial memory anchors.
const furniture=[];
for(let i=0;i<7;i++) addTableChair((rng()-.5)*15, -2-rng()*11, rng()*Math.PI*2, .75+rng()*.35);
function addTableChair(x,z,rot,s){
  const g=new THREE.Group(), green=new THREE.MeshStandardMaterial({color:0x234d3b,roughness:.75});
  const top=new THREE.Mesh(new THREE.BoxGeometry(2.2*s,.12,1.15*s),green); top.position.y=1.08*s; top.castShadow=true; g.add(top);
  [[-.9,-.42],[.9,-.42],[-.9,.42],[.9,.42]].forEach(([a,b])=>{const l=new THREE.Mesh(new THREE.BoxGeometry(.1,.98*s,.1),green);l.position.set(a*s,.55*s,b*s);l.castShadow=true;g.add(l)});
  const chair=new THREE.Group(); const seat=new THREE.Mesh(new THREE.BoxGeometry(.68*s,.1,.68*s),green);seat.position.y=.55*s;chair.add(seat); const back=new THREE.Mesh(new THREE.BoxGeometry(.68*s,.9,.08),green);back.position.set(0,1*s,.3*s);chair.add(back);chair.position.set(0,0,1.1*s);g.add(chair);
  g.position.set(x,0,z);g.rotation.y=rot;world.add(g);furniture.push(g);
}

const verticalTables=new THREE.Group(); verticalTables.visible=false; impossibleLayer.add(verticalTables);
for(let i=0;i<34;i++){const t=new THREE.Mesh(new THREE.BoxGeometry(1.2+rng()*1.4,.08,.7+rng()*.7),new THREE.MeshStandardMaterial({color:0x214838,emissive:0x102d22,emissiveIntensity:.6,roughness:.7}));t.position.set((rng()-.5)*22,2+rng()*19,-7-rng()*24);t.rotation.set(rng()*Math.PI,rng()*Math.PI,rng()*Math.PI);verticalTables.add(t)}

// Floating architecture fragments and dust.
const frameMat = new THREE.MeshStandardMaterial({color:0x697f68,roughness:.72});
for(let i=0;i<11;i++){const f=new THREE.Mesh(new THREE.TorusGeometry(.7+rng(),.05,8,4),frameMat);f.position.set((rng()-.5)*22,2+rng()*9,-4-rng()*17);f.rotation.set(rng()*2,rng()*2,rng()*2);world.add(f)}
const dustGeo=new THREE.BufferGeometry(), dust=[]; for(let i=0;i<700;i++) dust.push((rng()-.5)*42,rng()*14,(rng()-.5)*42); dustGeo.setAttribute('position',new THREE.Float32BufferAttribute(dust,3));
const dustMat=new THREE.PointsMaterial({color:0xffe5a4,size:.035,transparent:true,opacity:.55}); const dustField=new THREE.Points(dustGeo,dustMat);world.add(dustField);

// The world steals the player's route and turns it into a visible authored trace.
const pathPositions=[]; let pathGeo=new THREE.BufferGeometry(); const pathLine=new THREE.Line(pathGeo,new THREE.LineBasicMaterial({color:0xe6c979,transparent:true,opacity:.5,blending:THREE.AdditiveBlending}));pathLine.frustumCulled=false;world.add(pathLine);let pathTimer=0;
function updatePathGeometry(){pathLine.geometry.dispose();pathGeo=new THREE.BufferGeometry().setFromPoints(pathPositions);pathLine.geometry=pathGeo}

const memories = [
  makeMemory('绿桌椅',new THREE.Vector3(-5,1.15,-5),0x7fd2a7,'桌子比人更忠于原来的位置。'),
  makeMemory('午后窗口',new THREE.Vector3(5,2.3,-8),0xffd884,'光从一个已经不存在的下午照进来。'),
  makeMemory('远处的人',new THREE.Vector3(0,1.8,-15),0xd8eee5,'他没有转身，但你知道他正在等你。')
];
function makeMemory(name,pos,color,line){const m=new THREE.Mesh(new THREE.IcosahedronGeometry(.34,2),new THREE.MeshStandardMaterial({color,emissive:color,emissiveIntensity:3,transparent:true,opacity:.85}));m.position.copy(pos);m.userData={name,line,found:false};world.add(m);const light=new THREE.PointLight(color,4,5);m.add(light);return m}

const keys={}, velocity=new THREE.Vector3(), euler=new THREE.Euler(0,0,0,'YXZ'); let locked=false, started=false, frozen=false, rejected=0, found=[], nearby=null, ending=false;
const adapter = {
  // Later replace with MediaPipeAdapter, WebAudioAdapter, or XRControllerAdapter.
  sample(){return {moveX:(keys.KeyD?1:0)-(keys.KeyA?1:0),moveZ:(keys.KeyS?1:0)-(keys.KeyW?1:0),intensity:Math.min(1,velocity.length()/5),voice:0,freeze:frozen}}
};

document.querySelector('#enter').onclick=()=>{started=true;locked=true;document.querySelector('#start').classList.add('hidden');renderer.domElement.focus();renderer.domElement.requestPointerLock?.().catch?.(()=>{})};
document.addEventListener('pointerlockchange',()=>{locked=started||document.pointerLockElement===renderer.domElement;document.querySelector('#start').classList.toggle('hidden',started||found.length>0)});
document.addEventListener('mousemove',e=>{if(!locked||frozen||ending)return;euler.y-=e.movementX*.0018;euler.x-=e.movementY*.0015;euler.x=Math.max(-1.3,Math.min(1.3,euler.x));camera.quaternion.setFromEuler(euler)});
const keyAlias={ArrowUp:'KeyW',ArrowDown:'KeyS',ArrowLeft:'KeyA',ArrowRight:'KeyD'};
addEventListener('keydown',e=>{const code=keyAlias[e.code]||e.code;keys[code]=true;if(code==='KeyE')interact();if(code==='KeyF')frozen=!frozen;if(code==='KeyR')reject();if(['Digit1','Digit2','Digit3'].includes(code))setView(code.at(-1))});addEventListener('keyup',e=>keys[keyAlias[e.code]||e.code]=false);addEventListener('blur',()=>Object.keys(keys).forEach(k=>keys[k]=false));
document.querySelectorAll('[data-move]').forEach(button=>{const code=button.dataset.move;button.addEventListener('pointerdown',e=>{e.preventDefault();keys[code]=true;renderer.domElement.focus()});['pointerup','pointercancel','pointerleave'].forEach(type=>button.addEventListener(type,()=>keys[code]=false));button.addEventListener('click',()=>nudge(code))});
function nudge(code){const x=code==='KeyD'?1:code==='KeyA'?-1:0,z=code==='KeyS'?1:code==='KeyW'?-1:0;const dir=new THREE.Vector3(x,0,z).applyAxisAngle(new THREE.Vector3(0,1),euler.y);camera.position.addScaledVector(dir,.55)}

function interact(){if(!nearby||nearby.userData.found||ending)return;nearby.userData.found=true;found.push(nearby);nearby.material.opacity=.15;document.querySelector(`[data-dot="${found.length-1}"]`).classList.add('found');applyMemory(nearby,found.length-1);if(found.length===3)setTimeout(showEnding,900)}
function applyMemory(m,i){document.querySelector('#objective').textContent=m.userData.line;if(m.userData.name==='绿桌椅'){verticalTables.visible=true;portalState.city=variant==='C' ? .38 : .72;bloom.strength=.85;furniture.forEach((g,n)=>{g.userData.floatPhase=n*.7})}if(m.userData.name==='午后窗口'){portalState.window=variant==='B' ? .32 : .78;sun.position.x=8;renderer.toneMappingExposure=1.34;scene.fog.color.set(0x6f8f7b)}if(m.userData.name==='远处的人'){scene.fog.density*=.5;dustMat.opacity=.9;pathLine.material.opacity=1;pathPositions.forEach((p,n)=>p.y+=Math.sin(n*.5)*.4+n*.018);updatePathGeometry()}stateText()}
function reject(){if(!found.length)return;rejected++;const last=found.pop();last.userData.found=false;last.material.opacity=.85;document.querySelector(`[data-dot="${found.length}"]`).classList.remove('found');scene.fog.density=Math.min(.07,scene.fog.density*1.18);if(last.userData.name==='绿桌椅'){portalState.city=0;verticalTables.visible=false}if(last.userData.name==='午后窗口')portalState.window=0;document.querySelector('#objective').textContent='你拒绝了这个版本。空间把拒绝也记住：下一次它会故意少给你一样东西。';stateText()}
function setView(n){const url=new URL(location.href);url.searchParams.set('variant',['A','B','C'][Number(n)-1]);location.href=url}
function showEnding(){ending=true;document.exitPointerLock();const order=found.map(m=>m.userData.name).join(' → ');document.querySelector('#endingTitle').textContent=found[0].userData.name==='远处的人'?'你先看见了他':'你先让房间出现';document.querySelector('#endingCopy').textContent=`你的记忆路径是：${order}。同一个空间，因为进入顺序不同，已经成为只属于你的版本。`;document.querySelector('#ending').classList.remove('hidden')}
document.querySelector('#remember').onclick=()=>{document.querySelector('#endingCopy').textContent='你选择保存这段记忆。未来版本会把它写入个人观众种子，而不是覆盖其他人的世界。'};
document.querySelector('#release').onclick=()=>location.href=`?variant=${variant}&seed=${Math.random().toString(36).slice(2,8)}`;

function updateNearby(){nearby=null;let d=2.2;for(const m of memories){if(m.userData.found)continue;const q=m.position.distanceTo(camera.position);if(q<d){d=q;nearby=m}}const p=document.querySelector('#prompt');p.textContent=nearby?`E · 触碰「${nearby.userData.name}」`:'';p.classList.toggle('show',!!nearby)}
function stateText(){document.querySelector('#state').textContent=JSON.stringify({seed:seedText,view:lensName(variant),position:camera.position.toArray().map(n=>Number(n.toFixed(2))),found:found.map(m=>m.userData.name),rejected,frozen,input:'KeyboardAdapter',future:['MediaPipe','WebAudio','WebXR']},null,2)}

const clock=new THREE.Clock();
function animate(){requestAnimationFrame(animate);const dt=Math.min(clock.getDelta(),.04),input=adapter.sample();if(locked&&!frozen&&!ending){const dir=new THREE.Vector3(input.moveX,0,input.moveZ).normalize();dir.applyAxisAngle(new THREE.Vector3(0,1),euler.y);velocity.lerp(dir.multiplyScalar(4.2),.14);camera.position.addScaledVector(velocity,dt);camera.position.x=THREE.MathUtils.clamp(camera.position.x,-18,18);camera.position.z=THREE.MathUtils.clamp(camera.position.z,-19,18)}else velocity.multiplyScalar(.85);
  if(locked&&!frozen){pathTimer+=dt;if(pathTimer>.22){pathTimer=0;pathPositions.push(new THREE.Vector3(camera.position.x,.035,camera.position.z));if(pathPositions.length>220)pathPositions.shift();updatePathGeometry()}}
  memories.forEach((m,i)=>{if(!frozen){m.rotation.y+=dt*(.5+i*.2);m.position.y+=Math.sin(clock.elapsedTime*1.4+i)*.0015}});furniture.forEach(g=>{if(g.userData.floatPhase!==undefined&&!frozen){g.position.y=1.2+Math.sin(clock.elapsedTime*.7+g.userData.floatPhase)*1.4;g.rotation.z+=dt*.08}});verticalTables.rotation.y+=frozen?0:dt*.025;
  if(portalPlanes.city)portalPlanes.city.material.opacity=THREE.MathUtils.lerp(portalPlanes.city.material.opacity,portalState.city,.025);if(portalPlanes.window)portalPlanes.window.material.opacity=THREE.MathUtils.lerp(portalPlanes.window.material.opacity,portalState.window,.025);
  dustField.rotation.y+=frozen?0:dt*.007;updateNearby();stateText();composer.render()}
animate();

addEventListener('resize',()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight);composer.setSize(innerWidth,innerHeight)});
function lensName(v){return v==='B'?'DIRECTOR / OVERHEAD':v==='C'?'WITNESS / DRIFT':'PERFORMER / FIRST PERSON'}
if(variant==='B'){camera.position.set(0,15,7);euler.set(-1.05,0,0);camera.quaternion.setFromEuler(euler)}
if(variant==='C'){camera.position.set(-11,4,7);euler.set(-.15,-.75,0);camera.quaternion.setFromEuler(euler)}
stateText();
function mulberry32(a){return function(){let t=a+=0x6D2B79F5;t=Math.imul(t^t>>>15,t|1);t^=t+Math.imul(t^t>>>7,t|61);return((t^t>>>14)>>>0)/4294967296}}
