"""Assemble the verified Windows build and editable source without tool caches or credentials."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

root = Path(__file__).resolve().parents[1]
out = root / 'output'
release = out / 'game'
shutil.copyfile(root / 'game/README.md', release / 'README.md')
names = ['BeforeWaking-v0.2.exe', 'README.md', 'FONT-LICENSE.txt', 'Godot-LICENSE.txt', 'Godot-THIRD-PARTY.txt']
manifest = {name: hashlib.sha256((release / name).read_bytes()).hexdigest() for name in names}
(release / 'SHA256.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
with zipfile.ZipFile(out / 'BeforeWaking-v0.2-Windows.zip', 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for name in names + ['SHA256.json']:
        z.write(release / name, 'BeforeWaking-v0.2/' + name)
with zipfile.ZipFile(out / 'BeforeWaking-v0.2-Source.zip', 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for file in (root / 'game').rglob('*'):
        if not file.is_file() or '.godot' in file.parts or '__pycache__' in file.parts:
            continue
        if file.suffix == '.blend1' or file.name == 'NotoSansSC.ttf':
            continue
        z.write(file, file.relative_to(root))
    for name in ['Godot-LICENSE.txt', 'Godot-THIRD-PARTY.txt']:
        z.write(release / name, 'licenses/' + name)
for name in ['BeforeWaking-v0.2-Windows.zip', 'BeforeWaking-v0.2-Source.zip']:
    path = out / name
    with zipfile.ZipFile(path) as z:
        assert z.testzip() is None
        if 'Windows' in name:
            for file, digest in manifest.items():
                assert hashlib.sha256(z.read('BeforeWaking-v0.2/' + file)).hexdigest() == digest
        print(name, 'entries=', len(z.infolist()), 'bytes=', path.stat().st_size, 'CRC and content hashes verified')
print('EXE SHA256:', manifest['BeforeWaking-v0.2.exe'])
