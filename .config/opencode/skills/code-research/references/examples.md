# Worked Examples

This file contains detailed worked examples for common code research scenarios using the GitHub CLI.

## Example 1: How does React useState work internally?

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

## Example 2: Find authentication best practices

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

## Example 3: Discover TypeScript CLI frameworks

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

## Example 4: Debug payment webhook failure

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

## Example 5: Compare state management libraries

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

## Example 6: Trace error handling patterns

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
