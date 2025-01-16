# Changelog

All notable changes to this project will be documented in this file.
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
