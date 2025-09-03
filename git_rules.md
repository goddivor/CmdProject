# Git Commit Rules

## Commit Message Format

### Structure
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries

### Subject Rules
- Use imperative mood ("add" not "added" or "adds")
- No dot (.) at the end
- Maximum 50 characters
- Capitalize first letter

### Body (Optional)
- Wrap at 72 characters
- Explain what and why, not how
- Separate from subject with blank line

### Footer (Optional)
- Reference issues: "Closes #123"
- Breaking changes: "BREAKING CHANGE: description"

## Examples
```
feat(auth): add user authentication system

fix: resolve memory leak in data processor

docs: update installation instructions

chore: update dependencies to latest versions
```

## Restrictions

### Co-Authors
- **NEVER** include Co-Authored-By tags in commit messages
- All commits must have a single author only

### External References
- **NO** references to Claude or AI assistance
- **NO** links to claude.ai or related services
- Keep commit messages focused on the technical changes only