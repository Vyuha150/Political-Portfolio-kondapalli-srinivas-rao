-- backend/supabase/schema.sql
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  mobile text,
  gender text,
  role text default 'citizen',
  created_at timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists yuva_shakthi_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  fullname text,
  parentname text,
  dob date,
  gender text,
  phone text,
  email text,
  address text,
  village text,
  mandal text,
  constituency text,
  district text,
  education text,
  stream text,
  occupation text,
  skills text,
  interests text[],
  interest_other text,
  why text,
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists complaints (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  full_name text,
  age integer,
  gender text,
  phone text,
  email text,
  address text,
  contact_mode text,
  problem_category text,
  constituency text,
  mandal_village text,
  location text,
  problem_description text,
  supporting_documents text,
  problem_date date,
  reported_before text,
  report_details text,
  specific_authority text,
  similar_issues text,
  similar_issues_details text,
  auth_name text,
  auth_phone text,
  auth_email text,
  leader_photo text,
  status text default 'Pending',
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists scheme_eligibility (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  fullname text,
  age integer,
  gender text,
  mobile text,
  aadhaar text,
  caste text,
  marital text,
  disability text,
  disability_details text,
  income text,
  education text,
  employment text,
  skill_training text,
  skill_training_details text,
  social_service text,
  social_service_details text,
  welfare_member text,
  schemes text,
  status text default 'Under Review',
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists volunteers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  name text,
  email text,
  phone text,
  constituency text,
  message text,
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists grievances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  fullname text,
  age integer,
  gender text,
  mobile text,
  email text,
  address text,
  caste text,
  aadhaar text,
  grievance text,
  grievance_other text,
  details text,
  attachments text[], -- store file URLs if you use Supabase Storage
  political_sensitive text,
  parties text,
  anonymous text,
  opponent_name text,
  opponent_phone text,
  opponent_details text,
  -- New fields added
  previous_complaint text,
  govt_department text,
  acknowledgement_url text,
  video_url text,
  district text,
  mandal text,
  village text,
  status text default 'open',
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create Mahila Shakti grievances table
create table if not exists mahila_shakti_grievances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  fullname text,
  age integer,
  gender text,
  mobile text,
  email text,
  district text,
  constituency text,
  mandal text,
  ward text,
  grievance_types text[],
  grievance_other text,
  description text,
  attachments text[],
  response_modes text[],
  volunteer text,
  declaration boolean default false,
  status text default 'Under Review',
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

-- Backfill columns for older existing tables (safe no-op if already present)
alter table if exists mahila_shakti_grievances add column if not exists user_id uuid references auth.users on delete set null;
alter table if exists mahila_shakti_grievances add column if not exists fullname text;
alter table if exists mahila_shakti_grievances add column if not exists age integer;
alter table if exists mahila_shakti_grievances add column if not exists gender text;
alter table if exists mahila_shakti_grievances add column if not exists mobile text;
alter table if exists mahila_shakti_grievances add column if not exists email text;
alter table if exists mahila_shakti_grievances add column if not exists district text;
alter table if exists mahila_shakti_grievances add column if not exists constituency text;
alter table if exists mahila_shakti_grievances add column if not exists mandal text;
alter table if exists mahila_shakti_grievances add column if not exists ward text;
alter table if exists mahila_shakti_grievances add column if not exists grievance_types text[];
alter table if exists mahila_shakti_grievances add column if not exists grievance_other text;
alter table if exists mahila_shakti_grievances add column if not exists description text;
alter table if exists mahila_shakti_grievances add column if not exists attachments text[];
alter table if exists mahila_shakti_grievances add column if not exists response_modes text[];
alter table if exists mahila_shakti_grievances add column if not exists volunteer text;
alter table if exists mahila_shakti_grievances add column if not exists declaration boolean default false;
alter table if exists mahila_shakti_grievances add column if not exists status text default 'Under Review';
alter table if exists mahila_shakti_grievances add column if not exists submitted_at timestamp with time zone default timezone('utc'::text, now());

-- Normalize legacy constraints to match current optional fields
alter table if exists mahila_shakti_grievances alter column age drop not null;
alter table if exists mahila_shakti_grievances alter column user_id drop not null;
alter table if exists mahila_shakti_grievances alter column fullname drop not null;
alter table if exists mahila_shakti_grievances alter column gender drop not null;
alter table if exists mahila_shakti_grievances alter column mobile drop not null;
alter table if exists mahila_shakti_grievances alter column email drop not null;
alter table if exists mahila_shakti_grievances alter column district drop not null;
alter table if exists mahila_shakti_grievances alter column constituency drop not null;
alter table if exists mahila_shakti_grievances alter column mandal drop not null;
alter table if exists mahila_shakti_grievances alter column ward drop not null;
alter table if exists mahila_shakti_grievances alter column grievance_types drop not null;
alter table if exists mahila_shakti_grievances alter column grievance_other drop not null;
alter table if exists mahila_shakti_grievances alter column description drop not null;
alter table if exists mahila_shakti_grievances alter column attachments drop not null;
alter table if exists mahila_shakti_grievances alter column response_modes drop not null;
alter table if exists mahila_shakti_grievances alter column volunteer drop not null;
alter table if exists mahila_shakti_grievances alter column declaration drop not null;
alter table if exists mahila_shakti_grievances alter column status drop not null;
alter table if exists mahila_shakti_grievances alter column submitted_at drop not null;

-- Safety net for older/unknown legacy columns (e.g., address) that may still be NOT NULL
do $$
declare
  r record;
begin
  for r in
    select c.column_name
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = 'mahila_shakti_grievances'
      and c.is_nullable = 'NO'
      and c.column_name <> 'id' -- keep PK semantics intact
  loop
    execute format(
      'alter table if exists public.mahila_shakti_grievances alter column %I drop not null',
      r.column_name
    );
  end loop;
end
$$;

-- Create the new Mahila Shakti registrations table
create table if not exists mahila_shakti_registrations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  fullname text not null,
  age integer not null,
  mobile text not null,
  email text,
  address text not null,
  district text not null,
  constituency text not null,
  organization text not null, -- 'Yes' or 'No'
  organization_details text,
  interest_areas text[], -- array of selected interests
  why_join text not null,
  experience text not null, -- 'Yes' or 'No'
  experience_details text,
  grievance text, -- optional grievance/concern
  declaration boolean not null default false,
  status text default 'Registered',
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create citizen feedback table
create table if not exists citizen_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  name text not null,
  mobile text not null,
  area text not null,
  roads_condition text not null,
  power_issues text not null,
  water_supply text not null,
  drainage_system text not null,
  public_transport text not null,
  infrastructure_satisfaction text not null,
  scheme_awareness text not null,
  scheme_benefits text not null,
  scheme_satisfaction text not null,
  education_facilities text not null,
  education_satisfaction text not null,
  employment_opportunities text not null,
  employment_satisfaction text not null,
  healthcare_access text not null,
  accessibility_satisfaction text not null,
  issues_heard text not null,
  leadership_satisfaction text not null,
  priority_issue text not null,
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists social_media_grievances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete set null,
  fullname text,
  email text,
  phone text,
  location text,
  platforms text[], -- array of selected platforms
  platform_other text,
  grievance text,
  action text,
  file_urls text[], -- array of uploaded file URLs
  warrior_options text[],
  updates_options text[],
  status text default 'Investigating',
  submitted_at timestamp with time zone default timezone('utc'::text, now())
);

