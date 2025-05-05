function se
  set -gx OPENAI_API_KEY (pass show openai-secret-key)
  set -gx GEMINI_API_KEY (pass show googleai)
  set -gx FIGMA_ACCESS_TOKEN (pass show figma-wix-key)
end
