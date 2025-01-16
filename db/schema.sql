CREATE TABLE IF NOT EXISTS statuses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  is_final BOOLEAN NOT NULL DEFAULT 0,
  is_default BOOLEAN NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS severities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS reference_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS issues (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  reporter TEXT NOT NULL,
  registrar TEXT NOT NULL,
  severity TEXT NOT NULL,
  status TEXT NOT NULL,
  topic TEXT,
  start_timestamp TEXT,
  report_timestamp TEXT NOT NULL,
  resolution_timestamp TEXT,
  mitigation_steps TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS issue_references (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issue_id INTEGER NOT NULL,
  url TEXT NOT NULL,
  reference_type TEXT NOT NULL,
  description TEXT,
  FOREIGN KEY (issue_id) REFERENCES issues (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS impacted_systems (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issue_id INTEGER NOT NULL,
  system_name TEXT NOT NULL,
  impact_description TEXT,
  FOREIGN KEY (issue_id) REFERENCES issues (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS involved_teams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issue_id INTEGER NOT NULL,
  team_name TEXT NOT NULL,
  role TEXT,
  FOREIGN KEY (issue_id) REFERENCES issues (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS communication_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issue_id INTEGER NOT NULL,
  timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  message TEXT NOT NULL,
  channel TEXT NOT NULL,
  sender TEXT NOT NULL,
  FOREIGN KEY (issue_id) REFERENCES issues (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS issue_tags (
  issue_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (issue_id, tag_id),
  FOREIGN KEY (issue_id) REFERENCES issues (id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
);

-- Triggers to ensure only one default per type
CREATE TRIGGER IF NOT EXISTS status_default_trigger
AFTER UPDATE ON statuses
WHEN NEW.is_default = 1
BEGIN
  UPDATE statuses SET is_default = 0 WHERE id != NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS severity_default_trigger
AFTER UPDATE ON severities
WHEN NEW.is_default = 1
BEGIN
  UPDATE severities SET is_default = 0 WHERE id != NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS reference_type_default_trigger
AFTER UPDATE ON reference_types
WHEN NEW.is_default = 1
BEGIN
  UPDATE reference_types SET is_default = 0 WHERE id != NEW.id;
END;

-- Insert initial data
INSERT OR IGNORE INTO statuses (name, is_final, is_default, sort_order) VALUES
  ('New', 0, 1, 0),
  ('In Progress', 0, 0, 1),
  ('Resolved', 1, 0, 2);

INSERT OR IGNORE INTO severities (name, is_default, sort_order) VALUES
  ('Low', 0, 0),
  ('Medium', 1, 1),
  ('High', 0, 2),
  ('Critical', 0, 3);

INSERT OR IGNORE INTO reference_types (name, is_default, sort_order) VALUES
  ('Jira', 1, 0),
  ('GitHub', 0, 1),
  ('ServiceNow', 0, 2);
