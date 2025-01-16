-- Sample Statuses
INSERT INTO statuses (name, is_final, is_default, sort_order) VALUES
  ('New', 0, 1, 0),
  ('Investigating', 0, 0, 1),
  ('Mitigating', 0, 0, 2),
  ('Resolved', 1, 0, 3),
  ('Closed', 1, 0, 4);

-- Sample Severities
INSERT INTO severities (name, is_default, sort_order) VALUES
  ('Low', 0, 0),
  ('Medium', 1, 1),
  ('High', 0, 2),
  ('Critical', 0, 3),
  ('Urgent', 0, 4);

-- Sample Reference Types
INSERT INTO reference_types (name, is_default, sort_order) VALUES
  ('Jira', 1, 0),
  ('GitHub', 0, 1),
  ('ServiceNow', 0, 2),
  ('Confluence', 0, 3),
  ('Slack', 0, 4);

-- Sample Issues
INSERT INTO issues (
  title, description, reporter, registrar, severity, status,
  topic, start_timestamp, report_timestamp, resolution_timestamp,
  mitigation_steps, created_at, updated_at
) VALUES
  (
    'Database Connection Issues',
    'Users experiencing intermittent connection drops to main database',
    'John Smith',
    'Jane Doe',
    'High',
    'Resolved',
    'Infrastructure',
    '2024-01-15 08:30:00',
    '2024-01-15 08:45:00',
    '2024-01-15 11:30:00',
    'Scaled up connection pool and optimized query patterns',
    '2024-01-15 08:45:00',
    '2024-01-15 11:30:00'
  ),
  (
    'API Gateway Latency Spike',
    'API responses showing increased latency across all endpoints',
    'Mike Johnson',
    'Sarah Wilson',
    'Critical',
    'Mitigating',
    'Performance',
    '2024-01-16 14:20:00',
    '2024-01-16 14:25:00',
    NULL,
    'Investigating potential memory leak in gateway service',
    '2024-01-16 14:25:00',
    '2024-01-16 15:00:00'
  ),
  (
    'SSL Certificate Expiration',
    'Production SSL certificate expires in 24 hours',
    'Emma Brown',
    'David Clark',
    'High',
    'New',
    'Security',
    '2024-01-17 09:00:00',
    '2024-01-17 09:05:00',
    NULL,
    NULL,
    '2024-01-17 09:05:00',
    '2024-01-17 09:05:00'
  );

-- Sample References
INSERT INTO issue_references (issue_id, url, reference_type, description) VALUES
  (1, 'https://jira.company.com/browse/INC-123', 'Jira', 'Main incident ticket'),
  (1, 'https://github.com/company/service/pull/456', 'GitHub', 'Fix PR'),
  (2, 'https://jira.company.com/browse/INC-124', 'Jira', 'Incident ticket'),
  (2, 'https://confluence.company.com/pages/perf-runbook', 'Confluence', 'Performance troubleshooting runbook'),
  (3, 'https://jira.company.com/browse/INC-125', 'Jira', 'Certificate renewal ticket');

-- Sample Impacted Systems
INSERT INTO impacted_systems (issue_id, system_name, impact_description) VALUES
  (1, 'User Service', 'Intermittent 500 errors'),
  (1, 'Admin Dashboard', 'Unable to view user data'),
  (2, 'API Gateway', 'High latency on all requests'),
  (2, 'Customer Portal', 'Slow page loads'),
  (3, 'All HTTPS Services', 'Will be affected by certificate expiration');

-- Sample Involved Teams
INSERT INTO involved_teams (issue_id, team_name, role) VALUES
  (1, 'Database Team', 'Primary'),
  (1, 'Platform Team', 'Support'),
  (2, 'SRE Team', 'Primary'),
  (2, 'Backend Team', 'Support'),
  (3, 'Security Team', 'Primary'),
  (3, 'DevOps Team', 'Support');

-- Sample Tags
INSERT INTO tags (name) VALUES
  ('infrastructure'),
  ('database'),
  ('performance'),
  ('security'),
  ('urgent');

-- Sample Issue Tags
INSERT INTO issue_tags (issue_id, tag_id) VALUES
  (1, 1), -- infrastructure
  (1, 2), -- database
  (2, 1), -- infrastructure
  (2, 3), -- performance
  (2, 5), -- urgent
  (3, 4); -- security
