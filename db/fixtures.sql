-- Sample Statuses
INSERT INTO statuses (name, is_final, is_default, sort_order) VALUES
  ('New', 0, 1, 0),
  ('Investigating', 0, 0, 1),
  ('Mitigating', 0, 0, 2),
  ('Resolved', 1, 0, 3),
  ('Closed', 1, 0, 4),
  ('Pending Review', 0, 0, 5),
  ('Escalated', 0, 0, 6),
  ('On Hold', 0, 0, 7),
  ('Reopened', 0, 0, 8),
  ('Awaiting Input', 0, 0, 9),
  ('In Progress', 0, 0, 10),
  ('Blocked', 0, 0, 11),
  ('Deferred', 0, 0, 12),
  ('Scheduled', 0, 0, 13),
  ('Cancelled', 1, 0, 14);

-- Sample Severities
INSERT INTO severities (name, is_default, sort_order) VALUES
  ('Low', 0, 0),
  ('Medium', 1, 1),
  ('High', 0, 2),
  ('Critical', 0, 3),
  ('Urgent', 0, 4),
  ('Minor', 0, 5),
  ('Major', 0, 6),
  ('Severe', 0, 7),
  ('Negligible', 0, 8),
  ('Moderate', 0, 9),
  ('Significant', 0, 10),
  ('Catastrophic', 0, 11),
  ('Minimal', 0, 12),
  ('Extreme', 0, 13),
  ('Warning', 0, 14);

-- Sample Reference Types
INSERT INTO reference_types (name, is_default, sort_order) VALUES
  ('Jira', 1, 0),
  ('GitHub', 0, 1),
  ('ServiceNow', 0, 2),
  ('Confluence', 0, 3),
  ('Slack', 0, 4),
  ('Teams', 0, 5),
  ('Email', 0, 6),
  ('Wiki', 0, 7),
  ('PagerDuty', 0, 8),
  ('Linear', 0, 9),
  ('Notion', 0, 10),
  ('Trello', 0, 11),
  ('Asana', 0, 12),
  ('Google Doc', 0, 13),
  ('Zendesk', 0, 14);

