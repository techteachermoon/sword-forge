-- 같이 하기 인원별(2인~6인) 무한 도전 랭킹 표. Supabase → SQL Editor에 붙여 넣고 Run (한 번만)
-- 사람마다 인원수별로 한 줄(그 인원으로 오른 최고 층). 실행 전에는 2인~6인 탭이 비어 있다고만 나오고 게임은 그대로 된다.

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

create table if not exists public.party (
  id uuid not null default auth.uid() references auth.users on delete cascade,
  size int not null check (size between 2 and 6),
  room text not null default '' check (char_length(room) <= 12),
  name text not null check (char_length(name) between 1 and 8),
  title text not null default '' check (char_length(title) <= 16),
  es bigint not null default 0 check (es >= 0),
  et int not null default 0 check (et >= 0),
  ed int not null default 0 check (ed between 0 and 100000),
  ew text not null default '' check (char_length(ew) <= 24),
  pw text not null default '' check (char_length(pw) <= 60),
  updated_at timestamptz not null default now(),
  primary key (id, size)
);
create index if not exists party_size_rank on public.party (size, ed desc, es desc);

grant usage on schema public to anon, authenticated;
grant select on public.party to anon, authenticated;
grant insert, update on public.party to authenticated;

alter table public.party enable row level security;
drop policy if exists "party read" on public.party;
create policy "party read" on public.party for select using (true);
drop policy if exists "party insert own" on public.party;
create policy "party insert own" on public.party for insert with check (auth.uid() = id and public.from_official_site());
drop policy if exists "party update own" on public.party;
create policy "party update own" on public.party for update using (auth.uid() = id) with check (auth.uid() = id and public.from_official_site());
