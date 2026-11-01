-- =============================================================================
-- Migration: 20261101000000_create_schema.sql
-- Project: CreateIQ
-- Purpose: Schema setup for Profiles, Content Ideas, Content Drafts,
--          and Analytics Data with strict Row Level Security (RLS).
-- =============================================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. Profiles Table
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    name text not null,
    email text not null,
    niche text default 'Other',
    bio text default '',
    avatar_url text,
    questionnaire jsonb default '{}'::jsonb,
    connected_accounts jsonb default '[]'::jsonb,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);

-- -----------------------------------------------------------------------------
-- 2. Content Ideas Table (AI Generated & Saved Content)
-- -----------------------------------------------------------------------------
create table if not exists public.content_ideas (
    id text primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    type text not null check (type in ('postIdea', 'caption', 'hashtags', 'calendar')),
    title text not null,
    body text not null,
    tags text[] default '{}'::text[],
    weekday integer check (weekday >= 0 and weekday <= 6),
    suggested_time text,
    is_saved boolean default false not null,
    created_at timestamptz default now() not null
);

-- Index for querying ideas by user and save status
create index if not exists idx_content_ideas_user_id on public.content_ideas(user_id);
create index if not exists idx_content_ideas_user_saved on public.content_ideas(user_id, is_saved);

-- -----------------------------------------------------------------------------
-- 3. Content Drafts / Manual Posts Table
-- -----------------------------------------------------------------------------
create table if not exists public.content_drafts (
    id text primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    platform text not null check (platform in ('instagram', 'tiktok', 'youtube', 'facebook', 'x')),
    type text not null check (type in ('image', 'video', 'reel', 'story')),
    caption text default '',
    image_path text,
    likes integer default 0 not null,
    comments integer default 0 not null,
    shares integer default 0 not null,
    views integer default 0 not null,
    saves integer default 0 not null,
    followers_gained integer default 0 not null,
    followers_at_post integer default 10000 not null,
    is_manual boolean default true not null,
    post_date timestamptz default now() not null,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null
);

create index if not exists idx_content_drafts_user_date on public.content_drafts(user_id, post_date desc);

-- -----------------------------------------------------------------------------
-- 4. Analytics Data Table
-- -----------------------------------------------------------------------------
create table if not exists public.analytics_data (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    platform text not null check (platform in ('instagram', 'tiktok', 'youtube', 'facebook', 'x')),
    metric_date date not null,
    followers integer default 0 not null,
    likes integer default 0 not null,
    comments integer default 0 not null,
    shares integer default 0 not null,
    saves integer default 0 not null,
    views integer default 0 not null,
    is_demo boolean default true not null,
    created_at timestamptz default now() not null,
    unique(user_id, platform, metric_date, is_demo)
);

create index if not exists idx_analytics_data_user on public.analytics_data(user_id, metric_date);

-- -----------------------------------------------------------------------------
-- 5. Row Level Security (RLS) Policies
-- -----------------------------------------------------------------------------

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.content_ideas enable row level security;
alter table public.content_drafts enable row level security;
alter table public.analytics_data enable row level security;

-- Profiles Policies
create policy "Users can view their own profile"
    on public.profiles for select
    using (auth.uid() = id);

create policy "Users can update their own profile"
    on public.profiles for update
    using (auth.uid() = id);

create policy "Users can insert their own profile"
    on public.profiles for insert
    with check (auth.uid() = id);

-- Content Ideas Policies
create policy "Users can select their own ideas"
    on public.content_ideas for select
    using (auth.uid() = user_id);

create policy "Users can insert their own ideas"
    on public.content_ideas for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own ideas"
    on public.content_ideas for update
    using (auth.uid() = user_id);

create policy "Users can delete their own ideas"
    on public.content_ideas for delete
    using (auth.uid() = user_id);

-- Content Drafts Policies
create policy "Users can select their own drafts"
    on public.content_drafts for select
    using (auth.uid() = user_id);

create policy "Users can insert their own drafts"
    on public.content_drafts for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own drafts"
    on public.content_drafts for update
    using (auth.uid() = user_id);

create policy "Users can delete their own drafts"
    on public.content_drafts for delete
    using (auth.uid() = user_id);

-- Analytics Data Policies
create policy "Users can select their own analytics data"
    on public.analytics_data for select
    using (auth.uid() = user_id);

create policy "Users can insert their own analytics data"
    on public.analytics_data for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own analytics data"
    on public.analytics_data for update
    using (auth.uid() = user_id);

create policy "Users can delete their own analytics data"
    on public.analytics_data for delete
    using (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
-- 6. Trigger to automatically create profile on Auth Signup
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
    insert into public.profiles (id, email, name, niche, bio)
    values (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
        coalesce(new.raw_user_meta_data->>'niche', 'Other'),
        coalesce(new.raw_user_meta_data->>'bio', '')
    )
    on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- -----------------------------------------------------------------------------
-- 7. Updated At Trigger Function
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger tr_profiles_updated_at
    before update on public.profiles
    for each row execute function public.set_updated_at();

create trigger tr_content_drafts_updated_at
    before update on public.content_drafts
    for each row execute function public.set_updated_at();

