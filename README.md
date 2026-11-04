# Between Classes ☘️

A simple, private weekly planner for academics, Pioneers, hobbies and life beyond deadlines.

**Stack:** HTML + CSS + browser JavaScript + Supabase Auth/Postgres. No Python, Docker, Azure VM, or build pipeline. Static hosting on GitHub Pages.

## What you get

- Full weekly timetable, day view, focus/progress view
- **Every block is editable**, including classes; add, edit, delete, complete
- Personal timetable starter template (click to load on first sign-in)
- Progress completion resets each Monday (the history of completion isn't retained)
- Email/password login; cloud sync across devices; JSON backup export
- Owner-only database access using PostgreSQL Row Level Security

## One-time setup (about six steps)

1. Create a [Supabase](https://supabase.com/) project. Wait until its database is ready.
2. In **SQL Editor**, paste and run [`schema.sql`](./schema.sql).
3. In **Authentication → Users**, create your own user with your email and a strong password (use the dashboard's **Add user** option). You can disable public signups in **Authentication → Providers → Email** if you're the only user. The exact location of this setting may vary as Supabase changes its dashboard.
4. In **Project Settings / Connect → API**, copy the **Project URL** and **publishable/anon key** into `config.js`. **Never** copy the `service_role` or secret key. The publishable key is designed for browser use; RLS protects the data.
5. Push the files to your GitHub repository. In **Settings → Pages**, select **Deploy from a branch** → `main` → `/ (root)` → **Save**. GitHub will show your `https://USERNAME.github.io/REPO/` URL.
6. Open the website, sign in with your Supabase email/password, click **Load my starter timetable**. Each block can be clicked to edit or delete.

**Note:** If your repo currently contains the earlier Python version, replace its old files with this repository's contents. The new website does not use `server.py`, `static/`, `Dockerfile`, or `compose.yaml`.

### Local preview

Static ES modules need an HTTP origin (not `file://`):

```bash
python -m http.server 8000
```

Open http://localhost:8000. Python here is *only* a convenient local static-file server, not an app backend.

## Security and limitations

- `config.js` is public by design. Your password is **never** put in the repo.
- RLS policies restrict CRUD to the owner of each row. Never use Supabase service-role or secret keys in a browser.
- Configure Supabase Auth allowed/site URLs to match your GitHub Pages URL if you enable password recovery or email links. For manual password login, create the account in the Supabase dashboard first.
- Static hosting remains free subject to GitHub Pages policies. Supabase free tiers have usage caps and may pause inactive projects; this is **not** guaranteed permanent free hosting/storage.
- Completion toggles reset each Monday. Schedule entries recur weekly; they aren't dated calendar events.
- New users initially see an empty schedule; starter blocks load only when you click the button so deleting all blocks won't trigger accidental reseeding.
- Export JSON regularly. This starter does not implement JSON import or multi-user shared schedules.

## Deploy subsequent changes

```bash
git add .
git commit -m 'Update planner'
git push
```

GitHub Pages deploys the latest branch automatically.
