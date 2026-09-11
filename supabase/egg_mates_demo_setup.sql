-- Egg Mates browser-only demo setup.
-- Paste ONLY this file's contents into Supabase SQL Editor, then click Run.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key,
  username text unique not null,
  full_name text not null,
  bio text not null,
  avatar_url text,
  created_at timestamptz default now()
);
create table if not exists public.codes (
  code text primary key,
  user_id1 uuid not null references public.profiles(id),
  user_id2 uuid references public.profiles(id),
  status text not null default 'waiting',
  chat_id uuid unique,
  created_at timestamptz default now()
);
create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  code text unique not null references public.codes(code),
  created_at timestamptz default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null references public.profiles(id),
  body text not null,
  created_at timestamptz default now()
);

-- Lets browser-generated demo IDs be used instead of Supabase Auth user IDs.
alter table public.profiles drop constraint if exists profiles_id_fkey;

alter table public.profiles enable row level security;
alter table public.codes enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;

drop policy if exists "demo profiles select" on public.profiles;
drop policy if exists "demo profiles insert" on public.profiles;
drop policy if exists "demo profiles update" on public.profiles;
create policy "demo profiles select" on public.profiles for select to anon using (true);
create policy "demo profiles insert" on public.profiles for insert to anon with check (true);
create policy "demo profiles update" on public.profiles for update to anon using (true) with check (true);
drop policy if exists "demo codes select" on public.codes;
create policy "demo codes select" on public.codes for select to anon using (true);
drop policy if exists "demo chats select" on public.chats;
create policy "demo chats select" on public.chats for select to anon using (true);
drop policy if exists "demo messages select" on public.messages;
drop policy if exists "demo messages insert" on public.messages;
create policy "demo messages select" on public.messages for select to anon using (true);
create policy "demo messages insert" on public.messages for insert to anon with check (true);

grant usage on schema public to anon;
grant select, insert, update on public.profiles, public.messages to anon;
grant select on public.codes, public.chats to anon;

create or replace function public.claim_secret_code(entered_code text, claimant_id uuid)
returns table(result text, chat_id uuid, other_user_id uuid)
language plpgsql security definer set search_path = public as $$
declare current_code public.codes; new_chat uuid; normalized text := upper(trim(entered_code));
begin
  if not exists (select 1 from public.profiles where id = claimant_id) then raise exception 'Choose a profile first.'; end if;
  select * into current_code from public.codes where code = normalized for update;
  if not found then
    insert into public.codes(code, user_id1) values (normalized, claimant_id);
    return query select 'waiting'::text, null::uuid, null::uuid; return;
  end if;
  if current_code.status = 'matched' then return query select 'redeemed'::text, null::uuid, null::uuid; return; end if;
  if current_code.user_id1 = claimant_id then return query select 'own_code'::text, null::uuid, null::uuid; return; end if;
  insert into public.chats(code) values (normalized) returning id into new_chat;
  update public.codes set user_id2 = claimant_id, status = 'matched', chat_id = new_chat where code = normalized;
  return query select 'matched'::text, new_chat, current_code.user_id1;
end; $$;
grant execute on function public.claim_secret_code(text, uuid) to anon;

do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'codes') then
    alter publication supabase_realtime add table public.codes;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'messages') then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;
