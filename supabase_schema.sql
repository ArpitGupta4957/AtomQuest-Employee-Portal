-- ==========================================
-- ATOMQUEST HACKATHON 1.0 SUPABASE SCHEMA
-- ==========================================

-- 1. ENUMS
CREATE TYPE user_role AS ENUM ('employee', 'manager', 'admin');
CREATE TYPE goal_status AS ENUM ('draft', 'notStarted', 'pendingApproval', 'approved', 'rejected', 'inProgress', 'completed', 'overdue', 'locked');
CREATE TYPE uom_type AS ENUM ('numeric', 'percentage', 'timeline', 'zeroBased');
CREATE TYPE thrust_area AS ENUM ('strategicInitiative', 'operationalExcellence', 'innovation', 'customerSuccess', 'teamDevelopment', 'sustainability', 'revenueGrowth', 'processImprovement');
CREATE TYPE quarter AS ENUM ('q1', 'q2', 'q3', 'q4');
CREATE TYPE notification_type AS ENUM ('goalApproved', 'goalRejected', 'checkInReminder', 'managerFeedback', 'sharedGoalAssigned', 'quarterlyAlert', 'escalation');
CREATE TYPE audit_action AS ENUM ('goalCreated', 'goalEdited', 'goalSubmitted', 'goalApproved', 'goalRejected', 'goalUnlocked', 'quarterlyUpdate', 'sharedGoalCreated', 'sharedGoalLinked', 'commentAdded', 'weightageChanged');

-- 2. TABLES

-- Departments Table
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    head_id UUID, -- Will be constrained to users table after users table is created
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users Table (Extends Supabase Auth Auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role user_role NOT NULL DEFAULT 'employee',
    department_id UUID REFERENCES departments(id),
    designation TEXT NOT NULL,
    manager_id UUID REFERENCES users(id),
    avatar_url TEXT,
    joined_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add foreign key constraint to departments head_id
ALTER TABLE departments ADD CONSTRAINT fk_departments_head FOREIGN KEY (head_id) REFERENCES users(id);

-- Performance Cycles
CREATE TABLE performance_cycles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    year INT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shared Goals (Created by Admin/Managers, pushed down)
CREATE TABLE shared_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    thrust_area thrust_area NOT NULL,
    uom_type uom_type NOT NULL,
    target NUMERIC NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    target_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shared Goal Assignments (M2M tracking for assigned users and departments)
CREATE TABLE shared_goal_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shared_goal_id UUID NOT NULL REFERENCES shared_goals(id) ON DELETE CASCADE,
    assigned_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    assigned_department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
    CHECK (assigned_user_id IS NOT NULL OR assigned_department_id IS NOT NULL)
);

-- Individual Goals
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    thrust_area thrust_area NOT NULL,
    uom_type uom_type NOT NULL,
    target NUMERIC NOT NULL,
    weightage NUMERIC NOT NULL CHECK (weightage >= 10 AND weightage <= 100),
    status goal_status NOT NULL DEFAULT 'draft',
    shared_goal_id UUID REFERENCES shared_goals(id),
    is_shared BOOLEAN DEFAULT false,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    target_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quarterly Check-ins
CREATE TABLE quarterly_checkins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    quarter quarter NOT NULL,
    achievement NUMERIC,
    self_rating INT CHECK (self_rating >= 1 AND self_rating <= 5),
    notes TEXT,
    status goal_status NOT NULL DEFAULT 'draft',
    manager_comment TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(goal_id, quarter)
);

-- Goal Comments
CREATE TABLE goal_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit Logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action audit_action NOT NULL,
    goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    old_value TEXT,
    new_value TEXT,
    field_name TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    related_goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- ==========================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE quarterly_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ── Users Table RLS ──
-- Users can view all profiles in their organization.
CREATE POLICY "Users can view all other users" ON users FOR SELECT USING (true);
-- Users can only update their own profile.
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- ── Goals Table RLS ──
-- Employees can view and manage their own goals.
CREATE POLICY "Employees can manage own goals" ON goals FOR ALL USING (employee_id = auth.uid());
-- Managers can view and update goals of employees they manage.
CREATE POLICY "Managers can view/update team goals" ON goals FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = goals.employee_id AND manager_id = auth.uid())
);
-- Admins can view all goals.
CREATE POLICY "Admins can view all goals" ON goals FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- ── Check-ins Table RLS ──
-- Employees can manage their own check-ins
CREATE POLICY "Employees can manage own check-ins" ON quarterly_checkins FOR ALL USING (
    EXISTS (SELECT 1 FROM goals WHERE id = quarterly_checkins.goal_id AND employee_id = auth.uid())
);
-- Managers can view and update checkins of their team
CREATE POLICY "Managers can manage team check-ins" ON quarterly_checkins FOR ALL USING (
    EXISTS (
        SELECT 1 FROM goals 
        JOIN users ON goals.employee_id = users.id 
        WHERE goals.id = quarterly_checkins.goal_id AND users.manager_id = auth.uid()
    )
);

-- ── Notifications RLS ──
-- Users can only see and manage their own notifications
CREATE POLICY "Users manage own notifications" ON notifications FOR ALL USING (user_id = auth.uid());

-- ── Realtime Setup ──
-- Enable Realtime for critical tables
alter publication supabase_realtime add table goals;
alter publication supabase_realtime add table notifications;
alter publication supabase_realtime add table quarterly_checkins;
alter publication supabase_realtime add table goal_comments;