-- Sample Issues
INSERT INTO issues (
  title, description, reporter, registrar, severity, status,
  topic, start_timestamp, report_timestamp, resolution_timestamp,
  mitigation_steps, created_at, updated_at
) VALUES
  -- Infrastructure Issues
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
  ),
  -- Security Issues
  (
    'Suspicious Login Attempts',
    'Multiple failed login attempts detected from unknown IP ranges',
    'Security Team',
    'Alex Turner',
    'Critical',
    'Investigating',
    'Security',
    '2024-01-18 03:15:00',
    '2024-01-18 03:20:00',
    NULL,
    'Implementing IP blocking and additional monitoring',
    '2024-01-18 03:20:00',
    '2024-01-18 04:00:00'
  ),
  (
    'Data Privacy Compliance Alert',
    'Potential PII exposure in log files',
    'Compliance Team',
    'Rachel Green',
    'High',
    'Mitigating',
    'Security',
    '2024-01-19 11:00:00',
    '2024-01-19 11:15:00',
    NULL,
    'Implementing log sanitization and reviewing affected files',
    '2024-01-19 11:15:00',
    '2024-01-19 12:00:00'
  ),
  -- Performance Issues
  (
    'Memory Leak in Processing Service',
    'Gradual memory increase observed in processing service',
    'Monitoring Team',
    'Chris Evans',
    'Medium',
    'Investigating',
    'Performance',
    '2024-01-20 15:30:00',
    '2024-01-20 15:45:00',
    NULL,
    'Analyzing heap dumps and implementing memory profiling',
    '2024-01-20 15:45:00',
    '2024-01-20 16:30:00'
  ),
  (
    'High CPU Usage in Worker Nodes',
    'Worker nodes showing sustained high CPU utilization',
    'DevOps Team',
    'Tony Stark',
    'High',
    'Mitigating',
    'Performance',
    '2024-01-21 09:45:00',
    '2024-01-21 10:00:00',
    NULL,
    'Scaling up worker nodes and optimizing workload distribution',
    '2024-01-21 10:00:00',
    '2024-01-21 11:00:00'
  ),
  -- Network Issues
  (
    'Network Connectivity Loss',
    'Complete network outage in EU region',
    'Network Team',
    'Bruce Wayne',
    'Critical',
    'Resolved',
    'Infrastructure',
    '2024-01-22 02:00:00',
    '2024-01-22 02:05:00',
    '2024-01-22 04:30:00',
    'Failover to backup network provider and resolved routing issues',
    '2024-01-22 02:05:00',
    '2024-01-22 04:30:00'
  ),
  (
    'DNS Resolution Delays',
    'Intermittent DNS resolution failures affecting multiple services',
    'Infrastructure Team',
    'Peter Parker',
    'High',
    'Resolved',
    'Infrastructure',
    '2024-01-23 13:15:00',
    '2024-01-23 13:30:00',
    '2024-01-23 15:45:00',
    'Updated DNS configuration and implemented caching improvements',
    '2024-01-23 13:30:00',
    '2024-01-23 15:45:00'
  ),
  -- Storage Issues
  (
    'Storage Capacity Critical',
    'Primary storage cluster approaching capacity limits',
    'Storage Team',
    'Carol Danvers',
    'Urgent',
    'Mitigating',
    'Infrastructure',
    '2024-01-24 16:00:00',
    '2024-01-24 16:15:00',
    NULL,
    'Implementing emergency cleanup and capacity expansion',
    '2024-01-24 16:15:00',
    '2024-01-24 17:00:00'
  ),
  -- Backup Issues
  (
    'Backup Job Failures',
    'Nightly backup jobs failing for customer data',
    'Backup Team',
    'Stephen Strange',
    'Major',
    'Investigating',
    'Data',
    '2024-01-25 03:00:00',
    '2024-01-25 03:30:00',
    NULL,
    'Analyzing backup logs and storage connectivity',
    '2024-01-25 03:30:00',
    '2024-01-25 04:00:00'
  ),
  -- Application Issues
  (
    'Payment Processing Delays',
    'Customer payments taking longer than usual to process',
    'Payment Team',
    'Natasha Romanoff',
    'Severe',
    'Investigating',
    'Application',
    '2024-01-26 09:00:00',
    '2024-01-26 09:15:00',
    NULL,
    'Investigating payment gateway connectivity',
    '2024-01-26 09:15:00',
    '2024-01-26 10:00:00'
  ),
  -- Monitoring Issues
  (
    'Alert System Failure',
    'Production alerts not being delivered',
    'SRE Team',
    'Clint Barton',
    'Critical',
    'Mitigating',
    'Monitoring',
    '2024-01-27 07:00:00',
    '2024-01-27 07:15:00',
    NULL,
    'Restoring alert delivery system and checking notification queue',
    '2024-01-27 07:15:00',
    '2024-01-27 08:00:00'
  ),
  -- Cache Issues
  (
    'Cache Invalidation Problems',
    'Stale data being served from cache layer',
    'Cache Team',
    'Wanda Maximoff',
    'High',
    'Investigating',
    'Performance',
    '2024-01-28 11:30:00',
    '2024-01-28 11:45:00',
    NULL,
    'Reviewing cache invalidation logic and TTL settings',
    '2024-01-28 11:45:00',
    '2024-01-28 12:30:00'
  ),
  -- Load Balancer Issues
  (
    'Load Balancer Failover',
    'Primary load balancer failed to secondary',
    'Network Team',
    'Sam Wilson',
    'Critical',
    'Resolved',
    'Infrastructure',
    '2024-01-29 14:00:00',
    '2024-01-29 14:05:00',
    '2024-01-29 15:30:00',
    'Replaced faulty network card and restored primary',
    '2024-01-29 14:05:00',
    '2024-01-29 15:30:00'
  );

