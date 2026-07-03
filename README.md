# krayin-railway

Deploy [Krayin CRM](https://github.com/krayin/laravel-crm) (open-source, MIT) on
[Railway](https://railway.com) from this repo. Used as the CRM front-end for the
LeadGen engine — leads sourced/scored locally are pushed here via Krayin's REST API,
and you work them (calls, notes, activities, pipeline) in Krayin's UI.

## What this deploys

- **Image:** `webkul/krayin:2.2.0` — prebuilt Krayin (Nginx + PHP-FPM + Supervisord)
  with the **REST API bundled** (`/api/admin/documentation`).
- **Database:** the image's **internal MySQL**, which **self-seeds on first boot**
  (verified: empty datadir → 57 tables + admin user). No separate DB service needed.
- **Persistence:** a Railway **volume mounted at `/var/lib/mysql`** keeps all CRM
  data across redeploys. Without it, every redeploy wipes your leads and notes.

## Required config

| Variable  | Value                                              |
|-----------|----------------------------------------------------|
| `APP_URL` | Your Railway public domain, e.g. `https://<app>.up.railway.app` |
| `APP_KEY` | A Laravel key: `base64:` + 32 random bytes (see below) |

Generate an `APP_KEY`:

```bash
echo "base64:$(openssl rand -base64 32)"
```

Internal MySQL defaults (`DB_HOST=127.0.0.1`, `DB_DATABASE/USERNAME/PASSWORD=krayin`)
are baked in — leave them unset to use the bundled DB.

## Deploy (Railway CLI)

```bash
railway login                       # opens browser
railway init                        # create a new project
railway up                          # build + deploy this Dockerfile
railway volume add --mount-path /var/lib/mysql   # PERSISTENCE — do this before real use
railway variables --set "APP_KEY=base64:...=" --set "APP_URL=https://<app>.up.railway.app"
railway domain                      # generate the public URL, then set APP_URL to it and redeploy
```

## First login

- URL: your Railway domain → `/admin/login`
- Default admin: `admin@example.com` / `admin123` — **change the password immediately**
  (top-right profile → change password).

## REST API

- Swagger UI: `<APP_URL>/api/admin/documentation`
- Auth: Laravel Sanctum — log in for a bearer token, then create Persons/Leads.
- The LeadGen `sync` command (separate repo) pushes scored Dallas prospects here.

## Notes

- Krayin core + `krayin/rest-api` are MIT-licensed — no per-seat cost. Only your
  Railway infrastructure is billed.
- To upgrade Krayin, bump the tag in the `Dockerfile` and redeploy.
