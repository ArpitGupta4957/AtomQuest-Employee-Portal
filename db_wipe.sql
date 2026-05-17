-- ==========================================
-- ATOMQUEST - SAFE DATABASE WIPE SCRIPT
-- ==========================================
-- Run this script if you need to clear your database.
-- It safely breaks foreign key constraints (like department heads) 
-- before deleting the data so you don't get constraint errors.

-- 1. Break circular dependencies
UPDATE public.departments SET head_id = NULL;
UPDATE public.users SET manager_id = NULL;

-- 2. Delete all records in the correct order (children first, then parents)
DELETE FROM public.audit_logs;
DELETE FROM public.quarterly_checkins;
DELETE FROM public.goals;

-- 3. Delete users from public schema
DELETE FROM public.users;

-- 4. Delete users from auth schema
DELETE FROM auth.identities;
DELETE FROM auth.users;

-- 5. Finally, delete departments
DELETE FROM public.departments;

-- You can now run the supabase_seed_data.sql and fix_auth_identities.sql scripts again!
