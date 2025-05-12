# Contributing

This document outlines how to contribute to the DB Performance Monitoring Suite. We welcome contributions from everyone who is interested in improving database performance monitoring.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a new branch** for your feature or bug fix
4. **Make your changes** and commit them with clear messages
5. **Push your branch** to your fork
6. **Submit a pull request** to the main repository

## Development Guidelines

### Code Style

- Follow the existing code style in the repo
- For shell scripts:
  - Use meaningful variable names (all caps for global variables)
  - Add comments for complex logic
  - Include error handling where appropriate

### Testing

Before submitting changes, please test your scripts:

1. Run on at least one test database
2. Verify that the HTML report generates correctly
3. Check for syntax errors using:
   ```bash
   # For shell scripts
   shellcheck script_name.sh
   ```

### Documentation

- Update the documentation when adding new features
- Document any new metrics or sections added to the reports
- Keep the README and MkDocs documentation in sync

## Feature Requests

When requesting new features:

1. Check existing issues to avoid duplicates
2. Clearly describe the problem the feature would solve
3. If possible, outline a proposed implementation approach

## Bug Reports

When reporting bugs:

1. Specify the script version
2. Describe your environment (OS, database version)
3. Include steps to reproduce the issue
4. If possible, share the error output (with sensitive information redacted)

## Review Process

All pull requests will be reviewed by the maintainers. We aim to:

1. Provide feedback within one week
2. Focus on code quality and maintainability
3. Ensure new features align with the project's goals
4. Verify that changes don't break existing functionality

## Releasing

The release process is managed by the project maintainers:

1. Version numbers follow semantic versioning (MAJOR.MINOR.PATCH)
2. Release notes document all significant changes
3. New versions are tagged in the repository

## Communication

For questions or discussions:

- Open an issue for technical questions
- Contact the project maintainers directly for sensitive matters

## Code of Conduct

Please be respectful and constructive in all communications related to this project. We aim to foster an inclusive and welcoming community.
