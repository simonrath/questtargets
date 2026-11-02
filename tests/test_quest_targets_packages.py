"""Verify the distributable package shapes and unchanged upstream payloads."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile


ROOT = Path(__file__).resolve().parents[1]
CACHE = Path(tempfile.gettempdir()) / 'quest-targets-questiedb-v1.0.9'
PRODUCER_COMMIT = b'7901fee2753cecb577a72c2e4b7126198e05baec'
HASHES = {
    'Classic': ('Vanilla', '72b0353075df53d09d540dbd016c84b37ccce7ea08394421d7558fbd28121f9c'),
    'TBC': ('TBC', '6bcd8c1aff2ee55e6ec878f9b4f4e9323d645eb56125a56deab2bb7fa3735460'),
    'Mists': ('Mists', '5eb1315a52287c8c664b6aac747fa2e9d6071416c613903e678984d5d6aaf7b6'),
    'Forever': ('Forever', '9c180a2ecfa22328c6c7fa7d4e8154a178229d8e2339fce0b480f80916653edb'),
}
POWERSHELL = shutil.which('powershell') or shutil.which('pwsh')


def require_powershell():
    if not POWERSHELL:
        raise unittest.SkipTest('PowerShell is not installed')


def require_provider_cache():
    if not all((CACHE / f'QuestieDB-{flavor}.zip').exists() for flavor, _ in HASHES.values()):
        raise unittest.SkipTest('Pinned QuestieDB archives are not cached')


class PackageTests(unittest.TestCase):
    def test_client_pins_match_declared_interfaces(self):
        pins = json.loads((ROOT / 'tools/client-versions.json').read_text(encoding='utf-8'))
        self.assertEqual(set(pins['flavors']), {'Retail', 'Classic', 'TBC', 'Mists', 'Forever'})
        toc = (ROOT / 'QuestTargets/QuestTargets.toc').read_text(encoding='utf-8')
        declared = next(line.partition(': ')[2] for line in toc.splitlines()
                        if line.startswith('## Interface: '))
        self.assertEqual(set(declared.split(', ')),
                         {str(pin['interface']) for pin in pins['flavors'].values()})
        self.assertEqual(pins['flavors']['Retail']['interface'], 120105)
        for pin in pins['flavors'].values():
            self.assertTrue(pin['source'].startswith('https://eu.version.battle.net/'))
            self.assertTrue(pin['version'].endswith('.' + str(pin['build'])))
            major, minor, patch, _ = map(int, pin['version'].split('.'))
            self.assertEqual(pin['interface'], major * 10000 + minor * 100 + patch)

    def test_addon_category_and_client_interfaces(self):
        toc = (ROOT / 'QuestTargets/QuestTargets.toc').read_text(encoding='utf-8')
        self.assertIn('## Category: Quests', toc)
        self.assertIn('## Category-deDE: Quests', toc)
        interface = next(line.partition(': ')[2] for line in toc.splitlines()
                         if line.startswith('## Interface: '))
        self.assertTrue({'20506', '50504'} <= set(interface.split(', ')))

    def test_forever_interface_matches_official_provider(self):
        require_provider_cache()
        with zipfile.ZipFile(CACHE / 'QuestieDB-Forever.zip') as provider:
            provider_toc = provider.read('QuestieDB/QuestieDB_Forever.toc').splitlines()
        interface = next(line.partition(b': ')[2].decode('ascii') for line in provider_toc
                         if line.startswith(b'## Interface: '))
        addon_toc = (ROOT / 'QuestTargets/QuestTargets.toc').read_text(encoding='utf-8')
        declared = next(line.partition(': ')[2].strip().split(', ') for line in addon_toc.splitlines()
                        if line.startswith('## Interface: '))
        self.assertIn(interface, declared)

    @classmethod
    def setUpClass(cls):
        cls.version = next(line.partition(': ')[2].strip() for line in
                           (ROOT / 'QuestTargets/QuestTargets.toc').read_text(encoding='utf-8').splitlines()
                           if line.startswith('## Version: '))

    def build(self, flavor, *extra):
        require_powershell()
        result = subprocess.run(
            [POWERSHELL, '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
             str(ROOT / 'tools/package_quest_targets.ps1'), '-Flavor', flavor, *extra],
            cwd=ROOT, capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_combined_packages_contain_exact_official_provider_files(self):
        require_provider_cache()
        self.build('All', '-ProviderCache', str(CACHE))
        for label, (flavor, expected_hash) in HASHES.items():
            with self.subTest(label=label):
                upstream_path = CACHE / f'QuestieDB-{flavor}.zip'
                self.assertEqual(hashlib.sha256(upstream_path.read_bytes()).hexdigest(), expected_hash)
                package_path = ROOT / 'dist' / f'QuestTargets-{self.version}-{label}.zip'
                with zipfile.ZipFile(upstream_path) as upstream, zipfile.ZipFile(package_path) as package:
                    toc = upstream.read(f'QuestieDB/QuestieDB_{flavor}.toc')
                    self.assertIn(b'## Version: 1.0.9', toc)
                    self.assertIn(b'## X-Contract-Version: 4', toc)
                    self.assertIn(b'## X-BUILD-COMMIT: ' + PRODUCER_COMMIT, toc)
                    provider_names = {n for n in package.namelist() if n.startswith('QuestieDB/')}
                    source_names = {n for n in upstream.namelist() if not n.endswith('/')}
                    self.assertEqual(provider_names, source_names)
                    self.assertTrue(all(n.startswith(('QuestTargets/', 'QuestieDB/')) for n in package.namelist()))
                    self.assertTrue(any(n.startswith('QuestTargets/') for n in package.namelist()))
                    self.assertEqual(len(package.namelist()), len(set(package.namelist())))
                    for name in source_names:
                        self.assertEqual(package.read(name), upstream.read(name), name)
                    self.assertEqual(package.testzip(), None)
                    tocs = {n for n in provider_names if n.endswith('.toc')}
                    expected_tocs = ({'QuestieDB/QuestieDB_Forever.toc', 'QuestieDB/QuestieDB_Camelot.toc'}
                                     if label == 'Forever' else {f'QuestieDB/QuestieDB_{flavor}.toc'})
                    self.assertEqual(tocs, expected_tocs)

    def test_forever_archive_contains_v109_base_data(self):
        require_provider_cache()
        with zipfile.ZipFile(CACHE / 'QuestieDB-Forever.zip') as upstream:
            toc = upstream.read('QuestieDB/QuestieDB_Forever.toc')
        self.assertIn(b'## Version: 1.0.9', toc)
        self.assertGreater(sum(line.startswith(b'## X-Npc-') for line in toc.splitlines()), 28000)
        self.assertGreater(sum(line.startswith(b'## X-Quest-') for line in toc.splitlines()), 29000)

    def test_default_build_also_contains_retail_without_questiedb(self):
        self.build('Retail')
        package_path = ROOT / 'dist' / f'QuestTargets-{self.version}-Retail.zip'
        with zipfile.ZipFile(package_path) as package:
            self.assertEqual(package.testzip(), None)
            self.assertTrue(all(name.startswith('QuestTargets/') for name in package.namelist()))
            self.assertFalse(any(name.endswith('.md') for name in package.namelist()))
            self.assertIn(b'120105', package.read('QuestTargets/QuestTargets.toc'))

    def test_all_official_providers_satisfy_quest_targets_and_questie_contracts(self):
        require_provider_cache()
        from tests.questiedb_harness import load_release
        for label, (flavor, expected_hash) in HASHES.items():
            with self.subTest(label=label):
                lua = load_release(CACHE / f'QuestieDB-{flavor}.zip', flavor, expected_hash)
                lua.execute('NS={}')
                for source in ('Core.lua', 'Locale.lua', 'Database.lua', 'Proximity.lua'):
                    lua.execute('assert(loadstring(...))("QuestTargets",NS)',
                                (ROOT / 'QuestTargets' / source).read_bytes())
                if label in ('TBC', 'Mists'):
                    interface = 20506 if label == 'TBC' else 50504
                    lua.execute(f'function GetBuildInfo() return "", "", "", {interface} end')
                lua.execute(f'''assert(NS.Database.Provider() == LibQuestieDB)
                    assert(LibQuestieDB.flavor.name == "{flavor}")
                    assert(LibQuestieDB.RequireContract(1))''')
                self.assertIs(lua.eval('(LibQuestieDB.RequireContract(4))'), True,
                              'Questie 12.1.0 requires provider contract 4')
                lua.execute('''assert(type(LibQuestieDB.Enum.raceMaskById) == "table")
                    assert(type(LibQuestieDB.Enum.factionRaceMasks.Alliance) == "number")
                    assert(type(LibQuestieDB.Enum.factionRaceMasks.Horde) == "number")''')
                lua.execute('''
                    -- Compare the non-executing parser with the pinned provider's
                    -- actual map data. Compiling the trusted fixture is test-only.
                    local data=LibQuestieDB.Support.Get("ZoneDB").private
                    local expected={}
                    for _,key in ipairs({"areaIdToUiMapId", "areaIdToUiMapIdOverride"}) do
                        local value=data[key]
                        local map=type(value)=="string" and assert(loadstring(value))() or value or {}
                        for area,id in pairs(map) do expected[area]=id end
                    end
                    assert(next(expected), "Provider map fixture is empty")
                    local p=NS.Proximity
                    p.Register(LibQuestieDB,1,"Probe")
                    p.position={continent=1,x=0,y=0}
                    local compile=loadstring
                    loadstring=function() error("Runtime map compilation") end
                    p.Distance("Probe")
                    loadstring=compile
                    for area,id in pairs(expected) do assert(p.maps[area]==id, "Missing map: "..area) end
                    for area,id in pairs(p.maps) do assert(expected[area]==id, "Unexpected map: "..area) end
                ''')

    def test_minimal_package_still_excludes_database_and_documents(self):
        self.build('Minimal', '-CurseForge')
        with zipfile.ZipFile(ROOT / 'dist' / f'QuestTargets-{self.version}.zip') as package:
            self.assertTrue(package.namelist())
            self.assertTrue(all(n.startswith('QuestTargets/') for n in package.namelist()))
            self.assertFalse(any(n.endswith('.md') for n in package.namelist()))

    def test_corrupt_provider_archive_is_rejected(self):
        require_powershell()
        with tempfile.TemporaryDirectory() as cache:
            (Path(cache) / 'QuestieDB-Vanilla.zip').write_bytes(b'not a QuestieDB release')
            result = subprocess.run(
                [POWERSHELL, '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
                 str(ROOT / 'tools/package_quest_targets.ps1'), '-Flavor', 'Classic',
                 '-ProviderCache', cache],
                cwd=ROOT, capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('checksum mismatch', result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
