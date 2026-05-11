# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## What this repo is

Routing-only entry point for `youssef-aitelourf.com`. No UI, no build step — just `vercel.json`.

## Commands

```bash
# Validate vercel.json locally
python3 -c "import json; json.load(open('vercel.json')); print('OK')"
```

## Adding a new project

1. Deploy the sub-project on Vercel with `basePath: "/route-name"` in its `next.config.ts`
2. Add one entry to the `rewrites` array in `vercel.json`
3. Open a PR `dev → main` — CI validates the JSON, merge deploys to production

## Rules

- Never push directly to `main` — all changes via PR from `dev`
- Secrets never go in vercel.json (use Vercel dashboard for sub-projects)
- The `destination` URL must be the stable Vercel URL (not a per-deployment URL)
  Format: `https://<project-name>-youssef-ait-elourfs-projects.vercel.app`
