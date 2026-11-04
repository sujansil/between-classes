# Between Classes — clean replacement (GitHub Pages + Supabase)

A private, editable weekly planner for classes, self-study, Pioneers, hobbies, meals and downtime. Responsive dark interface, email/password login, cloud sync, 77 starter blocks, daily rotating note, weekly completion tracking, export. No Python, Docker, Azure or server hosting.

## Update your existing repository (IMPORTANT)

**Keep the existing `config.js`** in the root of your repository. It has your Supabase URL and public publishable/anon key. This ZIP deliberately contains `config.example.js` instead of `config.js` so you can replace the app without losing your configuration.

1. Make a backup of the current repo folder if you want. Unzip this archive.
2. Copy `index.html`, `app.js`, `style.css`, `schema.sql`, `seed.sql`, and optionally `README.md` over the files with the same names in the GitHub repo. **Do not copy an old `daily-note.js` script tag into `index.html`**; the note logic is already in `app.js`.
3. Leave `config.js` exactly as it was. If it no longer exists, copy `config.example.js` to `config.js` and enter your real Supabase URL and **publishable** key (never a service-role or secret key).
4. If your Supabase project was configured using the earlier complete `schema.sql`, no database setup change is needed. If the 77 blocks don't appear on your first login, run `schema.sql` once in Supabase SQL Editor (it is intended to be safe to re-run) or run the provided `seed.sql` after setting your login email. **Do not run `seed.sql` if you already have blocks you want to keep**; it deliberately skips nonempty schedules.
5. Commit and push:

```bash
git add -A
git commit -m "Restore complete planner with schedule and daily notes"
git push
```

6. Enable GitHub Pages: repository Settings → Pages → Deploy from branch → `main` / `(root)`. Visit `https://YOUR_USERNAME.github.io/between-classes/`. Hard refresh once if an old page is cached.

## First login

Create your account in Supabase Dashboard → Authentication → Users → Add user. The website is intentionally login-only (no public signup). Log in using that email and password. The database function `initialize_my_planner` populates the 77 starting blocks **once per account**, if empty. It never automatically restores intentionally deleted blocks afterward.

## Editing

Click **any** card, including classes, to edit its title, day, time or category. You can delete it. Click `+ Add block` to create one. Mark non-class blocks complete for the current week. Daily note rotates by local calendar date.

## Security and storage

Supabase Auth plus row-level security (RLS) policies restrict planner blocks by user ID. The URL and publishable key are public by design; never put passwords, API secret keys, or a service-role key in Git. Supabase free-tier projects can pause after inactivity. Export your schedule periodically.

## When something goes wrong

The login page now stays visible instead of rendering a completely blank page if a remote JavaScript module cannot load. Check the message on the login page and the browser Console (F12). Confirm `config.js` exists and has named ES exports `SUPABASE_URL` and `SUPABASE_ANON_KEY`. The front end imports only `./config.js` and the Supabase SDK, and all UI files remain static.
