-- Run this once in your Supabase project's SQL Editor.
-- Only authenticated users can touch their own blocks.
create table if not exists public.planner_blocks (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  day smallint not null check (day between 0 and 6),
  start_time time not null,
  end_time time not null,
  title text not null check (char_length(trim(title)) between 1 and 90),
  category text not null check (category in ('class','study','pio','hobby','rest','free')),
  completed_week date,
  created_at timestamptz not null default now(),
  constraint time_order check (end_time > start_time)
);
create index if not exists planner_blocks_user_day_idx on public.planner_blocks(user_id,day,start_time);
alter table public.planner_blocks enable row level security;
revoke all on public.planner_blocks from anon, authenticated;
grant select,insert,update,delete on public.planner_blocks to authenticated;
-- To support identity columns on older/grant-constrained projects:
grant usage, select on sequence public.planner_blocks_id_seq to authenticated;
drop policy if exists "read own blocks" on public.planner_blocks;
drop policy if exists "create own blocks" on public.planner_blocks;
drop policy if exists "edit own blocks" on public.planner_blocks;
drop policy if exists "delete own blocks" on public.planner_blocks;
create policy "read own blocks" on public.planner_blocks for select to authenticated using (user_id = (select auth.uid()));
create policy "create own blocks" on public.planner_blocks for insert to authenticated with check (user_id = (select auth.uid()));
create policy "edit own blocks" on public.planner_blocks for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "delete own blocks" on public.planner_blocks for delete to authenticated using (user_id = (select auth.uid()));

-- Automatic once-per-user starter timetable. Safe to run again on an existing project.
-- Seed status is separate from planner_blocks so deleting all blocks never repopulates them.
create table if not exists public.planner_initializations (
  user_id uuid primary key references auth.users(id) on delete cascade,
  initialized_at timestamptz not null default now()
);
alter table public.planner_initializations enable row level security;
revoke all on public.planner_initializations from anon, authenticated;

create or replace function public.initialize_my_planner()
returns boolean
language plpgsql
security definer
set search_path = ''
as $func$
declare
  uid uuid := auth.uid();
  inserted_count integer := 0;
