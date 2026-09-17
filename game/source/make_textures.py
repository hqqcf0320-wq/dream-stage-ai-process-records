"""Original, seamless small PBR studies. No third-party images."""
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter
import wave
ROOT=Path(__file__).resolve().parents[1]/'assets';ROOT.mkdir(exist_ok=True)
rng=np.random.default_rng(90417);N=1024
def noise(size):
 a=(rng.random((size,size))*255).astype('uint8')
 return np.array(Image.fromarray(a).resize((N,N),Image.Resampling.BICUBIC))/255.
fine=noise(512);mid=noise(64);broad=noise(8);y,x=np.mgrid[0:N,0:N]/N
def save(name,base,h,rough):
 col=np.clip(base,0,1);Image.fromarray((col*255).astype('uint8')).save(ROOT/(name+'_color.png'))
 dy,dx=np.gradient(h);norm=np.dstack((-dx*12,-dy*12,np.ones_like(h)));norm/=np.linalg.norm(norm,axis=2)[...,None]
 Image.fromarray(((norm*.5+.5)*255).astype('uint8')).save(ROOT/(name+'_normal.png'))
 Image.fromarray((np.clip(rough,0,1)*255).astype('uint8')).save(ROOT/(name+'_rough.png'))
grain=.55*broad+.28*mid+.17*fine
veins=np.clip((noise(32)-.68)*3,0,1)
base=np.array([.17,.36,.32])[None,None,:]*(.8+.4*grain[...,None])+veins[...,None]*.05
save('slate',base,grain*.45+fine*.08,.66+.2*mid)
fiber=(np.sin(x*N*.8)*np.sin(y*N*.8)+1)*.5
save('felt',np.array([.66,.40,.19])[None,None,:]*(.92+.10*mid[...,None]+.03*fine[...,None]),.3*fine+.2*fiber,.90+.08*mid)
save('knit',np.array([.40,.12,.095])[None,None,:]*(.76+.22*mid[...,None]+.18*fiber[...,None]),fiber*.8+fine*.15,.86+.08*mid)
crackle=np.clip((noise(16)-.57)*4,0,1)
paint=np.array([.49,.11,.064])[None,None,:]*(.86+.3*grain[...,None])
paint=paint*(1-crackle[...,None]*.5)+np.array([.25,.15,.075])[None,None,:]*crackle[...,None]*.5
save('paint',paint,.35*grain+.1*crackle,.64+.2*mid)
# Authored temporary score: filtered rain, a gentle sustained harmony, and small tactile sounds.
SR=24000
def wav(name,a):
 a=np.clip(a,-1,1);f=wave.open(str(ROOT/(name+'.wav')),'wb');f.setnchannels(1);f.setsampwidth(2);f.setframerate(SR);f.writeframes((a*32767).astype('<i2').tobytes());f.close()
t=np.arange(SR*12)/SR
pad=sum(np.sin(2*np.pi*f*t+np.sin(t*.3)*.08)/(i+1) for i,f in enumerate([174.614,261.626,349.228,523.251]))
pad*=.08*(.72+.28*np.sin(np.pi*t/12)**2);wav('memory',pad)
a=rng.normal(0,1,SR*8);a=np.convolve(a,np.ones(9)/9,mode='same');a*=.15;wav('rain',a)
t=np.arange(SR//2)/SR;wav('step',(.25*np.sin(2*np.pi*64*t)+rng.normal(0,.12,len(t)))*np.exp(-t*15))
t=np.arange(SR*2)/SR;wav('hum',sum(np.sin(2*np.pi*f*t) for f in [261.626,392.0])*.08*np.sin(np.pi*t/2)**2)
t=np.arange(SR*3)/SR;a=rng.normal(0,1,len(t));a=np.convolve(a,np.ones(120)/120,mode='same');wav('thunder',a*.9*np.sin(np.pi*t/3))
print('Textures and temporary score ready')
