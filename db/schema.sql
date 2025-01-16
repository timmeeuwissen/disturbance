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

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_severity ON issues(severity);
CREATE INDEX IF NOT EXISTS idx_issues_topic ON issues(topic);
CREATE INDEX IF NOT EXISTS idx_issues_timestamps ON issues(start_timestamp, report_timestamp, resolution_timestamp);
CREATE INDEX IF NOT EXISTS idx_communication_logs_datetime ON communication_logs(datetime);
CREATE INDEX IF NOT EXISTS idx_communication_logs_issue ON communication_logs(issue_id);
