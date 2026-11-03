"""Publish verified GitHub release assets; defaults to a read-only dry run."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tempfile
import time
from urllib import error, request
import uuid
import zipfile

ROOT = Path(__file__).resolve().parents[1]
FLAVORS = ('Classic', 'TBC', 'Mists', 'Forever', 'Retail')
CF_API = 'https://wow.curseforge.com/api'


class PublishError(Exception):
    pass


def release_version(tag, release):
    if not re.fullmatch(r'v\d+\.\d+\.\d+', tag):
        raise PublishError('Only stable vMAJOR.MINOR.PATCH tags can be published.')
    if release.get('isDraft') or release.get('isPrerelease'):
        raise PublishError('Drafts and prereleases are not published to CurseForge.')
    return tag[1:]


def read_changelog(root, version):
    path = root / 'docs' / 'curseforge' / f'{version}.md'
    if not path.is_file():
        raise PublishError(f'Missing player changelog: {path}. No developer-notes fallback.')
    text = path.read_text(encoding='utf-8').strip()
    if len(text) < 40 or not re.search(r'^[-*] ', text, re.M) or re.search(r'\b(TODO|TBD)\b', text):
        raise PublishError('Player changelog is empty, incomplete or not a Markdown list.')
    return text


def resolve_versions(rows, pins, flavors):
    result = {}
    for flavor in flavors:
        name = '.'.join(pins[flavor]['version'].split('.')[:3])
        matches = [row for row in rows if row.get('name') == name]
        if len(matches) != 1 or not isinstance(matches[0].get('id'), int):
            raise PublishError(f'CurseForge game version {name} ({flavor}) is missing or ambiguous.')
        result[flavor] = matches[0]['id']
    return result


def read_checksums(path):
    result = {}
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        match = re.fullmatch(r'([0-9a-fA-F]{64})  ([A-Za-z0-9._-]+)', line)
        if not match or match[2] in result:
            raise PublishError('Invalid or duplicate entry in SHA256SUMS.txt.')
        result[match[2]] = match[1].lower()
    return result


def verify_asset(path, version, flavor, checksums, interface):
    expected_name = f'QuestTargets-{version}-{flavor}.zip'
    if path.name != expected_name or checksums.get(path.name) != hashlib.sha256(path.read_bytes()).hexdigest():
        raise PublishError(f'Archive name/checksum mismatch: {path.name}')
    try:
        with zipfile.ZipFile(path) as archive:
            names = archive.namelist()
            allowed = {'QuestTargets'}
            if len(names) != len(set(names)) or sum(i.file_size for i in archive.infolist()) > 300_000_000:
                raise PublishError('Duplicate or oversized ZIP payload.')
            for name in names:
                parts = PurePosixPath(name).parts
                if not parts or parts[0] not in allowed or '..' in parts or '\\' in name or ':' in name:
                    raise PublishError(f'Unexpected ZIP path: {name}')
            if archive.testzip() is not None:
                raise PublishError('ZIP integrity check failed.')
            toc = archive.read('QuestTargets/QuestTargets.toc').decode('utf-8-sig')
            if not re.search(r'^## Version: ' + re.escape(version) + r'\s*$', toc, re.M):
                raise PublishError('ZIP TOC version differs from release tag.')
            declared = re.search(r'^## Interface: (.+)$', toc, re.M)
            if not declared or str(interface) not in declared[1].strip().split(', '):
                raise PublishError(f'{flavor} interface pin is not supported by the ZIP.')
            if 'QuestTargets/Bindings.xml' not in names:
                raise PublishError('ZIP is missing native keybindings.')
    except (zipfile.BadZipFile, KeyError, UnicodeError) as exc:
        raise PublishError(f'Invalid release ZIP: {path.name}') from exc


def multipart(metadata, filename, data):
    boundary = 'questtargets-' + uuid.uuid4().hex
    body = (f'--{boundary}\r\nContent-Disposition: form-data; name="metadata"\r\n'
            'Content-Type: application/json\r\n\r\n').encode()
    body += json.dumps(metadata, ensure_ascii=False).encode() + b'\r\n'
    body += (f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{filename}"\r\n'
             'Content-Type: application/zip\r\n\r\n').encode()
    body += data + f'\r\n--{boundary}--\r\n'.encode()
    return body, f'multipart/form-data; boundary={boundary}'


def gh(*args, payload=None, allow_failure=False):
    result = subprocess.run(['gh', *args], input=json.dumps(payload) if payload else None,
                            text=True, encoding='utf-8', capture_output=True)
    if result.returncode and not allow_failure:
        raise PublishError('GitHub CLI request failed: ' + result.stderr.strip())
    return result


def cf_json(endpoint, token, data=None, content_type=None):
    headers = {'X-Api-Token': token, 'User-Agent': 'QuestTargets-release-publisher'}
    if content_type:
        headers['Content-Type'] = content_type
    req = request.Request(CF_API + endpoint, data=data, headers=headers)
    try:
        with request.urlopen(req, timeout=120) as response:
            return json.load(response)
    except (error.HTTPError, error.URLError, TimeoutError, ValueError) as exc:
        # Do not echo authenticated requests, headers or arbitrary server bodies.
        status = getattr(exc, 'code', 'connection/response error')
        raise PublishError(f'CurseForge request failed ({status}). Uploads are never automatically retried.') from exc


def reserve_upload(repository, tag, flavor, commit):
    ref = f'tags/curseforge/{tag}/{flavor}'
    result = gh('api', '--method', 'POST', f'repos/{repository}/git/refs', '--input', '-',
                payload={'ref': 'refs/' + ref, 'sha': commit}, allow_failure=True)
    if result.returncode == 0:
        return True
    existing = gh('api', f'repos/{repository}/git/ref/{ref}', allow_failure=True)
    if existing.returncode == 0:
        return False
    raise PublishError('Cannot reserve upload in GitHub; no CurseForge upload was attempted.')


def run_uploads(plans, reserve, upload):
    results = []
    for plan in plans:
        if not reserve(plan):
            raise PublishError(f'{plan["flavor"]} is already reserved. Check the previous upload before retrying.')
        file_id = upload(plan)
        if not isinstance(file_id, int) or file_id <= 0:
            raise PublishError('Upload returned no valid file ID; reservation retained. Check CurseForge.')
        results.append({'flavor': plan['flavor'], 'fileID': file_id})
        print(f'CurseForge accepted {plan["flavor"]}: file ID {file_id}', flush=True)
        if os.environ.get('GITHUB_STEP_SUMMARY'):
            with open(os.environ['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as summary:
                summary.write(f'- {plan["flavor"]}: CurseForge file ID **{file_id}**\n')
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--flavor', choices=('All', *FLAVORS), default='All')
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--publish', action='store_true')
    modes.add_argument('--dry-run', action='store_true')
    parser.add_argument('--offline-versions', type=Path,
                        help='Use a captured CurseForge versions response for a token-free dry run only.')
    args = parser.parse_args()
    config = json.loads((ROOT / 'tools/curseforge.json').read_text(encoding='utf-8'))
    repository = config['repository']
    if os.environ.get('GITHUB_REPOSITORY', repository) != repository:
        raise PublishError('Publishing is restricted to the configured source repository.')
    if args.publish and (os.environ.get('CURSEFORGE_ENABLED') != 'true' or args.offline_versions):
        raise PublishError('Publishing requires CURSEFORGE_ENABLED=true and live version lookup.')
    release = json.loads(gh('release', 'view', args.tag, '--repo', repository,
                            '--json', 'isDraft,isPrerelease,tagName,assets').stdout)
    version = release_version(args.tag, release)
    notes = read_changelog(ROOT, version)
    flavors = list(FLAVORS) if args.flavor == 'All' else [args.flavor]
    pins = json.loads((ROOT / 'tools/client-versions.json').read_text(encoding='utf-8'))['flavors']
    token = os.environ.get('CF_API_TOKEN', '')
    if args.offline_versions:
        print('OFFLINE VERSION FIXTURE: version IDs are simulated/captured; uploading is disabled.')
        rows = json.loads(args.offline_versions.read_text(encoding='utf-8'))
    else:
        if not token:
            raise PublishError('Set CF_API_TOKEN to a CurseForge Upload API token, or use --offline-versions for a dry run.')
        rows = cf_json('/game/versions', token)
    versions = resolve_versions(rows, pins, flavors)
    filenames = [f'QuestTargets-{version}-{flavor}.zip' for flavor in flavors]
    # Some release tools publish before attaching assets. Read-only waiting is safe.
    for attempt in range(13):
        assets = {asset['name']: asset for asset in release['assets']}
        if all(name in assets for name in [*filenames, 'SHA256SUMS.txt']):
            break
        if attempt == 12:
            raise PublishError('Release assets are incomplete; attach the ZIPs and SHA256SUMS.txt first.')
        time.sleep(5)
        release = json.loads(gh('release', 'view', args.tag, '--repo', repository,
                               '--json', 'isDraft,isPrerelease,tagName,assets').stdout)
        release_version(args.tag, release)
    with tempfile.TemporaryDirectory(prefix='questtargets-curseforge-') as tmp:
        folder = Path(tmp)
        patterns = [item for name in [*filenames, 'SHA256SUMS.txt'] for item in ('--pattern', name)]
        gh('release', 'download', args.tag, '--repo', repository, '--dir', tmp, *patterns)
        checksums = read_checksums(folder / 'SHA256SUMS.txt')
        plans = []
        for flavor, filename in zip(flavors, filenames):
            path = folder / filename
            verify_asset(path, version, flavor, checksums, pins[flavor]['interface'])
            digest = assets[filename].get('digest')
            if digest and digest != 'sha256:' + checksums[filename]:
                raise PublishError('GitHub asset digest differs from SHA256SUMS.txt.')
            metadata = {'displayName': f'Quest Targets {version} - {flavor}',
                        'changelog': notes, 'changelogType': 'markdown',
                        'gameVersions': [versions[flavor]], 'releaseType': 'release'}
            plans.append({'flavor': flavor, 'path': path, 'metadata': metadata})
            print(f'Validated {filename}; CurseForge game version ID {versions[flavor]}')
        print('\nPlayer changelog:\n' + notes)
        if not args.publish:
            print('\nDRY RUN: no reservations created and no files uploaded.')
            return
        commit = json.loads(gh('api', f'repos/{repository}/commits/{args.tag}').stdout)['sha']
        def upload(plan):
            body, content_type = multipart(plan['metadata'], plan['path'].name, plan['path'].read_bytes())
            response = cf_json(f'/projects/{config["projectID"]}/upload-file', token, body, content_type)
            return response.get('id')
        run_uploads(plans, lambda plan: reserve_upload(repository, args.tag, plan['flavor'], commit), upload)


if __name__ == '__main__':
    # Windows terminals otherwise default to a legacy encoding without “→”.
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, 'reconfigure'):
            stream.reconfigure(encoding='utf-8')
    try:
        main()
    except PublishError as exc:
        print('ERROR: ' + str(exc), file=sys.stderr)
        sys.exit(1)
