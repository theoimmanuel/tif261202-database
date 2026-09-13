-- ============================================================
-- Call Sheet — Supabase schema
-- Run this once in your project's SQL editor
-- (Supabase Dashboard → SQL Editor → New query → paste → Run)
-- ============================================================

create extension if not exists "uuid-ossp";

-- The presenter queue, in order.
create table if not exists queue (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  position integer not null,
  notify_email text,
  notified boolean not null default false,
  created_at timestamptz not null default now()
);

-- A single row holding the shared timer state, so every
-- connected screen shows the same countdown.
create table if not exists timer_state (
  id integer primary key default 1,
  duration_seconds integer not null default 180,
  remaining_seconds integer not null default 180,
  running boolean not null default false,
  ends_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);

insert into timer_state (id) values (1)
  on conflict (id) do nothing;

-- ---- Row Level Security ----
alter table queue enable row level security;
alter table timer_state enable row level security;

-- Anyone can read (this is what a public "on now / on deck" screen needs).
create policy "Public read queue" on queue
  for select using (true);

create policy "Public read timer" on timer_state
  for select using (true);

-- Only signed-in admins can add, edit, or remove.
create policy "Admins write queue" on queue
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Admins write timer" on timer_state
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- ---- Realtime ----
-- Lets every open browser tab receive live updates.
alter publication supabase_realtime add table queue;
alter publication supabase_realtime add table timer_state;

-- ---- Advance-the-queue function ----
-- Any connected client calls this once its local clock sees the
-- countdown hit zero. It re-checks the real end time server-side
-- before doing anything, so it's safe even if several clients call
-- it at once.
create or replace function advance_queue()
returns void
language plpgsql
security definer
as $$
declare
  ts_row timer_state%rowtype;
  first_id uuid;
begin
  select * into ts_row from timer_state where id = 1 for update;

  if ts_row.running and ts_row.ends_at is not null and ts_row.ends_at <= now() then
    select id into first_id from queue order by position asc limit 1;

    if first_id is not null then
      delete from queue where id = first_id;
      update queue set position = position - 1 where position > 1;
    end if;

    if exists (select 1 from queue) then
      update timer_state set
        remaining_seconds = duration_seconds,
        ends_at = now() + (duration_seconds || ' seconds')::interval,
        running = true,
        updated_at = now()
      where id = 1;
    else
      update timer_state set
        remaining_seconds = duration_seconds,
        ends_at = null,
        running = false,
        updated_at = now()
      where id = 1;
    end if;
  end if;
end;
$$;

grant execute on function advance_queue() to anon, authenticated;
