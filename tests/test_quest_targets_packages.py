"""Verify the distributable package shapes and unchanged upstream payloads."""
import hashlib
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile


ROOT = Path(__file__).resolve().parents[1]
CACHE = Path(tempfile.gettempdir()) / 'quest-targets-questiedb-v1.0.4'
HASHES = {
    'Classic': ('Vanilla', 'cf0ac8dfd6b0986a0624db6364d4e42a3691089663b8b00122d8ae2b2d040eed'),
    'Forever': ('Forever', '2435d382c1a78c0876064c197196e73b9f417669f75187f51cc311fd8c2c19e1'),
}
POWERSHELL = shutil.which('powershell') or shutil.which('pwsh')


def require_powershell():
    if not POWERSHELL:
        raise unittest.SkipTest('PowerShell is not installed')


def require_provider_cache():
    if not all((CACHE / f'QuestieDB-{flavor}.zip').exists() for flavor, _ in HASHES.values()):
        raise unittest.SkipTest('Pinned QuestieDB archives are not cached')


class PackageTests(unittest.TestCase):
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
        self.build('Both', '-ProviderCache', str(CACHE))
        for label, (flavor, expected_hash) in HASHES.items():
            with self.subTest(label=label):
                upstream_path = CACHE / f'QuestieDB-{flavor}.zip'
                self.assertEqual(hashlib.sha256(upstream_path.read_bytes()).hexdigest(), expected_hash)
                package_path = ROOT / 'dist' / f'QuestTargets-{self.version}-{label}.zip'
                with zipfile.ZipFile(upstream_path) as upstream, zipfile.ZipFile(package_path) as package:
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
                    expected_tocs = ({'QuestieDB/QuestieDB_Vanilla.toc'} if label == 'Classic'
                                     else {'QuestieDB/QuestieDB_Forever.toc', 'QuestieDB/QuestieDB_Camelot.toc'})
                    self.assertEqual(tocs, expected_tocs)

    def test_default_build_also_contains_retail_without_questiedb(self):
        self.build('Retail')
        package_path = ROOT / 'dist' / f'QuestTargets-{self.version}-Retail.zip'
        with zipfile.ZipFile(package_path) as package:
            self.assertEqual(package.testzip(), None)
            self.assertTrue(all(name.startswith('QuestTargets/') for name in package.namelist()))
            self.assertFalse(any(name.endswith('.md') for name in package.namelist()))
            self.assertIn(b'120100', package.read('QuestTargets/QuestTargets.toc'))

    def test_both_official_providers_satisfy_the_addon_contract(self):
        require_provider_cache()
        from tests.questiedb_harness import load_release
        for label, (flavor, expected_hash) in HASHES.items():
            with self.subTest(label=label):
                lua = load_release(CACHE / f'QuestieDB-{flavor}.zip', flavor, expected_hash)
                lua.execute('NS={}')
                for source in ('Core.lua', 'Locale.lua', 'Database.lua'):
                    lua.execute('assert(loadstring(...))("QuestTargets",NS)',
                                (ROOT / 'QuestTargets' / source).read_bytes())
                lua.execute(f'''assert(NS.Database.Provider() == LibQuestieDB)
                    assert(LibQuestieDB.flavor.name == "{flavor}")
                    assert(LibQuestieDB.RequireContract(1))''')

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
