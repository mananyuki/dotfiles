#!/usr/bin/env bun
/**
 * Update custom Nix packages to their latest GitHub release versions.
 *
 * Usage:
 *   bun run update-packages.ts              # update all
 *   bun run update-packages.ts --check      # dry run
 *   bun run update-packages.ts --package mo # update one
 */

import { $, Glob } from "bun";
import { readFile, writeFile } from "node:fs/promises";
import { basename, join } from "node:path";
import { parseArgs } from "node:util";

const { values: flags } = parseArgs({
  args: Bun.argv.slice(2),
  options: {
    check: { type: "boolean", default: false },
    package: { type: "string" },
  },
});

const repoRoot = (await $`git rev-parse --show-toplevel`.text()).trim();
const pkgDir = join(repoRoot, "nix", "packages");

const GITHUB_RELEASE_RE =
  /github\.com\/(?<owner>[^/]+)\/(?<repo>[^/]+)\/releases\/download\//;

interface Result {
  package: string;
  old: string;
  new: string;
  status: "updated" | "up-to-date" | "update-available" | "skipped" | "error";
  message?: string;
}

// Verify required tools
for (const cmd of ["gh", "nix"]) {
  const which = await $`which ${cmd}`.quiet().nothrow();
  if (which.exitCode !== 0) {
    console.error(JSON.stringify({ error: `${cmd} is required but not found` }));
    process.exit(1);
  }
}

const glob = new Glob("*.nix");
const nixFiles = Array.from(glob.scanSync(pkgDir)).sort();

for (const filename of nixFiles) {
  const pname = basename(filename, ".nix");

  if (flags.package && pname !== flags.package) continue;

  const filePath = join(pkgDir, filename);
  const content = await readFile(filePath, "utf-8");

  // Extract GitHub owner/repo from URL
  const urlMatch = content.match(GITHUB_RELEASE_RE);
  if (!urlMatch?.groups) {
    console.log(JSON.stringify({ package: pname, old: "", new: "", status: "skipped" } satisfies Result));
    continue;
  }

  const { owner, repo } = urlMatch.groups;
  const currentVersion = content.match(/version\s*=\s*"([^"]+)"/)?.[1];
  if (!currentVersion) {
    console.log(
      JSON.stringify({ package: pname, old: "", new: "", status: "error", message: "could not parse version" } satisfies Result),
    );
    continue;
  }

  // Fetch latest release tag
  let latestTag: string;
  try {
    latestTag = (await $`gh api repos/${owner}/${repo}/releases/latest --jq .tag_name`.text()).trim();
  } catch {
    console.log(
      JSON.stringify({
        package: pname,
        old: currentVersion,
        new: "",
        status: "error",
        message: "failed to fetch latest release",
      } satisfies Result),
    );
    continue;
  }

  const latestVersion = latestTag.replace(/^v/, "");

  if (currentVersion === latestVersion) {
    console.log(JSON.stringify({ package: pname, old: currentVersion, new: latestVersion, status: "up-to-date" } satisfies Result));
    continue;
  }

  if (flags.check) {
    console.log(
      JSON.stringify({ package: pname, old: currentVersion, new: latestVersion, status: "update-available" } satisfies Result),
    );
    continue;
  }

  // Build the new URL by substituting version in the URL template from the file.
  // The .nix file uses ${version} interpolation; we extract the raw URL line and
  // replace the current version literal with the new one.
  const urlLine = content.match(/url\s*=\s*"([^"]+)"/)?.[1];
  if (!urlLine) {
    console.log(
      JSON.stringify({ package: pname, old: currentVersion, new: latestVersion, status: "error", message: "could not parse URL" } satisfies Result),
    );
    continue;
  }

  // The URL in the file contains ${version} — resolve it with the new version
  const newUrl = urlLine.replace(/\$\{version\}/g, latestVersion);

  // Compute SRI hash
  let newHash: string;
  try {
    const prefetchOutput = (await $`nix store prefetch-file --json ${newUrl}`.text()).trim();
    newHash = JSON.parse(prefetchOutput).hash;
  } catch {
    console.log(
      JSON.stringify({
        package: pname,
        old: currentVersion,
        new: latestVersion,
        status: "error",
        message: `failed to compute hash for ${newUrl}`,
      } satisfies Result),
    );
    continue;
  }

  // Update the .nix file
  const updated = content
    .replace(/(version\s*=\s*")([^"]+)(")/, `$1${latestVersion}$3`)
    .replace(/(hash\s*=\s*")([^"]+)(")/, `$1${newHash}$3`);

  await writeFile(filePath, updated);

  console.log(JSON.stringify({ package: pname, old: currentVersion, new: latestVersion, status: "updated" } satisfies Result));
}
