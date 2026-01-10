# AGENTS.md - Guidelines for AI Coding Agents

This document provides guidelines for AI agents operating in this repository.

## Project Overview

This is a PostgreSQL S3 backup tool consisting of:
- `scripts/pg_s3_backup` - Main bash script for database backups
- `Dockerfile` - Container image definition
- `Justfile` - Build and publish automation

## Build Commands

### Docker Image
```bash
# Build the Docker image
just build

# Tag images (latest, branch, and git tag/commit)
just tag

# Push all tagged images to registry
just push

# Full release (build, tag, push)
just release

# Check what tags will be applied
just all-tags
```

### Manual Docker Commands
```bash
# Build with specific tag
docker build -t regv2.gsingh.io/personal/pg-s3-backup:<tag> .

# Push image
docker push regv2.gsingh.io/personal/pg-s3-backup:<tag>

# Test run container
docker run --rm regv2.gsingh.io/personal/pg-s3-backup:latest --help
```

## Code Style Guidelines

### Bash Scripts (scripts/pg_s3_backup)

**Strict Mode**
- Always start scripts with: `set -euo pipefail`
- Use `#!/bin/bash` shebang

**Variables**
- Use UPPERCASE for constants/config variables
- Use lowercase for local/script variables
- Always quote variables: `"$VAR"` not `$VAR`
- Use `local` for function-scoped variables

**Functions**
- Use explicit `function name() {` syntax
- Keep functions small and single-purpose
- Return exit codes, not values (use globals or echo for output)
- Always validate parameters at function start

**Error Handling**
- Use `trap cleanup EXIT` for cleanup handlers
- Check command exit codes with `if ! cmd; then`
- Print errors to stderr: `echo "Error: ..." >&2`
- Exit with meaningful codes: `exit 1`

**Arrays and Lists**
- Use bash arrays for collections: `files=()`
- Append: `files+=("item")`
- Iterate: `for f in "${files[@]}"; do`
- Check array length: `${#array[@]}`

**Conditionals**
- Use `[[ ]]` for bash conditionals (not `[ ]`)
- String comparison: `[[ "$VAR" == "value" ]]`
- File tests: `[[ -f "$file" ]]`
- Array non-empty: `[[ ${#arr[@]} -gt 0 ]]`

### Dockerfile

**Base Image**
- Use specific tags: `debian:bookworm-slim` (not `debian:latest`)
- Prefer slim variants for minimal images

**Commands**
- Combine RUN commands with `&&` to minimize layers
- Clean up in same layer: `apt-get clean && rm -rf /var/lib/apt/lists/*`
- Use `COPY` for local files, `ADD` only for URLs/tar extraction

**Security**
- Create non-root user if needed
- Don't include secrets in image
- Use specific package versions when possible

### Justfile

**Variables**
- Use double quotes for strings
- Define constants at top
- Shell commands in backticks: `` `git rev-parse --short HEAD` ``

**Recipes**
- Dependencies after colon: `push: tag build`
- Use descriptive names: `release` not `all`
- Prefer tab indentation for recipe body

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Scripts | kebab-case | `pg_s3_backup` |
| Docker images | kebab-case | `pg-s3-backup` |
| Functions | snake_case | `validate_dependencies` |
| Variables | UPPERCASE | `S3_BUCKET` |
| Constants | UPPERCASE | `HOST`, `PORT` |
| Local vars | lowercase | `exit_code` |

## Error Handling Patterns

**Validate Dependencies**
```bash
validate_dependencies() {
    if ! command -v pg_dump >/dev/null 2>&1; then
        echo "Error: pg_dump not found" >&2
        exit 1
    fi
}
```

**Validate Parameters**
```bash
validate_parameters() {
    if [[ -z "$S3_BUCKET" ]]; then
        echo "Error: S3 bucket is required" >&2
        exit 1
    fi
}
```

**Cleanup on Exit**
```bash
CLEANUP_FILES=()

cleanup() {
    local exit_code=$?
    for file in "${CLEANUP_FILES[@]}"; do
        rm -f "$file"
    done
    exit $exit_code
}

trap cleanup EXIT
```

## Security Best Practices

- Never commit secrets or credentials
- Use `.pgpass` file with `chmod 600` for database passwords
- Pass credentials via environment variables, not command-line args
- Use AWS profile or IAM roles when possible instead of access keys

## Testing

### Manual Testing
```bash
# Test script help
./scripts/pg_s3_backup --help

# Test Docker build
just build

# Test container locally
docker run --rm \
    -e AWS_ACCESS_KEY_ID=... \
    -e AWS_SECRET_ACCESS_KEY=... \
    regv2.gsingh.io/personal/pg-s3-backup:latest \
    --bucket test-bucket --dbname testdb
```

### Integration Tests
- Verify backup creates valid SQL file
- Verify S3 upload succeeds
- Verify cleanup removes temporary files
- Test with and without compression
- Test with inline credentials and AWS profile

## Common Tasks

### Adding New Backup Options
1. Add variable declaration at top of script
2. Add argument parsing in `while [[ $# -gt 0 ]]` loop
3. Add validation in `validate_parameters()`
4. Use variable in `perform_backup()` or `upload_to_s3()`

### Updating Dependencies
1. Edit Dockerfile RUN command
2. Test `just build`
3. Update version/tag in Justfile if needed

### Creating Release
1. Ensure all tests pass
2. Create git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
3. Run `just release`
4. Push tags: `git push --tags`
