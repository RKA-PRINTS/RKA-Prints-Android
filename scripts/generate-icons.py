#!/usr/bin/env python3
"""Regenerate legacy bitmap icons from the checked-in website SVG.
Optional asset-authoring dependency: pip install cairosvg.
Adaptive / monochrome vectors remain shared and are masked by the launcher.
"""
from pathlib import Path
import xml.etree.ElementTree as ET
import cairosvg
ROOT = Path(__file__).resolve().parents[1]
SVG = ROOT / 'assets/rka-app-icon.svg'
NS = {'svg': 'http://www.w3.org/2000/svg'}
ET.register_namespace('', NS['svg'])
source = SVG.read_text()

def shaped(shape):
    root = ET.fromstring(source)
    ns = '{' + NS['svg'] + '}'
    defs = ET.Element(ns + 'defs')
    clip = ET.SubElement(defs, ns + 'clipPath', {'id': 'launcher-clip'})
    if shape == 'circle':
        ET.SubElement(clip, ns + 'circle', {'cx': '627', 'cy': '627', 'r': '627'})
    else:
        ET.SubElement(clip, ns + 'rect', {'width': '1254', 'height': '1254', 'rx': '235'})
    group = ET.Element(ns + 'g', {'clip-path': 'url(#launcher-clip)'})
    for child in list(root):
        if child.tag.endswith(('rect', 'g')):
            root.remove(child)
            group.append(child)
    root.append(defs)
    root.append(group)
    return ET.tostring(root)

circle = shaped('circle')
rounded = shaped('rounded')
for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
    folder = ROOT / 'res' / ('mipmap-' + density)
    cairosvg.svg2png(bytestring=circle, write_to=str(folder / 'ic_launcher_round.png'), output_width=size, output_height=size)
    for variant, data in [('Google', circle), ('Generic', rounded)]:
        folder = ROOT / 'variants' / variant / 'res' / ('mipmap-' + density)
        folder.mkdir(parents=True, exist_ok=True)
        cairosvg.svg2png(bytestring=data, write_to=str(folder / 'ic_launcher.png'), output_width=size, output_height=size)
for variant in ['Samsung', 'Google', 'Generic']:
    folder = ROOT / 'variants' / variant / 'res' / 'values'
    folder.mkdir(parents=True, exist_ok=True)
    (folder / 'distribution.xml').write_text('<resources><string name="distribution_variant">' + variant + '</string></resources>\n')
