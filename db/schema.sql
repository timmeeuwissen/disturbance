-- Severities table
CREATE TABLE IF NOT EXISTS severities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    value TEXT NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Statuses table
CREATE TABLE IF NOT EXISTS statuses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    value TEXT NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    is_final BOOLEAN NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Reference types table
CREATE TABLE IF NOT EXISTS reference_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    value TEXT NOT NULL UNIQUE,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
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

-- Issues table to store main incident information
CREATE TABLE IF NOT EXISTS issues (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    reporter TEXT NOT NULL,
    registrar TEXT NOT NULL,
    severity_id INTEGER NOT NULL,
    status_id INTEGER NOT NULL,
    topic TEXT NOT NULL,
    start_timestamp DATETIME,
    report_timestamp DATETIME,
    resolution_timestamp DATETIME,
    mitigation_steps TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (severity_id) REFERENCES severities(id),
    FOREIGN KEY (status_id) REFERENCES statuses(id),
    CHECK (
        (status_id NOT IN (SELECT id FROM statuses WHERE value IN ('resolved', 'closed'))) OR 
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
    reference_type_id INTEGER NOT NULL,
    description TEXT,
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE,
    FOREIGN KEY (reference_type_id) REFERENCES reference_types(id)
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

-- Issue tags junction table
CREATE TABLE IF NOT EXISTS issue_tags (
    issue_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (issue_id, tag_id),
    FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Initial severity data
INSERT OR IGNORE INTO severities (value, description, sort_order) VALUES
    ('critical', 'Critical severity level', 1),
    ('high', 'High severity level', 2),
    ('medium', 'Medium severity level', 3),
    ('low', 'Low severity level', 4);

-- Initial status data
INSERT OR IGNORE INTO statuses (value, description, sort_order, is_final) VALUES
    ('open', 'Issue is open', 1, 0),
    ('investigating', 'Issue is being investigated', 2, 0),
    ('mitigated', 'Issue has been mitigated', 3, 0),
    ('resolved', 'Issue has been resolved', 4, 1),
    ('closed', 'Issue is closed', 5, 1);

-- Initial reference type data
INSERT OR IGNORE INTO reference_types (value, description, sort_order) VALUES
    ('jira', 'Jira reference', 1),
    ('slack', 'Slack reference', 2),
    ('system', 'System reference', 3),
    ('other', 'Other reference type', 4);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status_id);
CREATE INDEX IF NOT EXISTS idx_issues_severity ON issues(severity_id);
CREATE INDEX IF NOT EXISTS idx_issues_topic ON issues(topic);
CREATE INDEX IF NOT EXISTS idx_issues_timestamps ON issues(start_timestamp, report_timestamp, resolution_timestamp);
CREATE INDEX IF NOT EXISTS idx_communication_logs_datetime ON communication_logs(datetime);
CREATE INDEX IF NOT EXISTS idx_communication_logs_issue ON communication_logs(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_tags_issue ON issue_tags(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_tags_tag ON issue_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_severities_active ON severities(is_active);
CREATE INDEX IF NOT EXISTS idx_statuses_active ON statuses(is_active);
CREATE INDEX IF NOT EXISTS idx_reference_types_active ON reference_types(is_active);
