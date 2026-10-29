from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root=Path(__file__).resolve().parents[1]/'release-preparation/1.7/screenshots'
out=root/'de-DE/us-style'; out.mkdir(parents=True,exist_ok=True)
template=Image.open(root/'design-assets/de-phone-template.png').convert('RGB').resize((1206,2622),Image.Resampling.LANCZOS).convert('RGBA')
items=[('01.png','Regiere','Deutschland','Dein Land. Deine Entscheidungen.'),('02.png','Schmiede','deine Koalition','Verhandle und finde eine Mehrheit.'),('03.png','Triff die','wichtigen Entscheidungen','Krisen, Reformen und dein Kurs.'),('04.png','Jede Entscheidung','zählt','Erlebe die Folgen deiner Politik.')]
for i,(name,a,b,sub) in enumerate(items,1):
 im=template.copy(); d=ImageDraw.Draw(im)
 x=506
 for color in ['#1A1A1E','#D93733','#F2C749']:
  d.rectangle((x,122,x+64,133),fill=color); x+=64
 fontpath='/System/Library/Fonts/Supplemental/Arial Bold.ttf'; size=86
 while max(d.textbbox((0,0),s,font=ImageFont.truetype(fontpath,size))[2] for s in (a,b))>1100: size-=2
 font=ImageFont.truetype(fontpath,size)
 d.text((603,173),a,font=font,fill='white',anchor='mt',stroke_width=2,stroke_fill='#102039')
 d.text((603,173+size+8),b,font=font,fill='white',anchor='mt',stroke_width=2,stroke_fill='#102039')
 subfont=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',35)
 d.text((603,383),sub,font=subfont,fill='#E1E5EA',anchor='mt',stroke_width=1,stroke_fill='#102039')
 screen=Image.open(root/'de-DE/raw'/name).convert('RGBA'); w=780; h=round(screen.height*w/screen.width); screen=screen.resize((w,h),Image.Resampling.LANCZOS)
 mask=Image.new('L',(w,h),0); ImageDraw.Draw(mask).rounded_rectangle((0,0,w-1,h-1),radius=83,fill=255)
 im.paste(screen,((1206-w)//2,638),mask)
 im.convert('RGB').save(out/f'{i:02}-deutsch.png',optimize=True)
 print(out/f'{i:02}-deutsch.png')
