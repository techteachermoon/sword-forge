-- 강화 랭킹 「현재 보유」·「역대 검」: 검 한 자루마다 한 줄(+10 이상 도달한 검). 파괴·판매돼도 남는다.
-- Supabase → SQL Editor에 붙여 넣고 Run (한 번만). 실행 전에는 두 탭에 「저장소가 아직 없다」라고만 나오고 게임은 그대로 된다.

create or replace function public.from_official_site() returns boolean
language sql stable as $$
  select coalesce(current_setting('request.headers', true)::json->>'origin', '') in (
    'https://swordforge.pages.dev',
    'https://forgegame.pages.dev',
    'https://techteachermoon.github.io'
  )
  or coalesce(current_setting('request.headers', true)::json->>'origin', '') like 'https://%.swordforge.pages.dev'
  or coalesce(current_setting('request.headers', true)::json->>'origin', '') like 'https://%.forgegame.pages.dev'
$$;

create table if not exists public.swords (
  id text primary key check (char_length(id) between 8 and 40),
  uid uuid not null default auth.uid() references auth.users on delete cascade,
  room text not null default '' check (char_length(room) <= 12),
  name text not null check (char_length(name) between 1 and 8),
  title text not null default '' check (char_length(title) <= 16),
  wid text not null default '' check (char_length(wid) <= 24),
  peak int not null default 0 check (peak between 0 and 35),
  lv int not null default 0 check (lv between 0 and 35),
  fate text not null default 'alive' check (fate in ('alive', 'vault', 'broken', 'sold')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists swords_peak on public.swords (room, peak desc);
create index if not exists swords_alive on public.swords (fate, lv desc);

grant usage on schema public to anon, authenticated;
grant select on public.swords to anon, authenticated;
grant insert, update on public.swords to authenticated;

alter table public.swords enable row level security;
drop policy if exists "swords read" on public.swords;
create policy "swords read" on public.swords for select using (true);
drop policy if exists "swords insert own" on public.swords;
create policy "swords insert own" on public.swords for insert with check (auth.uid() = uid and public.from_official_site());
drop policy if exists "swords update own" on public.swords;
create policy "swords update own" on public.swords for update using (auth.uid() = uid) with check (auth.uid() = uid and public.from_official_site());
