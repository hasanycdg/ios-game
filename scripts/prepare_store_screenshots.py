from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1] / 'release-preparation/1.7/screenshots'
BOLD = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
REGULAR = '/System/Library/Fonts/Supplemental/Arial.ttf'
sets = {
 'de-DE': [('01.png','DU REGIERST','DEUTSCHLAND','Dein Land. Dein Kurs.'),('02.png','BILDE DEINE','REGIERUNG','Suche Mehrheiten und verhandle.'),('03.png','DEINE WAHL.','DEIN KURS.','Jede Krise fordert Entscheidungen.'),('04.png','ENTSCHEIDUNGEN','HABEN FOLGEN','Verändere die Zukunft deines Landes.')],
 'en-US': [('01-taking-office.png','LEAD THE','UNITED STATES','Your country. Your choices.'),('02-congress.png','BUILD YOUR','ADMINISTRATION','Find support in Congress.'),('04-decision.png','MAKE THE','TOUGH CALLS','Choose your response to events.'),('05-result.png','EVERY DECISION','HAS CONSEQUENCES','See how your choices change the nation.'),('03-press.png','THE WORLD','RESPONDS','Follow headlines as history unfolds.')],
}
W,H=1206,2622
for locale, items in sets.items():
    dest=ROOT/locale/'designed'; dest.mkdir(parents=True,exist_ok=True)
    bg=ImageOps.fit(Image.open(ROOT/'design-assets'/('de.png' if locale=='de-DE' else 'en.png')).convert('RGB'),(W,H),method=Image.Resampling.LANCZOS)
    bg=Image.blend(bg,Image.new('RGB',(W,H),(4,10,23)),0.50).convert('RGBA')
    for i,(name,line1,line2,subtitle) in enumerate(items,1):
        canvas=bg.copy(); d=ImageDraw.Draw(canvas)
        kicker='POLITISCHE STRATEGIE' if locale=='de-DE' else 'POLITICAL STRATEGY'
        font=ImageFont.truetype(BOLD,31)
        d.text((W//2,72),kicker,font=font,fill='#DFC18B',anchor='mt',stroke_width=0)
        size=102
        while max(d.textbbox((0,0),line,font=ImageFont.truetype(BOLD,size))[2] for line in (line1,line2))>1090: size-=2
        headline=ImageFont.truetype(BOLD,size)
        d.text((W//2,130),line1,font=headline,fill='#FFFFFF',anchor='mt',stroke_width=1,stroke_fill='#0a0d18')
        d.text((W//2,130+size+10),line2,font=headline,fill='#EFCB8D',anchor='mt',stroke_width=1,stroke_fill='#0a0d18')
        sub=ImageFont.truetype(REGULAR,36)
        d.text((W//2,380),subtitle,font=sub,fill='#E8E8E8',anchor='mt')
        source=ROOT/locale/('raw' if locale=='de-DE' else '')/name
        screen=Image.open(source).convert('RGBA')
        width=942; height=round(screen.height*width/screen.width)
        screen=screen.resize((width,height),Image.Resampling.LANCZOS)
        x=(W-width)//2; y=492
        mask=Image.new('L',(width,height),0); ImageDraw.Draw(mask).rounded_rectangle((0,0,width-1,height-1),radius=40,fill=255)
        shadow=Image.new('RGBA',(W,H)); sd=ImageDraw.Draw(shadow); sd.rounded_rectangle((x-7,y+12,x+width+7,y+height+12),radius=48,fill=(0,0,0,220)); shadow=shadow.filter(ImageFilter.GaussianBlur(22)); canvas=Image.alpha_composite(canvas,shadow)
        d=ImageDraw.Draw(canvas); d.rounded_rectangle((x-5,y-5,x+width+5,y+height+5),radius=46,fill=(221,193,145,180))
        canvas.paste(screen,(x,y),mask)
        canvas.convert('RGB').save(dest/f'{i:02}-{locale}.png',optimize=True)
        print(dest/f'{i:02}-{locale}.png')
