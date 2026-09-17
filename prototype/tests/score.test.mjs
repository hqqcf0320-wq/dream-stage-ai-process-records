import test from 'node:test';import assert from 'node:assert/strict';
import{initial,input,advance,exchange,ruleProposal,validProposal,accept}from '../src/score.js';
test('每位观众独立归因，重复动作不覆盖来源',()=>{const s=initial();for(const who of ['A','B','C','D'])input(s,who,'sway');assert.deepEqual(s.events.map(e=>e.who),['A','B','C','D']);assert.equal(new Set(s.events.map(e=>e.id)).size,4);});
test('旧段落AI不能插入新段落；错误来源不能通过',()=>{const s=initial();input(s,'B','sleeve');const p=ruleProposal(s);assert(validProposal(s,p));assert(!validProposal(s,{...p,who:'A'}));advance(s);assert(!accept(s,p));});
test('暂停拦截输入与接受，交换只在交换节点且只能一次',()=>{const s=initial();input(s,'A','hug');const p=ruleProposal(s);s.paused=true;assert.equal(input(s,'B','stomp'),null);assert.equal(accept(s,p),false);assert.equal(advance(s),false);s.paused=false;assert.equal(exchange(s),false);s.chapter=4;assert.equal(advance(s),false);assert.equal(exchange(s),true);assert.equal(exchange(s),false);assert(advance(s));assert.equal(s.chapter,5);});
test('长场次仍保留唯一事件标识，避免AI引用错人',()=>{const s=initial();const all=[];for(let i=0;i<260;i++)all.push(input(s,'A','sway').id);assert.equal(new Set(all).size,260);assert.equal(s.events.length,200);});
test('热烈和安静路径都可以完成并产生不同动作回调',()=>{for(const kind of ['stomp','sway']){const s=initial();for(let i=0;i<6;i++)input(s,'ABCD'[i%4],kind);while(s.chapter<4)assert(advance(s));assert(exchange(s));assert(advance(s));const p=ruleProposal(s);assert(accept(s,p));assert.equal(p.action,kind==='sway'?'rock':'pat');}});

test('连续共振优先接住尚未回应的观众',()=>{const s=initial();for(const who of ['A','B','C','D'])input(s,who,'sleeve');for(let i=0;i<4;i++)assert(accept(s,ruleProposal(s)));assert.equal(new Set(s.callbacks.map(c=>c.who)).size,4);});