begin
  if uid is null then
    raise exception 'Authentication required';
  end if;
  -- A unique row serializes concurrent first logins across different devices.
  insert into public.planner_initializations (user_id) values (uid)
    on conflict (user_id) do nothing;
  get diagnostics inserted_count = row_count;
  if inserted_count = 0 then
    return false;
  end if;
  -- Protect an account that already created or imported a custom schedule.
  if exists (select 1 from public.planner_blocks where user_id = uid) then
    return false;
  end if;
  insert into public.planner_blocks (user_id, day, start_time, end_time, title, category)
  select uid, v.day, v.start_time::time, v.end_time::time, v.title, v.category
  from jsonb_to_recordset($seed$[{"day":0,"start_time":"09:15","end_time":"10:45","title":"Digital Design","category":"class"},{"day":0,"start_time":"11:00","end_time":"12:30","title":"Calculus","category":"class"},{"day":0,"start_time":"14:00","end_time":"15:30","title":"Linear Algebra","category":"class"},{"day":1,"start_time":"09:15","end_time":"10:45","title":"C Programming","category":"class"},{"day":1,"start_time":"11:00","end_time":"12:30","title":"Economics","category":"class"},{"day":1,"start_time":"14:00","end_time":"15:30","title":"Calculus","category":"class"},{"day":1,"start_time":"15:45","end_time":"17:15","title":"Physical Education","category":"class"},{"day":2,"start_time":"09:15","end_time":"10:45","title":"Digital Design","category":"class"},{"day":2,"start_time":"14:00","end_time":"15:30","title":"Linear Algebra","category":"class"},{"day":2,"start_time":"16:30","end_time":"18:00","title":"Linear Algebra Tutorial","category":"class"},{"day":3,"start_time":"14:00","end_time":"15:30","title":"Python Programming","category":"class"},{"day":3,"start_time":"15:45","end_time":"17:15","title":"Physical Education","category":"class"},{"day":4,"start_time":"11:00","end_time":"12:30","title":"Calculus Tutorial","category":"class"},{"day":4,"start_time":"14:00","end_time":"15:30","title":"Digital Design Tutorial","category":"class"},{"day":4,"start_time":"15:45","end_time":"17:15","title":"Physical Education","category":"class"},{"day":5,"start_time":"09:00","end_time":"10:30","title":"Physical Education (TT)","category":"class"},{"day":5,"start_time":"11:00","end_time":"12:30","title":"C Programming","category":"class"},{"day":5,"start_time":"14:00","end_time":"15:30","title":"Python Programming","category":"class"},{"day":0,"start_time":"16:30","end_time":"18:00","title":"Calculus / Linear Algebra review","category":"study"},{"day":0,"start_time":"18:00","end_time":"19:00","title":"Codeforces — practice","category":"hobby"},{"day":0,"start_time":"20:00","end_time":"21:00","title":"Digital Design self-study","category":"study"},{"day":0,"start_time":"21:00","end_time":"22:00","title":"Unsolved Monday — publish / coordinate","category":"pio"},{"day":1,"start_time":"18:00","end_time":"19:30","title":"Programming / assignments","category":"study"},{"day":1,"start_time":"20:30","end_time":"21:30","title":"Economics / Calculus review","category":"study"},{"day":2,"start_time":"11:00","end_time":"12:30","title":"Digital Design / pending work","category":"study"},{"day":2,"start_time":"19:00","end_time":"20:00","title":"Linear Algebra recap","category":"study"},{"day":2,"start_time":"20:00","end_time":"21:30","title":"Codeforces — practice","category":"hobby"},{"day":3,"start_time":"09:30","end_time":"11:00","title":"Deep work / assignments","category":"study"},{"day":3,"start_time":"11:00","end_time":"12:30","title":"Pioneers — research / production","category":"pio"},{"day":3,"start_time":"18:15","end_time":"19:15","title":"Python revision","category":"study"},{"day":3,"start_time":"20:15","end_time":"21:45","title":"Codeforces / try a new hobby","category":"hobby"},{"day":4,"start_time":"09:30","end_time":"10:30","title":"Tutorial prep","category":"study"},{"day":4,"start_time":"18:15","end_time":"19:45","title":"Assignments / revision","category":"study"},{"day":4,"start_time":"20:45","end_time":"21:45","title":"Pioneers — close submissions / review","category":"pio"},{"day":5,"start_time":"16:30","end_time":"18:00","title":"Weekly academic backlog","category":"study"},{"day":5,"start_time":"18:00","end_time":"19:00","title":"Pioneers — solution handoff","category":"pio"},{"day":5,"start_time":"20:00","end_time":"21:00","title":"Weekly revision","category":"study"},{"day":6,"start_time":"10:00","end_time":"11:30","title":"Focused academic catch-up","category":"study"},{"day":6,"start_time":"11:30","end_time":"13:00","title":"Pioneers — prepare / review","category":"pio"},{"day":6,"start_time":"14:30","end_time":"16:00","title":"Codeforces / new hobby","category":"hobby"},{"day":6,"start_time":"18:00","end_time":"19:00","title":"Upcoming-week academic prep","category":"study"},{"day":0,"start_time":"08:00","end_time":"09:00","title":"Breakfast and morning routine","category":"rest"},{"day":0,"start_time":"12:30","end_time":"14:00","title":"Lunch and downtime","category":"rest"},{"day":0,"start_time":"15:30","end_time":"16:30","title":"Rest / friends / snack","category":"rest"},{"day":0,"start_time":"19:00","end_time":"20:00","title":"Dinner and break","category":"rest"},{"day":0,"start_time":"22:00","end_time":"23:30","title":"Free time / winding down","category":"free"},{"day":1,"start_time":"08:00","end_time":"09:00","title":"Breakfast and morning routine","category":"rest"},{"day":1,"start_time":"12:30","end_time":"14:00","title":"Lunch and downtime","category":"rest"},{"day":1,"start_time":"17:15","end_time":"18:00","title":"Recovery and snack","category":"rest"},{"day":1,"start_time":"19:30","end_time":"20:30","title":"Dinner and break","category":"rest"},{"day":1,"start_time":"21:30","end_time":"23:30","title":"Friends / entertainment / free time","category":"free"},{"day":2,"start_time":"08:00","end_time":"09:00","title":"Breakfast and morning routine","category":"rest"},{"day":2,"start_time":"12:30","end_time":"14:00","title":"Lunch and downtime","category":"rest"},{"day":2,"start_time":"15:30","end_time":"16:30","title":"Rest and snack","category":"rest"},{"day":2,"start_time":"18:00","end_time":"19:00","title":"Dinner and recovery","category":"rest"},{"day":2,"start_time":"21:30","end_time":"23:30","title":"Free time","category":"free"},{"day":3,"start_time":"08:30","end_time":"09:30","title":"Breakfast and easy morning","category":"rest"},{"day":3,"start_time":"12:30","end_time":"14:00","title":"Lunch and downtime","category":"rest"},{"day":3,"start_time":"17:15","end_time":"18:15","title":"Rest and snack","category":"rest"},{"day":3,"start_time":"19:15","end_time":"20:15","title":"Dinner","category":"rest"},{"day":3,"start_time":"21:45","end_time":"23:30","title":"Free time","category":"free"},{"day":4,"start_time":"08:30","end_time":"09:30","title":"Breakfast and morning routine","category":"rest"},{"day":4,"start_time":"12:30","end_time":"14:00","title":"Lunch and downtime","category":"rest"},{"day":4,"start_time":"17:15","end_time":"18:15","title":"Recovery and break","category":"rest"},{"day":4,"start_time":"19:45","end_time":"20:45","title":"Dinner","category":"rest"},{"day":4,"start_time":"21:45","end_time":"23:30","title":"Social evening / free time","category":"free"},{"day":5,"start_time":"08:00","end_time":"08:45","title":"Breakfast and routine","category":"rest"},{"day":5,"start_time":"12:30","end_time":"14:00","title":"Lunch and downtime","category":"rest"},{"day":5,"start_time":"15:30","end_time":"16:30","title":"Rest and snack","category":"rest"},{"day":5,"start_time":"19:00","end_time":"20:00","title":"Dinner and break","category":"rest"},{"day":5,"start_time":"21:00","end_time":"23:30","title":"Friends / games / free time","category":"free"},{"day":6,"start_time":"09:00","end_time":"10:00","title":"Relaxed breakfast","category":"rest"},{"day":6,"start_time":"13:00","end_time":"14:30","title":"Lunch and downtime","category":"rest"},{"day":6,"start_time":"16:00","end_time":"18:00","title":"Unstructured free time / outing","category":"free"},{"day":6,"start_time":"19:00","end_time":"20:00","title":"Dinner","category":"rest"},{"day":6,"start_time":"20:00","end_time":"21:00","title":"Optional Pioneers prep / handoff","category":"pio"},{"day":6,"start_time":"21:00","end_time":"23:30","title":"Rest and friends","category":"free"}]$seed$::jsonb)
    as v(day smallint, start_time text, end_time text, title text, category text);
  return true;
end;
$func$;
revoke all on function public.initialize_my_planner() from public, anon;
grant execute on function public.initialize_my_planner() to authenticated;
