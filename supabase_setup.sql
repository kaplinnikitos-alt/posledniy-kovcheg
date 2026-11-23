-- Ковчег: минимальная схема комнат ожидания для Supabase
create extension if not exists pgcrypto;

create table if not exists public.kovcheg_rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (char_length(code)=5),
  host_name text not null,
  ark_title text not null,
  max_players int not null check (max_players between 6 and 30),
  target_days int not null check (target_days between 4 and 10),
  status text not null default 'waiting' check (status in ('waiting','started')),
  created_at timestamptz not null default now()
);

create table if not exists public.kovcheg_players (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.kovcheg_rooms(id) on delete cascade,
  player_id uuid not null,
  player_name text not null,
  gender text not null default 'male' check (gender in ('male','female')),
  archetype text not null default 'pragmatist' check (archetype in ('pragmatist','observer','adventurer')),
  is_host boolean not null default false,
  is_ready boolean not null default false,
  created_at timestamptz not null default now(),
  unique(room_id, player_id)
);

alter table public.kovcheg_rooms enable row level security;
alter table public.kovcheg_players enable row level security;

-- Простые политики для тестовой игры с друзьями.
-- Перед публичным коммерческим запуском их нужно заменить проверками через серверные функции.
create policy "rooms read for anon" on public.kovcheg_rooms for select to anon, authenticated using (true);
create policy "rooms create for anon" on public.kovcheg_rooms for insert to anon, authenticated with check (true);
create policy "rooms update for anon" on public.kovcheg_rooms for update to anon, authenticated using (true) with check (true);

create policy "players read for anon" on public.kovcheg_players for select to anon, authenticated using (true);
create policy "players create for anon" on public.kovcheg_players for insert to anon, authenticated with check (true);
create policy "players update for anon" on public.kovcheg_players for update to anon, authenticated using (true) with check (true);
create policy "players delete for anon" on public.kovcheg_players for delete to anon, authenticated using (true);

alter publication supabase_realtime add table public.kovcheg_rooms;
alter publication supabase_realtime add table public.kovcheg_players;
