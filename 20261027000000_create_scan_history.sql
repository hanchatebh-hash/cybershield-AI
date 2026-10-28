create table public.scan_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  content text not null check (char_length(content) between 1 and 5000),
  report jsonb not null check (jsonb_typeof(report) = 'object'),
  created_at timestamptz not null default now()
);

create index scan_history_user_created_at_idx
  on public.scan_history (user_id, created_at desc);

alter table public.scan_history enable row level security;

create policy "Users can read their own scan history"
  on public.scan_history
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can save scans to their own history"
  on public.scan_history
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
