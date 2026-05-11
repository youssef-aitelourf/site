# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Routing-only entry point for `youssef-aitelourf.com`. No UI, no build step — just `vercel.json`.
The domain is assigned exclusively to this project on Vercel (team: `youssef-ait-elourfs-projects`).

## Commands

```bash
# Validate vercel.json locally
python3 -c "import json; json.load(open('vercel.json')); print('OK')"
```

CI (`.github/workflows/ci.yml`) runs the same validation on every push to `dev` and PR to `main`.

## Adding a new project

Each project needs **two** rewrite entries — one for the root path and one for sub-paths. Vercel's `/:path*` wildcard does not match the root path without a trailing segment.

```json
{ "source": "/mon-projet",        "destination": "https://<url>/mon-projet" },
{ "source": "/mon-projet/:path*", "destination": "https://<url>/mon-projet/:path*" }
```

Full steps:
1. Deploy the sub-project on Vercel with `basePath: "/mon-projet"` in its `next.config.ts`
2. Add the two rewrite entries above to `vercel.json`
3. Open a PR `dev → main` — CI validates the JSON, merge deploys to production

## Vercel sub-project requirements

Sub-projects have no custom domain — they are served exclusively via their `.vercel.app` URL through this project's rewrites. For these rewrites to work, Vercel's **Deployment Protection must be disabled** on each sub-project (`ssoProtection: null`). If a sub-project starts returning 401, run:

```bash
curl -X PATCH "https://api.vercel.com/v9/projects/<PROJECT_ID>?teamId=team_folYzpvs2nNSQkAi6gVVg2xi" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ssoProtection": null}'
```

## Active projects

| Route | Vercel project | Stable URL |
|-------|---------------|------------|
| `/portfolio` | `portfolio-2` | `portfolio-2-youssef-ait-elourfs-projects.vercel.app` |
| `/cv-adapter` | `cv-adapter` | `cv-adapter-youssef-ait-elourfs-projects.vercel.app` |

## Rules

- Never push directly to `main` — all changes via PR from `dev`
- `destination` must use the stable project URL, not a per-deployment URL
- Secrets never go in `vercel.json` (configure env vars in the Vercel dashboard of the sub-project)
