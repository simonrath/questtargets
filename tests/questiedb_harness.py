"""Load the pinned, real QuestieDB release into Lua. No network or target selection.

Test dependencies: lupa and cbor2. C_EncodingUtil is emulated with Python's CBOR,
base64 and zlib implementations; the database/runtime code itself is unmodified.
"""
import base64
import hashlib
import os
from pathlib import Path
import sys
import tempfile
import zipfile
import zlib
from lupa.lua51 import LuaRuntime

TEST_DEPS = Path(tempfile.gettempdir()) / 'quest-targets-testdeps'
if TEST_DEPS.is_dir():
    sys.path.insert(0, str(TEST_DEPS))
import cbor2

PIN_SHA256 = '0aa71066dad715aac0af03d79f74acdb669a63df8d2368aed222b63dd20f68b8'
DEFAULT_ZIP = Path(tempfile.gettempdir()) / 'quest-targets-questiedb-v1.0.1/QuestieDB-Vanilla.zip'


def load_release(path=DEFAULT_ZIP):
    blob = Path(path).read_bytes()
    assert hashlib.sha256(blob).hexdigest() == PIN_SHA256, 'Unexpected QuestieDB release bytes'
    lua = LuaRuntime(unpack_returned_tuples=True, encoding=None)

    def convert(value):
        if isinstance(value, dict):
            return lua.table_from({convert(k): convert(v) for k, v in value.items()})
        if isinstance(value, (list, tuple)):
            return lua.table_from([convert(v) for v in value])
        return value.encode('utf-8') if isinstance(value, str) else value

    def decompress(blob, method):
        assert method == 1
        try:
            return zlib.decompress(blob)
        except zlib.error:
            return zlib.decompress(blob, -15)

    with zipfile.ZipFile(path) as archive:
        toc = archive.read('QuestieDB/QuestieDB_Vanilla.toc').decode('utf-8')
        metadata = {}
        for line in toc.splitlines():
            if line.startswith('## ') and ': ' in line:
                key, value = line[3:].split(': ', 1)
                metadata[key.encode()] = value.encode()
        lua.globals().metadata_read = lambda name, key: metadata.get(key)
        lua.globals().decode_base64 = base64.b64decode
        lua.globals().decompress = decompress
        lua.globals().decode_cbor = lambda blob: convert(cbor2.loads(blob))
        lua.execute('''
            C_AddOns={GetAddOnMetadata=function(name,key) return metadata_read(name,key) end}
            C_EncodingUtil={DecodeBase64=function(s) return decode_base64(s) end,
                DecompressString=function(s,method) return decompress(s,method) end,
                DeserializeCBOR=function(s) return decode_cbor(s) end}
            function GetLocale() return 'deDE' end
            function UnitClassBase() return 'WARRIOR' end
            function UnitFactionGroup() return 'Alliance' end
            C_Seasons={GetActiveSeason=function() return 0 end}
            Enum={SeasonID={SeasonOfDiscovery=2}}
            provider={}
        ''')
        for line in toc.splitlines():
            line = line.strip()
            if line and not line.startswith('#'):
                source = archive.read('QuestieDB/' + line.replace('\\', '/'))
                lua.execute('assert(loadstring(...))("QuestieDB",provider)', source)
    return lua


if __name__ == '__main__':
    lua = load_release()
    for quest_id in (7, 33, 47, 60):
        title = lua.eval('QuestDB.name')(quest_id)
        print(quest_id, title.decode('utf-8') if title else None)
        objectives = lua.eval('QuestDB.objectives')(quest_id)
        for kind, rows in objectives.items():
            for _, row in rows.items():
                if kind in (1, 3):
                    entity = lua.globals().NpcDB if kind == 1 else lua.globals().ItemDB
                    name = entity[b'name'](row[1])
                    print(' ', kind, row[1], name.decode('utf-8') if name else None)
                    if kind == 3:
                        drops = entity[b'npcDrops'](row[1])
                        print('   drops:', list(drops.values()) if drops else [])