-- Sample References
INSERT INTO issue_references (issue_id, url, reference_type, description) VALUES
  -- Infrastructure Issues References
  (1, 'https://jira.company.com/browse/INC-123', 'Jira', 'Main incident ticket'),
  (1, 'https://github.com/company/service/pull/456', 'GitHub', 'Fix PR'),
  (1, 'https://confluence.company.com/pages/db-runbook', 'Confluence', 'Database runbook'),
  (2, 'https://jira.company.com/browse/INC-124', 'Jira', 'Incident ticket'),
  (2, 'https://confluence.company.com/pages/perf-runbook', 'Confluence', 'Performance troubleshooting runbook'),
  (2, 'https://teams.company.com/incident-124', 'Teams', 'Incident channel'),
  (3, 'https://jira.company.com/browse/INC-125', 'Jira', 'Certificate renewal ticket'),
  (3, 'https://wiki.company.com/ssl-renewal', 'Wiki', 'SSL renewal process'),
  -- Security Issues References
  (4, 'https://jira.company.com/browse/SEC-001', 'Jira', 'Security incident ticket'),
  (4, 'https://pagerduty.com/incidents/789', 'PagerDuty', 'Initial alert'),
  (4, 'https://slack.company.com/security-alerts', 'Slack', 'Security team discussion'),
  (5, 'https://jira.company.com/browse/COMP-001', 'Jira', 'Compliance ticket'),
  (5, 'https://confluence.company.com/privacy-guidelines', 'Confluence', 'Privacy guidelines'),
  -- Performance Issues References
  (6, 'https://jira.company.com/browse/PERF-001', 'Jira', 'Performance investigation'),
  (6, 'https://github.com/company/service/issues/789', 'GitHub', 'Memory leak investigation'),
  (7, 'https://jira.company.com/browse/OPS-001', 'Jira', 'CPU utilization ticket'),
  (7, 'https://grafana.company.com/dashboard/cpu', 'Wiki', 'CPU monitoring dashboard'),
  -- Network Issues References
  (8, 'https://jira.company.com/browse/NET-001', 'Jira', 'Network outage ticket'),
  (8, 'https://status.company.com/incidents/001', 'ServiceNow', 'Public status page'),
  (9, 'https://jira.company.com/browse/NET-002', 'Jira', 'DNS issue ticket'),
  (9, 'https://confluence.company.com/dns-troubleshooting', 'Confluence', 'DNS troubleshooting guide'),
  -- Storage Issues References
  (10, 'https://jira.company.com/browse/STOR-001', 'Jira', 'Storage capacity ticket'),
  (10, 'https://linear.company.com/stor-001', 'Linear', 'Capacity planning'),
  (10, 'https://notion.company.com/storage-runbook', 'Notion', 'Storage expansion runbook'),
  -- Backup Issues References
  (11, 'https://jira.company.com/browse/BAK-001', 'Jira', 'Backup failure ticket'),
  (11, 'https://trello.com/backup-recovery', 'Trello', 'Recovery checklist'),
  (11, 'https://asana.com/backup-project', 'Asana', 'Backup improvement project'),
  -- Application Issues References
  (12, 'https://jira.company.com/browse/PAY-001', 'Jira', 'Payment processing ticket'),
  (12, 'https://zendesk.company.com/payment-delays', 'Zendesk', 'Customer support tickets'),
  (12, 'https://docs.google.com/payment-analysis', 'Google Doc', 'Payment flow analysis'),
  -- Monitoring Issues References
  (13, 'https://jira.company.com/browse/MON-001', 'Jira', 'Alert system ticket'),
  (13, 'https://pagerduty.com/incidents/alert-failure', 'PagerDuty', 'Alert system failure'),
  (13, 'https://teams.company.com/alert-incident', 'Teams', 'Alert system discussion'),
  -- Cache Issues References
  (14, 'https://jira.company.com/browse/CACHE-001', 'Jira', 'Cache invalidation ticket'),
  (14, 'https://github.com/company/cache/issues/123', 'GitHub', 'Cache investigation'),
  (14, 'https://confluence.company.com/cache-design', 'Confluence', 'Cache system design'),
  -- Load Balancer Issues References
  (15, 'https://jira.company.com/browse/LB-001', 'Jira', 'Load balancer ticket'),
  (15, 'https://wiki.company.com/lb-failover', 'Wiki', 'Failover procedure'),
  (15, 'https://slack.company.com/lb-incident', 'Slack', 'Incident discussion');

