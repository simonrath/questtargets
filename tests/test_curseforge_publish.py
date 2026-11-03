import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile
from unittest.mock import patch
import json
import os

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('curseforge_publish', ROOT / 'tools/publish_curseforge.py')
cf = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(cf)


class CurseForgeTests(unittest.TestCase):
    def test_only_published_stable_version_tags(self):
        self.assertEqual(cf.release_version('v1.4.1', {'isDraft': False, 'isPrerelease': False}), '1.4.1')
        for tag, release in [('main', {}), ('v1.4.1-beta', {}),
                             ('v1.4.1', {'isDraft': True}), ('v1.4.1', {'isPrerelease': True})]:
            with self.assertRaises(cf.PublishError):
                cf.release_version(tag, release)

    def test_exact_unambiguous_version_ids_not_interface_numbers(self):
        pins = {'Classic': {'version': '1.15.9.123', 'interface': 11509}}
        rows = [{'name': '1.15.9', 'id': 42}, {'name': '1.15.8', 'id': 41}]
        self.assertEqual(cf.resolve_versions(rows, pins, ['Classic']), {'Classic': 42})
        for bad in ([], rows + [{'name': '1.15.9', 'id': 43}]):
            with self.assertRaises(cf.PublishError):
                cf.resolve_versions(bad, pins, ['Classic'])

    def test_changelog_has_no_fallback_to_developer_release_body(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with self.assertRaises(cf.PublishError):
                cf.read_changelog(root, '1.4.1')
            path = root / 'docs/curseforge/1.4.1.md'
            path.parent.mkdir(parents=True)
            path.write_text('# Quest Targets 1.4.1\n\n- Bind controller buttons.\n')
            self.assertIn('controller', cf.read_changelog(root, '1.4.1'))
            path.write_text('TODO')
            with self.assertRaises(cf.PublishError):
                cf.read_changelog(root, '1.4.1')

    def make_archive(self, directory, flavor='Retail', version='1.4.1', extra=None):
        path = Path(directory) / f'QuestTargets-1.4.1-{flavor}.zip'
        with zipfile.ZipFile(path, 'w') as archive:
            archive.writestr('QuestTargets/QuestTargets.toc',
                             f'## Version: {version}\n## Interface: 120105, 16001\n')
            archive.writestr('QuestTargets/Bindings.xml', '<Bindings/>')
            if extra:
                archive.writestr(*extra)
        return path

    def verify(self, path, flavor='Retail', checksum=None):
        checksum = checksum or hashlib.sha256(path.read_bytes()).hexdigest()
        cf.verify_asset(path, '1.4.1', flavor, {path.name: checksum}, 120105 if flavor=='Retail' else 16001)

    def test_checksums_version_and_flavor_payload(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.make_archive(tmp)
            self.verify(path)
            with self.assertRaises(cf.PublishError):
                self.verify(path, checksum='0'*64)
            path = self.make_archive(tmp, version='1.4.0')
            with self.assertRaises(cf.PublishError):
                self.verify(path)
            path = self.make_archive(tmp, flavor='Forever')
            self.verify(path, flavor='Forever')

    def test_rejects_unexpected_folders_paths_and_retail_database(self):
        for entry in ('../escaped', 'AnotherAddon/code.lua', 'QuestTargets/../escaped',
                      'QuestieDB/src/api.lua'):
            with self.subTest(entry=entry), tempfile.TemporaryDirectory() as tmp:
                path = self.make_archive(tmp, extra=(entry, 'bad'))
                with self.assertRaises(cf.PublishError):
                    self.verify(path)

    def test_rejects_bundled_database_for_every_flavor(self):
        for flavor in cf.FLAVORS:
            with self.subTest(flavor=flavor), tempfile.TemporaryDirectory() as tmp:
                path = self.make_archive(tmp, flavor=flavor,
                                         extra=('QuestieDB/src/api.lua', '-- provider'))
                with self.assertRaises(cf.PublishError):
                    self.verify(path, flavor=flavor)

    def test_reserve_precedes_upload_and_duplicate_is_not_uploaded(self):
        events = []
        plans = [{'flavor': 'Classic'}, {'flavor': 'Retail'}]
        def reserve(plan):
            events.append(('reserve', plan['flavor']))
            return plan['flavor'] != 'Retail'
        def upload(plan):
            events.append(('upload', plan['flavor']))
            return 321
        with self.assertRaises(cf.PublishError):
            cf.run_uploads(plans, reserve, upload)
        self.assertEqual(events, [('reserve', 'Classic'), ('upload', 'Classic'), ('reserve', 'Retail')])

    def test_uncertain_post_is_never_retried(self):
        calls = []
        def upload(plan):
            calls.append(plan)
            raise cf.PublishError('Connection lost after request')
        with self.assertRaises(cf.PublishError):
            cf.run_uploads([{'flavor': 'Forever'}], lambda plan: True, upload)
        self.assertEqual(len(calls), 1)

    def test_multipart_contains_json_and_exact_zip_bytes(self):
        body, content_type = cf.multipart({'changelog': 'Player notes', 'gameVersions': [42]}, 'addon.zip', b'ZIP\x00DATA')
        self.assertIn('boundary=', content_type)
        self.assertIn(b'name="metadata"', body)
        self.assertIn(b'"gameVersions": [42]', body)
        self.assertIn(b'ZIP\x00DATA', body)

    def test_no_upload_when_later_flavor_validation_fails(self):
        from types import SimpleNamespace
        release = {'isDraft': False, 'isPrerelease': False, 'assets':
                   [{'name': f'QuestTargets-1.4.1-{flavor}.zip'} for flavor in cf.FLAVORS]
                   + [{'name': 'SHA256SUMS.txt'}]}
        def fake_gh(*args, **kwargs):
            if args[:2] == ('release', 'view'):
                return SimpleNamespace(stdout=json.dumps(release))
            if args[:2] == ('release', 'download'):
                destination = Path(args[args.index('--dir')+1])
                (destination/'SHA256SUMS.txt').write_text('')
                return SimpleNamespace(stdout='')
            self.fail(f'Unexpected GitHub write: {args}')
        def verify(path, version, flavor, checksums, interface):
            if flavor == 'Retail':
                raise cf.PublishError('Final archive is invalid')
        with patch.object(cf, 'gh', side_effect=fake_gh), \
             patch.object(cf, 'verify_asset', side_effect=verify), \
             patch.object(cf, 'read_changelog', return_value='- Player notes'), \
             patch.object(cf, 'resolve_versions', return_value=dict.fromkeys(cf.FLAVORS, 42)), \
             patch.object(cf, 'cf_json', return_value=[]), \
             patch.object(cf, 'reserve_upload') as reserve, \
             patch.dict(os.environ, {'CURSEFORGE_ENABLED': 'true', 'CF_API_TOKEN': 'test-token',
                                     'GITHUB_REPOSITORY': 'simonrath/questtargets'}), \
             patch.object(cf.sys, 'argv', ['publisher', '--tag', 'v1.4.1', '--publish']):
            with self.assertRaisesRegex(cf.PublishError, 'Final archive'):
                cf.main()
            reserve.assert_not_called()

    def test_disabled_publishing_cannot_write(self):
        with patch.dict(os.environ, {'CURSEFORGE_ENABLED': 'false'}), \
             patch.object(cf, 'gh') as github, \
             patch.object(cf.sys, 'argv', ['publisher', '--tag', 'v1.4.1', '--publish']):
            with self.assertRaises(cf.PublishError):
                cf.main()
            github.assert_not_called()

    def test_invalid_and_duplicate_checksum_entries(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp)/'SHA256SUMS.txt'
            valid = 'a'*64 + '  addon.zip\n'
            path.write_text(valid)
            self.assertEqual(cf.read_checksums(path), {'addon.zip': 'a'*64})
            for text in (valid+valid, 'a'*64+'  ../addon.zip\n'):
                path.write_text(text)
                with self.assertRaises(cf.PublishError):
                    cf.read_checksums(path)


if __name__ == '__main__':
    unittest.main()
