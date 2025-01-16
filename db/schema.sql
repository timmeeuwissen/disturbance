-- Issues table to store main incident information
CREATE TABLE IF NOT EXISTS issues (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    reporter TEXT NOT NULL,
    registrar TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('critical', 'high', 'medium', 'low')),
    status TEXT NOT NULL CHECK (status IN ('open', 'investigating', 'mitigated', 'resolved', 'closed')),
    topic TEXT NOT NULL,
    start_timestamp DATETIME,
    report_timestamp DATETIME,
    resolution_timestamp DATETIME,
    mitigation_steps TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        (status != 'resolved' AND status != 'closed') OR 
        (start_timestamp IS NOT NULL AND resolution_timestamp IS NOT NULL)
    )
);

-- Communication logs for issue timeline
CREATE TABLE IF NOT EXISTS communication_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    issue_id INTEGER NOT NULL,
    link TEXT,
    datetime DATETIME NOT NULL,
    communicator TEXT NOT NULL,
    system TEXT,
    is_internal BOOLEAN NOT NULL DEFAULT 0,
    message TEXT NOT NULL,
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE
);

-- References table for URLs (Jira, Slack, etc.)
CREATE TABLE IF NOT EXISTS issue_references (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    issue_id INTEGER NOT NULL,
    url TEXT NOT NULL,
    reference_type TEXT NOT NULL CHECK (reference_type IN ('jira', 'slack', 'system', 'other')),
    description TEXT,
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE
);

-- Impacted systems tracking
CREATE TABLE IF NOT EXISTS impacted_systems (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    issue_id INTEGER NOT NULL,
    system_name TEXT NOT NULL,
    impact_description TEXT,
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE
);

-- Teams involved in incident resolution
CREATE TABLE IF NOT EXISTS involved_teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    issue_id INTEGER NOT NULL,
    team_name TEXT NOT NULL,
    role TEXT,
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE
);

-- Tags table for issue categorization
CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    definition TEXT NOT NULL,
    description TEXT,
    color_primary TEXT NOT NULL DEFAULT '#FF9800',
    color_secondary TEXT NOT NULL DEFAULT '#FFB74D',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Issue tags junction table
CREATE TABLE IF NOT EXISTS issue_tags (
    issue_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (issue_id, tag_id),
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Enumerations table for system lists
CREATE TABLE IF NOT EXISTS enumerations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(category, value)
);

-- Initial enumeration data
INSERT OR IGNORE INTO enumerations (category, value, description, sort_order) VALUES
    ('severity', 'critical', 'Critical severity level', 1),
    ('severity', 'high', 'High severity level', 2),
    ('severity', 'medium', 'Medium severity level', 3),
    ('severity', 'low', 'Low severity level', 4),
    ('status', 'open', 'Issue is open', 1),
    ('status', 'investigating', 'Issue is being investigated', 2),
    ('status', 'mitigated', 'Issue has been mitigated', 3),
    ('status', 'resolved', 'Issue has been resolved', 4),
    ('status', 'closed', 'Issue is closed', 5),
    ('reference_type', 'jira', 'Jira reference', 1),
    ('reference_type', 'slack', 'Slack reference', 2),
    ('reference_type', 'system', 'System reference', 3),
    ('reference_type', 'other', 'Other reference type', 4);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_severity ON issues(severity);
CREATE INDEX IF NOT EXISTS idx_issues_topic ON issues(topic);
CREATE INDEX IF NOT EXISTS idx_issues_timestamps ON issues(start_timestamp, report_timestamp, resolution_timestamp);
CREATE INDEX IF NOT EXISTS idx_communication_logs_datetime ON communication_logs(datetime);
CREATE INDEX IF NOT EXISTS idx_communication_logs_issue ON communication_logs(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_tags_issue ON issue_tags(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_tags_tag ON issue_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_enumerations_category ON enumerations(category);
CREATE INDEX IF NOT EXISTS idx_enumerations_active ON enumerations(is_active);