-- Sample Impacted Systems
INSERT INTO impacted_systems (issue_id, system_name, impact_description) VALUES
  -- Infrastructure Issues Impacts
  (1, 'User Service', 'Intermittent 500 errors'),
  (1, 'Admin Dashboard', 'Unable to view user data'),
  (1, 'Reporting Service', 'Delayed report generation'),
  (2, 'API Gateway', 'High latency on all requests'),
  (2, 'Customer Portal', 'Slow page loads'),
  (2, 'Mobile App', 'Timeout errors'),
  (3, 'All HTTPS Services', 'Will be affected by certificate expiration'),
  (3, 'External APIs', 'Client connections at risk'),
  -- Security Issues Impacts
  (4, 'Authentication Service', 'Under brute force attack'),
  (4, 'User Accounts', 'Potential unauthorized access attempts'),
  (5, 'Logging System', 'Privacy violation risk'),
  (5, 'Data Export Service', 'PII exposure risk'),
  -- Performance Issues Impacts
  (6, 'Processing Service', 'Degraded performance'),
  (6, 'Background Jobs', 'Increased failure rate'),
  (7, 'Worker Cluster', 'Reduced processing capacity'),
  (7, 'Job Queue', 'Growing backlog'),
  -- Network Issues Impacts
  (8, 'EU Data Center', 'Complete outage'),
  (8, 'EU Customer Services', 'Service unavailable'),
  (9, 'Service Discovery', 'Intermittent failures'),
  (9, 'Internal Services', 'Communication delays'),
  -- Storage Issues Impacts
  (10, 'Storage Cluster', 'Near capacity'),
  (10, 'Backup System', 'Unable to create new backups'),
  (10, 'Archive Service', 'Archive creation blocked'),
  -- Backup Issues Impacts
  (11, 'Backup Service', 'Failed jobs'),
  (11, 'Data Protection', 'Missing backup windows'),
  (11, 'Recovery System', 'Restore capability at risk'),
  -- Application Issues Impacts
  (12, 'Payment Gateway', 'Processing delays'),
  (12, 'Order System', 'Orders stuck in processing'),
  (12, 'Customer Billing', 'Delayed charges'),
  -- Monitoring Issues Impacts
  (13, 'Alert Manager', 'Not sending alerts'),
  (13, 'Monitoring Dashboard', 'Missing recent data'),
  (13, 'On-Call System', 'Notification failure'),
  -- Cache Issues Impacts
  (14, 'Cache Layer', 'Serving stale data'),
  (14, 'Product Catalog', 'Showing old prices'),
  (14, 'User Preferences', 'Not updating'),
  -- Load Balancer Issues Impacts
  (15, 'Load Balancer', 'Failover event'),
  (15, 'Traffic Distribution', 'Uneven distribution'),
  (15, 'SSL Termination', 'Certificate warnings');

