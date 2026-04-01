-- Enable Row Level Security (RLS) for the profiles table
alter table profiles enable row level security;

-- Allow users to insert their own profile
drop policy if exists "Allow users to insert their own profile" on profiles;
create policy "Allow users to insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

-- Allow users to select (read) their own profile
drop policy if exists "Allow users to select their own profile" on profiles;
create policy "Allow users to select their own profile"
  on profiles for select
  using (auth.uid() = id);

-- Allow users to update their own profile
drop policy if exists "Allow users to update their own profile" on profiles;
create policy "Allow users to update their own profile"
  on profiles for update
  using (auth.uid() = id);

-- (Optional) Allow users to delete their own profile
drop policy if exists "Allow users to delete their own profile" on profiles;
create policy "Allow users to delete their own profile"
  on profiles for delete
  using (auth.uid() = id);

-- Enable Row Level Security (RLS) for the yuva_shakthi_members table
alter table yuva_shakthi_members enable row level security;

-- Allow authenticated users to insert into yuva_shakthi_members
drop policy if exists "Allow insert for authenticated users" on yuva_shakthi_members;
create policy "Allow insert for authenticated users"
  on yuva_shakthi_members for insert
  with check (auth.uid() = user_id);

-- Enable Row Level Security (RLS) for the complaints table
alter table complaints enable row level security;

-- Allow authenticated users to insert into complaints
drop policy if exists "Allow insert for authenticated users" on complaints;
create policy "Allow insert for authenticated users"
  on complaints for insert
  with check (auth.uid() = user_id);

-- Enable Row Level Security (RLS) for the scheme_eligibility table
alter table scheme_eligibility enable row level security;

-- Allow authenticated users to insert into scheme_eligibility
drop policy if exists "Allow insert for authenticated users" on scheme_eligibility;
create policy "Allow insert for authenticated users"
  on scheme_eligibility for insert
  with check (auth.uid() = user_id);

-- Enable Row Level Security (RLS) for the volunteers table
alter table volunteers enable row level security;

-- Allow authenticated users to insert into volunteers
drop policy if exists "Allow insert for authenticated users" on volunteers;
create policy "Allow insert for authenticated users"
  on volunteers for insert
  with check (auth.uid() = user_id);

-- Enable Row Level Security (RLS) for the grievances table
alter table grievances enable row level security;

-- Allow authenticated users to insert into grievances
drop policy if exists "Allow insert for authenticated users" on grievances;
create policy "Allow insert for authenticated users"
  on grievances for insert
  with check (auth.uid() = user_id);

-- Enable Row Level Security (RLS) for the mahila_shakti_grievances table
alter table mahila_shakti_grievances enable row level security;

-- Allow authenticated users to insert into mahila_shakti_grievances
drop policy if exists "Allow insert for authenticated users" on mahila_shakti_grievances;
create policy "Allow insert for authenticated users"
on mahila_shakti_grievances
for insert
with check (auth.uid() = user_id);

--Enable Row Level Security (RLS) for the social_media_grievances table
alter table social_media_grievances enable row level security;

-- Allow authenticated users to insert into social_media_grievances
drop policy if exists "Allow insert for authenticated users" on social_media_grievances;
create policy "Allow insert for authenticated users"
on social_media_grievances
for insert
with check (auth.uid() = user_id);

drop policy if exists "Admins can select all profiles" on profiles;

-- NOTE:
-- The previous admin policy queried `profiles` from inside a policy on `profiles`,
-- which can cause infinite recursion in Postgres RLS evaluation.
-- This non-recursive policy allows authenticated users to read profiles.
drop policy if exists "Allow authenticated users to select profiles" on profiles;
create policy "Allow authenticated users to select profiles"
  on profiles for select
  using (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- Unified policies for public form submissions + admin panel visibility
-- ---------------------------------------------------------------------------
-- Why this block exists:
-- 1) Public site forms are intended to work even without login.
-- 2) Admin panel uses authenticated users and must be able to read/manage rows.
--
-- It creates (or recreates) policies for all form tables so that:
-- - anon + authenticated can INSERT (public intake)
-- - authenticated can SELECT/UPDATE/DELETE (admin panel operations)
do $$
declare
  t text;
  form_tables text[] := array[
    'yuva_shakthi_members',
    'complaints',
    'scheme_eligibility',
    'volunteers',
    'grievances',
    'mahila_shakti_grievances',
    'mahila_shakti_registrations',
    'citizen_feedback',
    'social_media_grievances'
  ];
begin
  foreach t in array form_tables loop
    execute format('alter table if exists public.%I enable row level security', t);

    execute format('drop policy if exists %I on public.%I', 'Public can insert records', t);
    execute format(
      'create policy %I on public.%I for insert to anon, authenticated with check (true)',
      'Public can insert records',
      t
    );

    execute format('drop policy if exists %I on public.%I', 'Authenticated can read records', t);
    execute format(
      'create policy %I on public.%I for select to authenticated using (true)',
      'Authenticated can read records',
      t
    );

    execute format('drop policy if exists %I on public.%I', 'Authenticated can update records', t);
    execute format(
      'create policy %I on public.%I for update to authenticated using (true) with check (true)',
      'Authenticated can update records',
      t
    );

    execute format('drop policy if exists %I on public.%I', 'Authenticated can delete records', t);
    execute format(
      'create policy %I on public.%I for delete to authenticated using (true)',
      'Authenticated can delete records',
      t
    );
  end loop;
end
$$;