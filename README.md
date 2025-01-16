# Disturbance Monitoring System

A system for tracking and analyzing system outages and incidents.

## Features

- Create and manage incident reports
- Track incident status, severity, and resolution progress
- Record impacted systems and involved teams
- Export incident data in various formats
- Analytics dashboard with key metrics
- Detailed incident history and timeline
- Admin mode with database management and system configuration
- Tag-based incident categorization

## Setup

1. Install dependencies:
```bash
make install
```

2. Initialize the database:
```bash
make init-db
```

3. Start the development server:
```bash
make dev
```

The application will be available at http://localhost:3000

## Project Structure

- `/pages` - Frontend pages (New Issue, Issues Overview, Analytics, Admin)
- `/server` - Backend API and database services
- `/db` - Database schema and migrations
- `/types` - TypeScript type definitions
- `/assets` - Styles and other assets
- `/scripts` - Utility scripts for development
- `/components` - Reusable Vue components
- `/composables` - Vue composables for shared logic

## Database Schema

### Issues Table
- Main incident information
- Status tracking
- Timestamps for incident lifecycle

### References Table
- Links to external resources (Jira, Slack, etc.)
- Associated with specific incidents

### Impacted Systems Table
- Systems affected by incidents
- Impact descriptions

### Involved Teams Table
- Teams working on incident resolution
- Team roles and responsibilities

### Communication Logs Table
- Timeline of communications during incidents
- Internal and external communication tracking
- Links to communication sources

### Tags Table
- Custom incident categorization
- Color-coded tags with definitions
- Many-to-many relationship with issues

### Enumerations Table
- System-wide lists management
- Configurable values for dropdowns
- Categories: severity, status, reference types

## Admin Features

### SQL Administration
- Real-time database schema visualization (ERD)
- SQL query editor with syntax highlighting
- Query results in sortable table format
- Export query results to CSV
- Read-only access (destructive queries prevented)

### Lists Management
- Manage system-wide enumerations
- Configure dropdown options for forms
- Active/inactive status control
- Sort order customization

### Tag Management
- Create and edit issue tags
- Define tag meanings and descriptions
- Customize tag colors
- Visual preview of tag appearance

## Available Commands

- `make dev` - Start development server
- `make build` - Build for production
- `make init-db` - Initialize/reset database
- `make install` - Install dependencies
- `make clean` - Clean build artifacts
- `make git-commit` - Commit changes with changelog update

## API Endpoints

### GET /api/issues
Get all issues with optional filtering

### POST /api/issues
Create a new issue

### GET /api/issues/:id
Get a specific issue by ID

### PUT /api/issues/:id
Update an existing issue

### POST /api/issues/export
Export issues in CSV or JSON format with different templates:
- Full details
- Summary view
- Metrics only

### POST /api/admin/sql
Execute read-only SQL queries (admin only)

## Contributing

1. Create a feature branch
2. Make your changes
3. Update the changelog using `make update-changelog`
4. Commit changes using `make git-commit`
5. Create a pull request

## License

MIT
