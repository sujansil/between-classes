# Between Classes — manual seeding + daily message update

The planner now has a **one-time standalone `seed.sql`** and a rotating motivational note in the bottom card (and sidebar). No need to replace the entire website or rerun schema whenever you want to seed a timetable.

## If you already have the website online

1. Run `schema.sql` **only if you haven't set up the tables yet**.
2. In Supabase **Authentication → Users**, verify your account exists.
3. In Supabase **SQL Editor**, open `seed.sql`, replace `REPLACE_WITH_YOUR_LOGIN_EMAIL` with your actual login email, then run it **once**.
4. Refresh the website. The 77 class, study, Pioneers, hobby, meal, and free-time blocks appear in your timetable. You can edit or delete every block.

**Safety:** `seed.sql` only inserts into an **empty** timetable. If you already have blocks, it skips rather than overwrite, duplicate, or delete anything. Editing and deleting blocks afterwards does not trigger reseeding. If you need to merge defaults into an existing custom timetable, don't delete your data; do it manually or ask for a merge script.

## Change the rotating message

Replace only `app.js` and `index.html` in your existing repository, then:

```bash
git add app.js index.html
git commit -m "Add a daily rotating note"
git push
```

The bottom "A note to self" card shows a different original message each **local calendar day** (14-message rotation). The sidebar quote changes too. Quotes don't change every refresh. No database tables, cron jobs, keys, or API calls are needed.

## Existing project setup

Static HTML, CSS and JS + Supabase authentication and Postgres. `config.js` should retain **your existing** project URL and public publishable key; don't overwrite it when applying this patch. `schema.sql` remains available for a *new* project. The old optional in-app "Restore the sample schedule" button remains available when the timetable is empty.

For the existing Supabase project, no table migrations are needed merely to rotate messages or run `seed.sql`.
