function se
  set -Ux SENTRY_AUTH_TOKEN (pass show sentry-token)
end
