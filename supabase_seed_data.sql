-- ==========================================
-- ATOMQUEST HACKATHON 1.0 - SEED DATA
-- ==========================================
-- Run this in your Supabase SQL Editor AFTER running the schema file.

-- 1. Insert Departments
INSERT INTO public.departments (id, name, created_at)
VALUES 
('d1111111-1111-1111-1111-111111111111', 'Engineering', NOW()),
('d2222222-2222-2222-2222-222222222222', 'Product', NOW()),
('d3333333-3333-3333-3333-333333333333', 'Human Resources', NOW())
ON CONFLICT DO NOTHING;

-- 2. Insert Users into Supabase Auth (So you can log in manually)
-- Password for all users is: demo1234
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
('e1111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'employee@atomberg.com', crypt('demo1234', gen_salt('bf')), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW()),
('b2222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'manager@atomberg.com', crypt('demo1234', gen_salt('bf')), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW()),
('a3333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@atomberg.com', crypt('demo1234', gen_salt('bf')), NOW(), '{"provider":"email","providers":["email"]}', '{}', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- 3. Insert Users into Public Schema (App Profiles)
INSERT INTO public.users (id, name, email, role, department_id, designation, manager_id, joined_date, created_at)
VALUES 
-- The Admin
('a3333333-3333-3333-3333-333333333333', 'Alice Admin', 'admin@atomberg.com', 'admin', 'd3333333-3333-3333-3333-333333333333', 'HR Director', NULL, '2020-01-15', NOW()),
-- The Manager
('b2222222-2222-2222-2222-222222222222', 'Michael Scott', 'manager@atomberg.com', 'manager', 'd1111111-1111-1111-1111-111111111111', 'Engineering Manager', 'a3333333-3333-3333-3333-333333333333', '2021-03-10', NOW()),
-- The Employee
('e1111111-1111-1111-1111-111111111111', 'Sarah Jenkins', 'employee@atomberg.com', 'employee', 'd1111111-1111-1111-1111-111111111111', 'Frontend Developer', 'b2222222-2222-2222-2222-222222222222', '2023-06-01', NOW())
ON CONFLICT (id) DO NOTHING;

-- 4. Update Departments with Heads
UPDATE public.departments SET head_id = 'b2222222-2222-2222-2222-222222222222' WHERE id = 'd1111111-1111-1111-1111-111111111111';
UPDATE public.departments SET head_id = 'a3333333-3333-3333-3333-333333333333' WHERE id = 'd3333333-3333-3333-3333-333333333333';

-- 5. Insert Sample Goals for the Employee
INSERT INTO public.goals (id, employee_id, title, description, thrust_area, uom_type, target, weightage, status, start_date, target_date, created_at)
VALUES 
('f1111111-1111-1111-1111-111111111111', 'e1111111-1111-1111-1111-111111111111', 'Ship AtomQuest Portal v1', 'Complete frontend and backend integration before the hackathon deadline.', 'strategicInitiative', 'percentage', 100, 40, 'approved', '2024-05-01', '2024-06-30', NOW()),
('f2222222-2222-2222-2222-222222222222', 'e1111111-1111-1111-1111-111111111111', 'Reduce App Load Time', 'Optimize Flutter rendering and reduce Supabase payload sizes.', 'operationalExcellence', 'numeric', 1.5, 30, 'inProgress', '2024-05-01', '2024-09-30', NOW()),
('f3333333-3333-3333-3333-333333333333', 'e1111111-1111-1111-1111-111111111111', 'Conduct Peer Code Reviews', 'Review at least 20 PRs from team members to ensure code quality.', 'teamDevelopment', 'numeric', 20, 30, 'pendingApproval', '2024-05-01', '2024-12-31', NOW())
ON CONFLICT (id) DO NOTHING;

-- 6. Insert a Quarterly Check-in for the first goal
INSERT INTO public.quarterly_checkins (id, goal_id, quarter, achievement, self_rating, notes, status, manager_comment, submitted_at)
VALUES 
('c1111111-1111-1111-1111-111111111111', 'f1111111-1111-1111-1111-111111111111', 'q1', 85, 4, 'Most features are complete. Just finalizing the reporting module.', 'inProgress', 'Great progress Sarah. Let me know if you need help with the CSV export.', NOW())
ON CONFLICT (id) DO NOTHING;

-- 7. Insert some Audit Logs
INSERT INTO public.audit_logs (id, action, goal_id, user_id, new_value, timestamp)
VALUES 
(uuid_generate_v4(), 'goalCreated', 'f1111111-1111-1111-1111-111111111111', 'e1111111-1111-1111-1111-111111111111', 'New goal submitted', NOW() - INTERVAL '10 days'),
(uuid_generate_v4(), 'goalApproved', 'f1111111-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', 'approved', NOW() - INTERVAL '8 days')
ON CONFLICT DO NOTHING;