-- Sample Involved Teams
INSERT INTO involved_teams (issue_id, team_name, role) VALUES
  -- Infrastructure Issues Teams
  (1, 'Database Team', 'Primary'),
  (1, 'Platform Team', 'Support'),
  (1, 'Application Team', 'Stakeholder'),
  (2, 'SRE Team', 'Primary'),
  (2, 'Backend Team', 'Support'),
  (2, 'API Team', 'Support'),
  (3, 'Security Team', 'Primary'),
  (3, 'DevOps Team', 'Support'),
  -- Security Issues Teams
  (4, 'Security Team', 'Primary'),
  (4, 'Infrastructure Team', 'Support'),
  (4, 'Identity Team', 'Support'),
  (5, 'Compliance Team', 'Primary'),
  (5, 'Legal Team', 'Stakeholder'),
  (5, 'Development Team', 'Support'),
  -- Performance Issues Teams
  (6, 'Platform Team', 'Primary'),
  (6, 'SRE Team', 'Support'),
  (6, 'Development Team', 'Support'),
  (7, 'DevOps Team', 'Primary'),
  (7, 'Platform Team', 'Support'),
  -- Network Issues Teams
  (8, 'Network Team', 'Primary'),
  (8, 'Infrastructure Team', 'Support'),
  (8, 'Customer Support', 'Stakeholder'),
  (9, 'Infrastructure Team', 'Primary'),
  (9, 'Network Team', 'Support'),
  -- Storage Issues Teams
  (10, 'Storage Team', 'Primary'),
  (10, 'Infrastructure Team', 'Support'),
  (10, 'Backup Team', 'Support'),
  -- Backup Issues Teams
  (11, 'Backup Team', 'Primary'),
  (11, 'Storage Team', 'Support'),
  (11, 'Data Team', 'Stakeholder'),
  -- Application Issues Teams
  (12, 'Payment Team', 'Primary'),
  (12, 'Backend Team', 'Support'),
  (12, 'Customer Support', 'Stakeholder'),
  -- Monitoring Issues Teams
  (13, 'SRE Team', 'Primary'),
  (13, 'Platform Team', 'Support'),
  (13, 'DevOps Team', 'Support'),
  -- Cache Issues Teams
  (14, 'Cache Team', 'Primary'),
  (14, 'Backend Team', 'Support'),
  (14, 'Product Team', 'Stakeholder'),
  -- Load Balancer Issues Teams
  (15, 'Network Team', 'Primary'),
  (15, 'Infrastructure Team', 'Support'),
  (15, 'Security Team', 'Support');

-- Sample Tags
INSERT INTO tags (name) VALUES
  ('infrastructure'),
  ('database'),
  ('performance'),
  ('security'),
  ('urgent'),
  ('network'),
  ('compliance'),
  ('monitoring'),
  ('customer-impact'),
  ('maintenance'),
  ('hardware'),
  ('software'),
  ('configuration'),
  ('authentication'),
  ('availability'),
  ('storage'),
  ('backup'),
  ('data-protection'),
  ('payment'),
  ('cache'),
  ('load-balancer'),
  ('alert-system'),
  ('capacity'),
  ('failover'),
  ('latency');

-- Sample Issue Tags
INSERT INTO issue_tags (issue_id, tag_id) VALUES
  -- Infrastructure Issues Tags
  (1, 1), -- infrastructure
  (1, 2), -- database
  (1, 9), -- customer-impact
  (2, 1), -- infrastructure
  (2, 3), -- performance
  (2, 5), -- urgent
  (3, 4), -- security
  (3, 10), -- maintenance
  -- Security Issues Tags
  (4, 4), -- security
  (4, 5), -- urgent
  (4, 14), -- authentication
  (5, 4), -- security
  (5, 7), -- compliance
  -- Performance Issues Tags
  (6, 3), -- performance
  (6, 8), -- monitoring
  (6, 12), -- software
  (7, 3), -- performance
  (7, 11), -- hardware
  -- Network Issues Tags
  (8, 1), -- infrastructure
  (8, 6), -- network
  (8, 15), -- availability
  (9, 6), -- network
  (9, 13), -- configuration
  -- Storage Issues Tags
  (10, 16), -- storage
  (10, 23), -- capacity
  (10, 5), -- urgent
  -- Backup Issues Tags
  (11, 17), -- backup
  (11, 18), -- data-protection
  (11, 8), -- monitoring
  -- Application Issues Tags
  (12, 19), -- payment
  (12, 9), -- customer-impact
  (12, 25), -- latency
  -- Monitoring Issues Tags
  (13, 22), -- alert-system
  (13, 8), -- monitoring
  (13, 5), -- urgent
  -- Cache Issues Tags
  (14, 20), -- cache
  (14, 3), -- performance
  (14, 12), -- software
  -- Load Balancer Issues Tags
  (15, 21), -- load-balancer
  (15, 24), -- failover
  (15, 15); -- availability
