#!/usr/bin/env python3
"""Generate Apple's icon catalogue on macOS using the built-in sips tool."""
from pathlib import Path
import json
import subprocess

root = Path(__file__).resolve().parent
catalogue = root / 'Assets.xcassets' / 'AppIcon.appiconset'
catalogue.mkdir(parents=True, exist_ok=True)
images = []
for idiom, sizes in {
    'iphone': [('20', 2), ('20', 3), ('29', 2), ('29', 3), ('40', 2), ('40', 3), ('60', 2), ('60', 3)],
    'ipad': [('20', 1), ('20', 2), ('29', 1), ('29', 2), ('40', 1), ('40', 2), ('76', 1), ('76', 2), ('83.5', 2)],
    'ios-marketing': [('1024', 1)]
}.items():
    for size, scale in sizes:
        pixels = str(round(float(size) * scale))
        filename = f'{idiom}-{size}-{scale}x.png'
        subprocess.run(['sips', '-z', pixels, pixels, str(root / 'AppIcon-1024.png'), '--out', str(catalogue / filename)], check=True, stdout=subprocess.DEVNULL)
        images.append({'idiom': idiom, 'size': f'{size}x{size}', 'scale': f'{scale}x', 'filename': filename})
(catalogue / 'Contents.json').write_text(json.dumps({'images': images, 'info': {'author': 'xcode', 'version': 1}}, indent=2))
