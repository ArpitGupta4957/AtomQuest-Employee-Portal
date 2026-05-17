-- ==========================================
-- ATOMQUEST HACKATHON 1.0 - DYNAMIC SEED DATA
-- ==========================================
-- INSTRUCTIONS:
-- 1. Create the 3 users in the Supabase Dashboard -> Authentication -> Users:
--    - employee@atomberg.com
--    - manager@atomberg.com
--    - admin@atomberg.com
-- 2. Run this script in the SQL Editor. It will dynamically fetch their new IDs!

-- 1. Insert Departments
INSERT INTO public.departments (id, name, created_at)
VALUES 
('d1111111-1111-1111-1111-111111111111', 'Engineering', NOW()),
('d2222222-2222-2222-2222-222222222222', 'Product', NOW()),
('d3333333-3333-3333-3333-333333333333', 'Human Resources', NOW())
ON CONFLICT DO NOTHING;

-- 2. Dynamically Insert Users into Public Schema (App Profiles) using their real Auth IDs
INSERT INTO public.users (id, name, email, role, department_id, designation, manager_id, joined_date, created_at)
SELECT id, 'Sarah Jenkins', 'employee@atomberg.com', 'employee'::user_role, 'd1111111-1111-1111-1111-111111111111'::uuid, 'Frontend Developer', NULL::uuid, '2023-06-01'::timestamp, NOW() FROM auth.users WHERE email = 'employee@atomberg.com'
UNION ALL
SELECT id, 'Michael Scott', 'manager@atomberg.com', 'manager'::user_role, 'd1111111-1111-1111-1111-111111111111'::uuid, 'Engineering Manager', NULL::uuid, '2021-03-10'::timestamp, NOW() FROM auth.users WHERE email = 'manager@atomberg.com'
UNION ALL
SELECT id, 'Alice Admin', 'admin@atomberg.com', 'admin'::user_role, 'd3333333-3333-3333-3333-333333333333'::uuid, 'HR Director', NULL::uuid, '2020-01-15'::timestamp, NOW() FROM auth.users WHERE email = 'admin@atomberg.com'
ON CONFLICT DO NOTHING;

-- 3. Update Managers (now that everyone exists in the table)
UPDATE public.users 
SET manager_id = (SELECT id FROM public.users WHERE email = 'manager@atomberg.com') 
WHERE email = 'employee@atomberg.com';

UPDATE public.users 
SET manager_id = (SELECT id FROM public.users WHERE email = 'admin@atomberg.com') 
WHERE email = 'manager@atomberg.com';

-- 4. Update Departments with Heads
UPDATE public.departments SET head_id = (SELECT id FROM public.users WHERE email = 'manager@atomberg.com') WHERE id = 'd1111111-1111-1111-1111-111111111111';
UPDATE public.departments SET head_id = (SELECT id FROM public.users WHERE email = 'admin@atomberg.com') WHERE id = 'd3333333-3333-3333-3333-333333333333';

-- 5. Insert Sample Goals for the Employee (Dynamically linking to their real ID)
INSERT INTO public.goals (id, employee_id, title, description, thrust_area, uom_type, target, weightage, status, start_date, target_date, created_at)
SELECT 'f1111111-1111-1111-1111-111111111111'::uuid, id, 'Ship AtomQuest Portal v1', 'Complete frontend and backend integration before the hackathon deadline.', 'strategicInitiative'::thrust_area, 'percentage'::uom_type, 100, 40, 'approved'::goal_status, '2024-05-01'::timestamp, '2024-06-30'::timestamp, NOW() FROM public.users WHERE email = 'employee@atomberg.com'
UNION ALL
SELECT 'f2222222-2222-2222-2222-222222222222'::uuid, id, 'Reduce App Load Time', 'Optimize Flutter rendering and reduce Supabase payload sizes.', 'operationalExcellence'::thrust_area, 'numeric'::uom_type, 1.5, 30, 'inProgress'::goal_status, '2024-05-01'::timestamp, '2024-09-30'::timestamp, NOW() FROM public.users WHERE email = 'employee@atomberg.com'
UNION ALL
SELECT 'f3333333-3333-3333-3333-333333333333'::uuid, id, 'Conduct Peer Code Reviews', 'Review at least 20 PRs from team members to ensure code quality.', 'teamDevelopment'::thrust_area, 'numeric'::uom_type, 20, 30, 'pendingApproval'::goal_status, '2024-05-01'::timestamp, '2024-12-31'::timestamp, NOW() FROM public.users WHERE email = 'employee@atomberg.com'
ON CONFLICT DO NOTHING;

-- 6. Insert a Quarterly Check-in for the first goal
INSERT INTO public.quarterly_checkins (id, goal_id, quarter, achievement, self_rating, notes, status, manager_comment, submitted_at)
VALUES 
('c1111111-1111-1111-1111-111111111111', 'f1111111-1111-1111-1111-111111111111', 'q1', 85, 4, 'Most features are complete. Just finalizing the reporting module.', 'inProgress', 'Great progress Sarah. Let me know if you need help with the CSV export.', NOW())
ON CONFLICT (id) DO NOTHING;

-- 7. Insert some Audit Logs
INSERT INTO public.audit_logs (id, action, goal_id, user_id, new_value, timestamp)
SELECT uuid_generate_v4(), 'goalCreated'::audit_action, 'f1111111-1111-1111-1111-111111111111'::uuid, id, 'New goal submitted', NOW() - INTERVAL '10 days' FROM public.users WHERE email = 'employee@atomberg.com'
UNION ALL
SELECT uuid_generate_v4(), 'goalApproved'::audit_action, 'f1111111-1111-1111-1111-111111111111'::uuid, id, 'approved', NOW() - INTERVAL '8 days' FROM public.users WHERE email = 'manager@atomberg.com'
ON CONFLICT DO NOTHING;
