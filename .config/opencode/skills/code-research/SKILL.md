---
name: code-research
description: Expert code research using GitHub CLI for repository discovery, code search, and deep analysis. Use this skill when you need to: (1) Understand how popular libraries/frameworks work internally, (2) Find implementation patterns across GitHub repositories, (3) Research and compare technologies or libraries, (4) Investigate bugs by searching for similar issues and fixes, (5) Analyze repository architecture and structure, (6) Find real-world code examples, or (7) Analyze pull requests for implementation decisions. Triggers include questions like "How does X work?", "Find examples of Y", "Compare X vs Y libraries", or "Search GitHub for Z pattern".
---

# Code Research with GitHub CLI

## Core Workflows

### 1. Repository Discovery

Find relevant repositories by topics, keywords, and quality metrics.

```bash
# Search by GitHub topics (most precise)
gh search repos --topic=react,hooks --stars=">5000" --json name,description,url,stargazersCount --limit 10

# Search by keywords in name/description
gh search repos "typescript cli framework" --language=typescript --stars=">1000" --limit 10

# Organization repositories
gh search repos --owner=facebook --visibility=public --limit 20

# Sort by recent activity
gh search repos --topic=nextjs --sort=updated --order=desc --limit 10
```

**Key flags**: `--topic`, `--stars`, `--language`, `--owner`, `--sort`, `--limit`

### 2. Code Search

Find specific code patterns, function implementations, or usage examples.

```bash
# Search for implementations
gh search code "useState implementation" --language=typescript --owner=facebook --limit 20

# Search in specific files
gh search code "authentication middleware" --filename=middleware.ts --limit 15

# Search in specific repos
gh search code "error handling" --repo=vercel/next.js --limit 10

# Get JSON output with text matches
gh search code "useCallback" --language=typescript --json repository,path,textMatches --limit 10
```

**Key flags**: `--language`, `--filename`, `--repo`, `--owner`, `--extension`, `--limit`

### 3. File Content Retrieval

Read file contents from GitHub repositories.

```bash
# Step 1: Get file download URL via GitHub API
DOWNLOAD_URL=$(gh api repos/facebook/react/contents/packages/react/src/ReactHooks.js --jq '.download_url')

# Step 2: Fetch content using webfetch (in OpenCode) or curl
# In agent context, use: webfetch with the download URL
curl -s "$DOWNLOAD_URL"

# Or read specific sections by line numbers after fetching
# Use read tool with line ranges for efficiency
```

**Alternative - Get content directly**:
```bash
gh api repos/facebook/react/contents/packages/react/src/ReactHooks.js --jq '.content' | base64 -d
```

### 4. Pull Request Analysis

Find PRs, analyze changes, and understand implementation decisions.

```bash
# Search merged PRs with specific labels
gh search prs --repo=vercel/next.js --merged --label=bug --limit 10 --json title,number,url,body

# Get specific PR details
gh pr view 12345 --repo vercel/next.js --json title,body,files,comments

# View PR diff to see actual changes
gh pr diff 12345 --repo vercel/next.js

# Search PRs by author or date
gh search prs --author=gaearon --repo=facebook/react --merged --created=">2024-01-01" --limit 10
```

**Key flags**: `--merged`, `--label`, `--author`, `--state`, `--created`, `--repo`

### 5. Repository Structure

Explore directory structure and file organization.

```bash
# List root directory contents
gh api repos/facebook/react/contents --jq '.[] | {name, type, path, size}'

# List specific directory
gh api repos/facebook/react/contents/packages --jq '.[] | select(.type=="dir") | .name'

# Get repository metadata
gh repo view facebook/react --json name,description,stargazersCount,language,topics,homepageUrl

# For deeper structure exploration, clone and use task explore agent
git clone --depth=1 https://github.com/facebook/react.git /tmp/react-explore
# Then use: task explore agent on /tmp/react-explore
```

## Tools Quick Reference

- **`gh search repos`** - Find repositories by topics, keywords, stars, language
- **`gh search code`** - Search code patterns across GitHub with file/language filters
- **`gh search prs`** - Find pull requests by state, labels, authors, dates
- **`gh api repos/{owner}/{repo}/contents/{path}`** - Get file metadata and download URLs
- **`gh repo view {owner}/{repo}`** - Get repository overview and metadata
- **`gh pr view/diff {number}`** - Analyze specific pull request changes
- **`webfetch {url}`** - Fetch raw file content from GitHub URLs
- **`task explore`** - Deep local codebase analysis (after cloning)
- **`grep`, `read`** - Analyze fetched content locally

## Worked Examples

For detailed worked examples covering common research scenarios, see [references/examples.md](references/examples.md):

- **Example 1**: Understanding library internals (React useState)
- **Example 2**: Finding authentication best practices
- **Example 3**: Discovering TypeScript CLI frameworks
- **Example 4**: Debugging webhook failures
- **Example 5**: Comparing state management libraries
- **Example 6**: Tracing error handling patterns

### Quick Example: Find React's useState implementation

```bash
# 1. Search for useState implementation
gh search code "function useState" --repo=facebook/react --limit 5 --json path,repository

# 2. Get file content
DOWNLOAD_URL=$(gh api repos/facebook/react/contents/packages/react/src/ReactHooks.js --jq '.download_url')

# 3. Fetch and analyze (use webfetch tool)
# webfetch $DOWNLOAD_URL

# 4. Search for related implementation files
gh search code "useState" --repo=facebook/react --filename=ReactFiberHooks --limit 3
```

## Best Practices

- **Start broad, then narrow**: Use `gh search repos` first, then drill down with `gh search code`
- **Use topics over keywords**: Topics are curated and more precise than free-text search
- **Filter by stars**: Add `--stars=">1000"` to find quality, maintained projects
- **Limit results**: Use `--limit` to avoid overwhelming output; iterate with refined queries
- **Check language filters**: Always specify `--language` for code search to reduce noise
- **Use JSON output**: Add `--json` flag for structured data you can parse programmatically
- **Fetch selectively**: Don't fetch entire files; use line ranges or pattern matching with `read` tool
- **Clone for deep analysis**: For complex exploration, clone repo and use `task explore` agent
- **Respect rate limits**: GitHub search has 10 requests/min; space out queries if hitting limits
- **Combine with local tools**: Use `grep`, `read`, `task` on fetched content for deeper analysis

## Limitations

- **Rate limits**: GitHub search API allows ~10 requests/minute for authenticated users
- **Legacy search**: GitHub Code Search uses older engine; regex and advanced syntax not yet available via API
- **Sequential processing**: No bulk parallel queries like octocode-mcp; execute commands sequentially
- **Content size**: Large files may need truncation; fetch specific sections when possible
- **No package search**: Cannot search npm/PyPI directly; use repository search as workaround
- **Repository structure**: Need multiple API calls to explore deep directory trees; clone for comprehensive exploration

## Workarounds

- **Rate limits**: Use `--limit` to reduce calls; cache results; spread queries over time
- **Bulk operations**: Write bash loops for multiple queries if needed
- **Large files**: Use `gh api` to get file size first, fetch only needed sections via line ranges
- **Deep structure**: Clone repositories to `/tmp` for comprehensive local analysis with `task explore`
- **Package discovery**: Search repos by package name, then check package.json for dependencies
