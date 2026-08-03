#!/usr/bin/env node

import { existsSync, readdirSync, writeFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import path from 'node:path';
import {
  intro,
  outro,
  select,
  multiselect,
  text,
  isCancel,
  cancel,
} from '@clack/prompts';

const REPO_ROOT = execSync('git rev-parse --show-toplevel').toString().trim();
const GIT_DIR = execSync('git rev-parse --git-dir').toString().trim();
const MSG_FILE = path.join(GIT_DIR, 'VANIA_COMMIT_MSG');

const PARTS = ['backend', 'core', 'frontend'];

const CHANGE_TYPES = [
  { value: 'feat', label: 'feat', hint: 'a new feature' },
  { value: 'fix', label: 'fix', hint: 'a bug fix' },
  { value: 'test', label: 'test', hint: 'adding or fixing tests' },
  { value: 'refactor', label: 'refactor', hint: 'no behavior change' },
  { value: 'docs', label: 'docs', hint: 'documentation only' },
  { value: 'chore', label: 'chore', hint: 'tooling, deps, config' },
  { value: 'style', label: 'style', hint: 'formatting only' },
  { value: 'perf', label: 'perf', hint: 'performance improvement' },
  { value: 'build', label: 'build', hint: 'build system / dependencies' },
  { value: 'ci', label: 'ci', hint: 'CI/CD configuration' },
];

function modulesFor(part) {
  const modulesDir = path.join(REPO_ROOT, part, 'lib', 'modules');
  const found = existsSync(modulesDir)
    ? readdirSync(modulesDir, { withFileTypes: true })
        .filter((entry) => entry.isDirectory())
        .map((entry) => entry.name)
        .sort()
    : [];
  return [...found, 'shared', 'other'];
}

function abort(message) {
  cancel(message ?? 'Commit aborted.');
  process.exit(1);
}

async function main() {
  // No terminal attached (CI, GUI client, etc.) - don't block the commit.
  if (!process.stdin.isTTY) {
    process.exit(0);
  }

  intro('vaniabase commit wizard');

  const partChoice = await select({
    message: 'Which part does this change affect?',
    options: [
      { value: 'backend', label: 'Backend' },
      { value: 'core', label: 'Core' },
      { value: 'frontend', label: 'Frontend' },
      { value: 'all', label: 'All' },
    ],
  });
  if (isCancel(partChoice)) abort();

  const parts = partChoice === 'all' ? PARTS : [partChoice];
  const moduleOptions = [...new Set(parts.flatMap(modulesFor))].sort();

  const modules = await multiselect({
    message: `Which module(s) inside ${partChoice} does this change touch?`,
    options: moduleOptions.map((m) => ({ value: m, label: m })),
    required: true,
  });
  if (isCancel(modules)) abort();

  const type = await select({
    message: 'What type of change is this?',
    options: CHANGE_TYPES,
  });
  if (isCancel(type)) abort();

  const subject = await text({
    message: 'Commit message subject:',
    placeholder: 'short, imperative description',
    validate: (value) => {
      if (!value || !value.trim()) return 'Subject is required';
    },
  });
  if (isCancel(subject)) abort();

  const scope =
    partChoice === 'all'
      ? modules.join(',')
      : `${partChoice}/${modules.join(',')}`;

  const commitMessage = `${type}(${scope}): ${subject.trim()}`;

  writeFileSync(MSG_FILE, commitMessage, 'utf8');

  outro(`Will commit as: ${commitMessage}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
