"""Verify the application checks that bin/check --full runs, with a simulated Xcode."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]


class CheckApplicationTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="pantrydates application checks ")
        self.addCleanup(temporary.cleanup)
        base = Path(temporary.name)
        self.repo = base / "checkout"
        (self.repo / "bin").mkdir(parents=True)
        shutil.copy2(SOURCE / "bin/check-application", self.repo / "bin/check-application")
        self.events = base / "events.jsonl"
        (self.repo / "tests").mkdir()
        for name in ("first", "second"):
            (self.repo / "tests" / f"test_{name}.py").write_text(
                "import json, os, unittest\n"
                "class Probe(unittest.TestCase):\n"
                "    def test_probe(self):\n"
                "        with open(os.environ['CHECK_EVENTS'], 'a') as stream:\n"
                f"            stream.write(json.dumps({{'test': '{name}'}}) + '\\n')\n"
                "        self.assertNotIn('FAIL_TESTS', os.environ)\n")
        tools = base / "tools"
        tools.mkdir()
        (tools / "python3").symlink_to(sys.executable)
        xcodebuild = tools / "xcodebuild"
        xcodebuild.write_text(
            "#!" + sys.executable + "\n"
            "import json, os, sys\n"
            "if sys.argv[1:] == ['-version']:\n"
            "    print(os.environ.get('CHECK_XCODE_VERSION', 'Xcode 26.3') + '\\nBuild version 17C52')\n"
            "    sys.exit(0)\n"
            "with open(os.environ['CHECK_EVENTS'], 'a') as stream:\n"
            "    stream.write(json.dumps({'args': sys.argv[1:], 'cwd': os.getcwd(),\n"
            "                             'git': any(key.startswith('GIT_') for key in os.environ)}) + '\\n')\n"
            "if 'FAIL_BUILD' in os.environ:\n"
            "    print('** BUILD FAILED **', file=sys.stderr)\n"
            "    sys.exit(65)\n")
        xcodebuild.chmod(0o755)
        self.env = {key: value for key, value in os.environ.items()
                    if key not in {"CHECK_XCODE_VERSION", "FAIL_BUILD", "FAIL_TESTS"}}
        self.env.update(PATH=str(tools), CHECK_EVENTS=str(self.events), GIT_DIR=str(base / "elsewhere.git"))

    def check(self, **extra):
        return subprocess.run([str(self.repo / "bin/check-application")], cwd=self.repo, env=self.env | extra,
                              text=True, capture_output=True, timeout=60)

    def recorded(self):
        events = [json.loads(line) for line in self.events.read_text().splitlines()] if self.events.exists() else []
        self.events.unlink(missing_ok=True)
        return events

    def test_runs_python_tests_then_builds_the_app_with_checkout_local_caches(self):
        for version in ("Xcode 26.3", "Xcode 27.0"):
            with self.subTest(version=version):
                result = self.check(CHECK_XCODE_VERSION=version)
                self.assertEqual(result.returncode, 0, result.stderr)
                *tests, build = self.recorded()
                self.assertEqual(tests, [{"test": "first"}, {"test": "second"}])
                root = self.repo.resolve()
                self.assertEqual(build, {"args": [
                    "-project", "pantrydates/pantrydates.xcodeproj", "-scheme", "pantrydates",
                    "-destination", "generic/platform=iOS Simulator",
                    "-derivedDataPath", str(root / ".cache/xcode/DerivedData"),
                    "-clonedSourcePackagesDirPath", str(root / ".cache/xcode/SourcePackages"),
                    "CODE_SIGNING_ALLOWED=NO", "build"], "cwd": str(root), "git": False})

    def test_unsupported_xcode_stops_before_any_check(self):
        for version in ("Xcode 25.4", "Xcode 26.2"):
            with self.subTest(version=version):
                result = self.check(CHECK_XCODE_VERSION=version)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(version, result.stderr)
                self.assertIn("is unsupported; select Xcode 26.3 or later", result.stderr)
                self.assertEqual(self.recorded(), [])

    def test_failures_propagate_and_stop_later_checks(self):
        result = self.check(FAIL_TESTS="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.recorded(), [{"test": "first"}, {"test": "second"}])
        result = self.check(FAIL_BUILD="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("** BUILD FAILED **", result.stderr)
        self.assertEqual(len(self.recorded()), 3)


if __name__ == "__main__":
    unittest.main()
