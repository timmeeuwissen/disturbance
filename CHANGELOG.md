# Changelog

All notable changes to this project will be documented in this file.
## [2025-01-16]

- Added database fixtures and reset functionality:n- Added sample data fixtures for all tablesn- Added script to load fixturesn- Added script to reset database with confirmationn- Added make targets for database management

## [2025-01-16]

- Added list sorting functionality:n- Added sort_order field to list tablesn- Added drag and drop sorting UIn- Added API endpoint for updating sort ordern- Updated list display to respect sort ordern- Replaced toggles with chips for better UX

## [2025-01-16]

- Added default value support to new issue page:n- Added useLists composable for managing lists and defaultsn- Updated new issue page to use default valuesn- Added proper type definitionsn- Added error handling

## [2025-01-16]

- Added default value support to new issue page:n- Added useLists composable for managing lists and defaultsn- Updated new issue page to use default valuesn- Added proper type definitionsn- Added error handling

## [2025-01-16]

- Fixed database initialization:n- Added execute permissions to init-db scriptn- Initialized database with new schema including default valuesn- Added triggers for default value management

## [2025-01-16]

- Added default value support for lists:n- Added default flag to database scheman- Added triggers to ensure single default per typen- Updated API endpoints to handle default valuesn- Added UI controls for managing default values

## [2025-01-16]

- Added list management functionality:n- Added API endpoints for managing statuses, severities, and reference typesn- Implemented list management UI with CRUD operationsn- Added support for final status flagn- Added proper error handling and feedback

## [2025-01-16]

- Fixed admin toggle functionality:n- Updated layout to use proper v-model bindingn- Fixed composable to handle toggle correctlyn- Improved state management interaction

## [2025-01-16]

- Fixed Pinia configuration:n- Added proper module configurationn- Fixed auto-imports setupn- Added TypeScript strict mode

## [2025-01-16]

- Migrated admin state management to Pinia:n- Added Pinia store for admin staten- Updated useAdmin composable to use Pinia storen- Added persistence for admin staten- Improved index page with conditional admin section

## [2025-01-16]

- Fixed SQL admin page performance issues:n- Added proper lazy loading for heavy componentsn- Improved error handling and retry logicn- Added loading states and error boundariesn- Fixed component initialization issues

## [2025-01-16]

- Improved SQL admin page performance by adding lazy loading for components, optimized Monaco editor and ERD diagram initialization

## [2025-01-16]

- Split enumerations into separate tables (severities, statuses, reference_types), added isFinal flag to statuses, improved type safety across components

## [2025-01-16]

- Improved type safety by using proper enums for status and severity values, added value handling helpers

## [2025-01-16]

- Added zoom and pan controls to ERD diagram, improved SQL editor, and made admin UI more organized with collapsible cards

## [2025-01-16]

- Fixed schema parsing to generate valid Mermaid ERD syntax

## [2025-01-16]

- Fixed ERD diagram generation with proper Mermaid syntax and improved schema parsing

## [2025-01-16]

- Added dynamic ERD diagram generation from database schema file

## [2025-01-16]

- Enhanced database schema visualization with interactive ERD diagram using Mermaid.js

## [2025-01-16]

- Updated documentation to include admin features, database schema changes, and new functionality

## [2025-01-16]

- Added admin pages for SQL database management and system lists configuration

## [2025-01-16]

- Added SQLite3 dependency for database operations

## [2025-01-16]

- Added dependencies for SQL editor, database visualization, and state management

## [2025-01-16]

- Made report timestamp immutable and automatically set to current time when creating new issues

## [2025-01-16]

- Added communication logs section and made timestamps optional except when status is resolved

## [2025-01-16]

- Fixed array syntax in analytics page v-select components

## [2025-01-16]

- Fixed pug template array syntax in v-select components

## [2025-01-16]

- Updated Vuetify configuration to work with client-side rendering

## [2025-01-16]

- Added Vuetify, Sass, and Vite plugin for Vuetify

## [2025-01-16]

- Added Vuetify, Material Design Icons, and Nuxt Vuetify module dependencies

## [2025-01-15]

- Disabled SSR globally to fix Vuetify form component issues

## [2025-01-15]

- Fixed Vue script setup exports and script language type consistency

## [2025-01-15]

- Updated Vue template configuration for proper pug handling

## [2025-01-15]

- Updated Vite configuration to show error overlay and improve logging

## [2025-01-15]

- Updated git-commit.sh and update-changelog.sh to accept command line arguments

## [2025-01-15]

- Working on adding pug

## [2025-01-15]

- 


## [2024-01-15]

### Added
- Initial project setup with Nuxt 3
- Database schema for issues, references, impacted systems, and teams
- Frontend pages:
  - New issue form with comprehensive fields
  - Issues overview with filtering and export
  - Analytics dashboard with metrics and charts
- API endpoints:
  - CRUD operations for issues
  - Export functionality with multiple templates
- SQLite database integration
- Makefile for common operations
- Git and changelog automation scripts
