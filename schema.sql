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
