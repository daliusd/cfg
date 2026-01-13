---
name: code-research
description: Expert code research using GitHub CLI for repository discovery, code search, and deep analysis
compatibility: opencode
metadata:
  audience: developers
  workflow: research
---

## What I Do

I help you conduct deep code research across GitHub using the GitHub CLI (`gh`). I orchestrate repository discovery, code pattern search, file content retrieval, and PR analysis to answer complex technical questions. Use me to learn from production codebases, discover implementation patterns, and investigate how popular libraries work internally.

## When to Use Me

- **Understanding library internals**: How does React's useState work? How is Redux implemented?
- **Pattern discovery**: Find authentication patterns, error handling strategies, or API design approaches across popular repos
- **Technology research**: Discover and compare TypeScript CLI frameworks, state management libraries, or testing tools
- **Bug investigation**: Search for similar issues and fixes across GitHub to solve your problems
- **Architecture analysis**: Study how successful projects structure their code, handle dependencies, or organize monorepos
- **Learning from production**: Find real-world examples of implementing specific features or solving technical challenges

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

### Example 1: How does React useState work internally?

```bash
# 1. Find React repository
gh repo view facebook/react --json url,stargazersCount

# 2. Search for useState implementation
gh search code "function useState" --repo=facebook/react --limit 5 --json path,repository

# 3. Get file content (e.g., ReactHooks.js)
DOWNLOAD_URL=$(gh api repos/facebook/react/contents/packages/react/src/ReactHooks.js --jq '.download_url')

# 4. Fetch and analyze (use webfetch in OpenCode)
# webfetch $DOWNLOAD_URL

# 5. Search for related implementation files
gh search code "useState" --repo=facebook/react --filename=ReactFiberHooks --limit 3

# Result: Understanding of useState implementation flow across multiple files
```

### Example 2: Find authentication best practices

```bash
# 1. Find popular authentication libraries
gh search repos --topic=authentication,nodejs --stars=">3000" --limit 10 --json name,owner,description,url

# 2. Search for JWT authentication patterns
gh search code "jwt.verify" --language=javascript --stars=">1000" --limit 15 --json repository,path

# 3. Find middleware implementations
gh search code "authentication middleware" --language=typescript --filename=auth --limit 10

# 4. Analyze specific implementation
gh api repos/auth0/node-jsonwebtoken/contents/index.js --jq '.download_url'

# 5. Compare with alternative approaches
gh search code "passport.authenticate" --language=javascript --limit 10

# Result: Collection of authentication patterns from production codebases
```

### Example 3: Discover TypeScript CLI frameworks

```bash
# 1. Search for TypeScript CLI tools
gh search repos --topic=cli,typescript --stars=">2000" --limit 15 --json name,description,url,stargazersCount,owner

# 2. View top framework structure
gh api repos/oclif/oclif/contents --jq '.[] | {name, type}'

# 3. Compare command parsing approaches
gh search code "command parser" --language=typescript --owner=oclif --limit 10
gh search code "command parser" --language=typescript --owner=sindresorhus --limit 10

# 4. Find documentation and examples
gh search code "cli example" --filename=README.md --repo=oclif/oclif

# 5. Get package.json to see dependencies
gh api repos/oclif/oclif/contents/package.json --jq '.download_url'

# Result: Comparison of CLI frameworks with architectural insights
```

### Example 4: Debug payment webhook failure

```bash
# 1. Search for similar webhook issues in popular payment libraries
gh search code "webhook validation failed" --language=typescript --limit 15 --json repository,path

# 2. Find merged PRs about webhook bugs
gh search prs "webhook" --label=bug --merged --created=">2024-01-01" --limit 10 --json title,url,number

# 3. Analyze how Stripe handles webhooks
gh search code "verifyWebhookSignature" --repo=stripe/stripe-node --limit 5

# 4. Get implementation details
gh api repos/stripe/stripe-node/contents/lib/Webhooks.js --jq '.download_url'

# 5. Check for security best practices in PRs
gh search prs "webhook security" --repo=stripe/stripe-node --merged --limit 5
gh pr diff {pr_number} --repo stripe/stripe-node

# Result: Root cause identified and solution from production implementations
```

### Example 5: Compare state management libraries

```bash
# 1. Find popular state management libraries
gh search repos --topic=state-management,react --stars=">5000" --limit 10 --json name,description,url,stargazersCount

# 2. Compare Redux vs Zustand approaches
gh search code "createStore" --repo=reduxjs/redux --limit 5 --json path
gh search code "create(" --repo=pmndrs/zustand --limit 5 --json path

# 3. Get core implementation files
gh api repos/pmndrs/zustand/contents/src/vanilla.ts --jq '.download_url'
gh api repos/reduxjs/redux/contents/src/createStore.ts --jq '.download_url'

# 4. Compare bundle sizes and dependencies
gh api repos/pmndrs/zustand/contents/package.json --jq '.download_url'
gh api repos/reduxjs/redux/contents/package.json --jq '.download_url'

# 5. Check community discussion and adoption
gh search prs "migration" --repo=pmndrs/zustand --limit 10 --json title,body
gh search prs "migration" --repo=reduxjs/redux --limit 10 --json title,body

# Result: Architectural comparison with bundle size, API complexity, and community insights
```

### Example 6: Trace error handling patterns

```bash
# 1. Search for error handling patterns in popular frameworks
gh search code "try catch async" --language=typescript --stars=">5000" --limit 20 --json repository,path

# 2. Find error boundary implementations
gh search code "class ErrorBoundary" --language=typescript --repo=facebook/react --limit 5

# 3. Search for custom error classes
gh search code "extends Error" --language=typescript --stars=">3000" --limit 15 --json repository,path

# 4. Get specific error handling implementation
gh api repos/vercel/next.js/contents/packages/next/src/server/lib/error.ts --jq '.download_url'

# 5. Find PRs discussing error handling improvements
gh search prs "error handling" --repo=vercel/next.js --merged --sort=updated --limit 10 --json title,url,body

# Result: Collection of production-grade error handling patterns and best practices
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
