export const chapters=[
 {id:'dark',title:'一个停住的下午',line:'姥爷。你听得见吗？',hint:'呼喊没有回答。试着踏一下地面。'},
 {id:'gold',title:'地面记住了我们',line:'你帮我一下。',hint:'四位观众的脚步各自留下一道金光。'},
 {id:'rain',title:'我们成为天气',line:'原来，我们可以让这个下午动起来。',hint:'踏步生雨，摇摆起风，歌声带来彩虹。'},
 {id:'chase',title:'近在眼前，无法抵达',line:'……姥爷！这次你先别走。',hint:'靠近使数字房间转动；真人的位置保持不变。'},
 {id:'exchange',title:'把小熊送过去',line:'我的也在这儿。',hint:'把小熊放下，抱起大熊。两边开始共振。'},
 {id:'care',title:'他的手还记得',line:'这一次，我没有继续往前跑。',hint:'早先的动作回来，成为一次照顾。'}
];
export const people=[{id:'A',name:'观众 A',color:'#eac785',x:-3.4,z:4.5},{id:'B',name:'观众 B',color:'#86cac1',x:-1.15,z:5.2},{id:'C',name:'观众 C',color:'#d8999b',x:1.2,z:5.1},{id:'D',name:'观众 D',color:'#a1afe1',x:3.3,z:4.4}];
export const gestures={stomp:'踏步',sway:'摇摆',sing:'哼唱',hug:'抱紧小熊',sleeve:'整理袖口',call:'呼喊'};
export function initial(){return {chapter:0,epoch:0,eventSerial:0,paused:false,events:[],selected:'A',approaches:0,exchanged:false,accepted:null,callbacks:[],mode:'rules',started:false};}
export function input(state,who,kind,note=''){
 if(state.paused||!people.some(p=>p.id===who)||!Object.hasOwn(gestures,kind))return null;
 const e={id:`e${state.epoch}-${++state.eventSerial}`,who,kind,note:String(note).slice(0,160),at:Date.now(),chapter:chapters[state.chapter].id};state.events.push(e); if(state.events.length>200)state.events.shift();
 return e;
}
export function advance(s){if(s.paused||s.chapter>=5)return false;if(s.chapter===4&&!s.exchanged)return false;s.chapter++;s.epoch++;s.accepted=null;return true;}
export function exchange(s){if(s.chapter!==4||s.paused||s.exchanged)return false;s.exchanged=true;return true;}
export function validProposal(s,p){return p&&p.epoch===s.epoch&&p.chapter===chapters[s.chapter].id&&s.events.some(e=>e.id===p.sourceEvent&&e.who===p.who)&&['rock','sleeve','cheek','pat'].includes(p.action);}
export function ruleProposal(s){const reversed=[...s.events].reverse(),unanswered=reversed.filter(e=>!s.callbacks.some(c=>c.who===e.who));const pool=unanswered.length?unanswered:reversed;const e=pool.find(e=>['sway','hug','sleeve','sing'].includes(e.kind))||pool[0];if(!e)return null;const action={sway:'rock',hug:'cheek',sleeve:'sleeve',sing:'pat'}[e.kind]||'pat';return{epoch:s.epoch,chapter:chapters[s.chapter].id,sourceEvent:e.id,who:e.who,action,title:`让 ${e.who} 的${gestures[e.kind]}回来`,actorCue:{rock:'轻轻摇熊，等对方接住这个节奏。',cheek:'把熊的脸贴近手掌，停留一个呼吸。',sleeve:'给熊理顺袖口，留下让人认出的停顿。',pat:'用刚才的节奏轻拍熊，再慢下来。'}[action],visualCue:'原来的金线从参与者脚边返回窗下。',reason:'规则模式：依据最近一次可用动作映射，不是AI生成。',provider:'rules'};}
export function accept(s,p){if(s.paused||!validProposal(s,p))return false;s.accepted=p;s.callbacks.push({...p,at:Date.now()});return true;}
