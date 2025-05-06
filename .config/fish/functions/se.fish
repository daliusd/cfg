function se
  set -Ux OPENAI_API_KEY (pass show openai-secret-key)
  set -Ux GEMINI_API_KEY (pass show googleai)
  set -Ux FIGMA_ACCESS_TOKEN (pass show figma-wix-key)
end
