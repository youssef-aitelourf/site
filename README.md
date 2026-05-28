# site — youssef-aitelourf.com

Point d'entrée du domaine. Ne contient pas d'UI — uniquement le routing vers les sous-projets.

## Ajouter un nouveau projet

**1. Déployer le sous-projet sur Vercel** (indépendamment), avec dans son `next.config.ts` :
```ts
const nextConfig = {
  basePath: "/mon-projet",
};
```

**2. Ajouter une ligne dans `vercel.json`** :
```json
{
  "source": "/mon-projet/:path*",
  "destination": "https://<projet>-youssef-ait-elourfs-projects.vercel.app/mon-projet/:path*"
}
```

**3. Ouvrir une PR `dev → main`** — CI valide le JSON, merge déclenche le déploiement du site.

C'est tout. Le domaine `youssef-aitelourf.com` est lié uniquement à ce projet.

## Projets actifs

| Route | Repo | URL Vercel |
|-------|------|------------|
| `/portfolio` | [portfolio-2](https://github.com/youssef-aitelourf/portfolio-2) | `portfolio-2-youssef-ait-elourfs-projects.vercel.app` |

CV Adapter (`/cv-adapter`, `/admin/cv-adapter`) est **désactivé** — les requêtes sont redirigées vers `/portfolio` ou `/admin`.

## Structure

```
site/
├── vercel.json          ← rewrites + redirect racine
├── .github/workflows/
│   └── ci.yml           ← valide vercel.json sur chaque PR
└── README.md
```

## Branches

- `main` → Production Vercel (domaine `youssef-aitelourf.com`)
- `dev` → Preview Vercel
- Toute modification passe par une PR `dev → main` (CI obligatoire avant merge)
