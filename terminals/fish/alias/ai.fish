# Pi quick AI helpers using OpenAI Codex models.
# Use --provider explicitly so pi never falls back to provider matching.
# - q: fast knowledge/questions, read-only/no tools for speed and safety
# - qcode: coding questions with the current directory context and tools enabled
# - qhard: harder reasoning/design questions
function __pi_codex --description 'Run pi with the OpenAI Codex provider'
    set -l model $argv[1]
    set -l thinking $argv[2]
    set -e argv[1..2]

    pi -p --provider openai-codex --model $model --thinking $thinking $argv
end

function q --description 'Ask pi a quick knowledge question using a fast Codex model'
    __pi_codex gpt-5.4-mini low --no-tools (string join ' ' -- $argv)
end

function qcode --description 'Ask pi a coding question using a strong Codex model'
    __pi_codex gpt-5.4 medium (string join ' ' -- $argv)
end

function qhard --description 'Ask pi a harder reasoning/design question using the strongest Codex model'
    __pi_codex gpt-5.5 high (string join ' ' -- $argv)
end
