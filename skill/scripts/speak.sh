#!/usr/bin/env bash
# speak.sh — speak a line aloud for the system-design skill.
#
# Usage:
#   speak.sh [--voice=<macos-voice>] [--role=<label>] [--engine=say|elevenlabs] "text"
#   echo "text" | speak.sh --voice=Samantha --role=secondary
#   speak.sh --check [--engine=elevenlabs] [--roles=primary,secondary]   # preflight, no speech
#
# Two independent voice selectors, one per engine:
#   - Native `say` uses --voice: a real macOS voice name (e.g. Daniel, Samantha).
#   - ElevenLabs ignores --voice and picks a voice id by --role, in this order:
#       ELEVENLABS_VOICE_<ROLE>   (role upper-cased, e.g. ELEVENLABS_VOICE_PRIMARY)
#       ELEVENLABS_VOICE_ID       (single voice for everything)
#       built-in per-role default (primary and secondary differ — see below)
#     The two-speaker `learn --auto` dialog uses role `primary` (interviewer) and
#     `secondary` (candidate); the built-in defaults are already two distinct
#     ElevenLabs voices, so it works with no setup. Override either with
#     ELEVENLABS_VOICE_PRIMARY / ELEVENLABS_VOICE_SECONDARY. Single-speaker modes use `primary`.
#
# --check validates the chosen engine before a session: confirms the API key is
# present AND accepted by ElevenLabs (live HTTP 200), and that each requested
# role resolves to a distinct voice id. Prints copy-paste export guidance and a
# final `STATUS: ready|needs-key|needs-voices` line. Exit 0 ready / 2 voices / 3 key.
#
# Behavior notes:
#   - The text is sanitized before speaking: fenced ``` blocks (ASCII / mermaid
#     diagrams), markdown tables, stray ASCII-art lines, and inline markdown are
#     removed so only the spoken prose is read — the words stay verbatim.
#   - Intended use: pipe the EXACT turn you displayed in via stdin
#     (printf '%s' "$turn" | speak.sh ...) so screen and audio share one source.
#   - Speaking is synchronous by default (you hear turns in order). Set
#     SD_SAY_ASYNC=1 to background it.
#   - TTS must never break an interview: every failure path exits 0.

set -uo pipefail

# Built-in per-role ElevenLabs defaults — distinct so two speakers differ with no setup.
el_default_for_role() {
  case "$(printf '%s' "${1:-primary}" | tr '[:upper:]' '[:lower:]')" in
    secondary) echo "56AoDkrOh6qfVPDXZ7Pt" ;;
    *)         echo "UgBBYS2sOqTuMpoF3BR0" ;;   # primary / unknown
  esac
}

voice="${SD_SAY_VOICE:-Daniel}"
role=""
engine=""
check=0
roles_csv=""
args=()

for a in "$@"; do
  case "$a" in
    --voice=*)  voice="${a#--voice=}" ;;
    --role=*)   role="${a#--role=}" ;;
    --roles=*)  roles_csv="${a#--roles=}" ;;
    --engine=*) engine="${a#--engine=}" ;;
    --check)    check=1 ;;
    *)          args+=("$a") ;;
  esac
done

upper() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | tr -c 'A-Z0-9' '_'; }

# Remove everything non-speakable while keeping the prose verbatim (no paraphrase):
# fenced code/diagram blocks, markdown tables, stray ASCII-art lines, and inline
# markdown (bold, code, headers, blockquotes, bullets, links, arrow glyphs).
sanitize_for_speech() {
  # LC_ALL=C: treat input as bytes so UTF-8 (em dashes, smart quotes) passes
  # through untouched — macOS awk/sed otherwise abort on multibyte chars.
  LC_ALL=C awk '
    /^[[:space:]]*```/ { infence = !infence; next }   # fenced code / diagram block
    infence { next }
    BEGIN { draw="|+<>^v=-_/\\" }
    {
      line=$0; t=line; sub(/^[[:space:]]+/,"",t)
      if (t ~ /^\|/) next                              # markdown table row
      letters=0; nonspace=0; hasdraw=0; n=length(line)
      for (i=1;i<=n;i++){ c=substr(line,i,1)
        if (c ~ /[A-Za-z]/) letters++
        if (c !~ /[[:space:]]/) nonspace++
        if (index(draw,c)>0) hasdraw=1
      }
      # drop lines that are mostly drawing chars with little text (unfenced ASCII art)
      if (nonspace>0 && letters*10 < nonspace*3 && hasdraw) next
      print line
    }
  ' \
  | LC_ALL=C sed -E \
      -e 's/`([^`]*)`/\1/g' \
      -e 's/\*\*([^*]*)\*\*/\1/g' \
      -e 's/\[([^][]+)\]\([^()]+\)/\1/g' \
      -e 's/^[[:space:]]*#+[[:space:]]*//' \
      -e 's/^[[:space:]]*>[[:space:]]*//' \
      -e 's/^[[:space:]]*[-*+][[:space:]]+//' \
      -e 's/×/ times /g' \
      -e 's/−/ minus /g' \
      -e 's/÷/ divided by /g' \
      -e 's/≈/ approximately /g' \
      -e 's/≤/ at most /g' \
      -e 's/≥/ at least /g' \
      -e 's/≠/ not equal to /g' \
      -e 's/→/ then /g' \
      -e 's/·/ /g' \
      -e 's/[<>=-]{2,}/ /g' \
      -e 's/[*_`]//g'
}

# Resolve an ElevenLabs voice id for a role into globals _RID (id) and _RSRC (source label).
el_resolve() {
  local r="$1" key val
  if [[ -n "$r" ]]; then
    key="ELEVENLABS_VOICE_$(upper "$r")"; val="${!key:-}"
    if [[ -n "$val" ]]; then _RID="$val"; _RSRC="$key"; return; fi
  fi
  if [[ -n "${ELEVENLABS_VOICE_ID:-}" ]]; then _RID="${ELEVENLABS_VOICE_ID}"; _RSRC="ELEVENLABS_VOICE_ID (shared)"; return; fi
  _RID="$(el_default_for_role "$r")"; _RSRC="built-in default (${r:-primary})"
}

# ---- --check: preflight, no speech. Safe to run anytime; spends no TTS characters.
if [[ $check -eq 1 ]]; then
  eng="$engine"
  [[ -z "$eng" ]] && { [[ -n "${ELEVENLABS_API_KEY:-}" ]] && eng="elevenlabs" || eng="say"; }
  if [[ "$eng" != "elevenlabs" ]]; then
    echo "engine: native macOS \`say\` (no API key required)"
    echo "STATUS: ready"
    exit 0
  fi
  echo "engine: elevenlabs"
  command -v curl >/dev/null 2>&1 || echo "  [x] curl not found — cannot reach ElevenLabs."
  if [[ -z "${ELEVENLABS_API_KEY:-}" ]]; then
    echo "  [x] ELEVENLABS_API_KEY is NOT set."
    echo ""
    echo "  Add to ~/.zshrc (then open a new session, or re-run this check):"
    echo "    export ELEVENLABS_API_KEY=\"sk_...\"          # from elevenlabs.io -> API Keys"
    echo "    export ELEVENLABS_VOICE_ID=\"<voice-id>\"      # one voice for everything, OR:"
    echo "    export ELEVENLABS_VOICE_PRIMARY=\"<id>\"       # learn --auto interviewer (single-voice modes too)"
    echo "    export ELEVENLABS_VOICE_SECONDARY=\"<id>\"     # learn --auto candidate"
    echo "  List your voice IDs:"
    echo "    curl -s -H \"xi-api-key: \$ELEVENLABS_API_KEY\" https://api.elevenlabs.io/v1/voices | jq -r '.voices[] | \"\\(.name)\\t\\(.voice_id)\"'"
    echo "STATUS: needs-key"
    exit 3
  fi
  echo "  [ok] ELEVENLABS_API_KEY is set"
  if command -v curl >/dev/null 2>&1; then
    code="$(curl -s -o /dev/null -w '%{http_code}' -H "xi-api-key: ${ELEVENLABS_API_KEY}" https://api.elevenlabs.io/v1/user 2>/dev/null || echo 000)"
    case "$code" in
      200) echo "  [ok] key validated with ElevenLabs (HTTP 200)" ;;
      401|403) echo "  [x] key rejected by ElevenLabs (HTTP $code) — wrong or expired key."; echo "STATUS: needs-key"; exit 3 ;;
      000) echo "  [!] could not reach ElevenLabs (offline?) — will fall back to native \`say\` at runtime." ;;
      *) echo "  [!] unexpected response from ElevenLabs (HTTP $code)." ;;
    esac
  fi
  IFS=',' read -ra _rl <<< "${roles_csv:-${role:-primary}}"
  seen=" "; dup=0; n=0
  for r in "${_rl[@]}"; do
    [[ -z "$r" ]] && continue
    n=$((n+1)); el_resolve "$r"
    echo "  role '$r' -> $_RSRC"
    [[ "$seen" == *" $_RID "* ]] && dup=1
    seen="$seen$_RID "
  done
  if [[ $n -gt 1 && $dup -eq 1 ]]; then
    echo "  [!] multiple roles resolve to the SAME voice — they will sound identical."
    echo "      give each role a distinct id:"
    for r in "${_rl[@]}"; do
      [[ -z "$r" ]] && continue
      echo "        export ELEVENLABS_VOICE_$(upper "$r")=\"<voice-id>\""
    done
    echo "STATUS: needs-voices"
    exit 2
  fi
  echo "STATUS: ready"
  exit 0
fi

# ---- speak path
# Text comes from positional args, or stdin if none were given.
if [[ ${#args[@]} -gt 0 ]]; then
  text="${args[*]}"
else
  text="$(cat 2>/dev/null || true)"
fi

# Strip non-speakable content (diagrams, tables, markdown), then collapse whitespace.
text="$(printf '%s\n' "$text" | sanitize_for_speech | tr -s '[:space:]' ' ')"
text="${text#"${text%%[![:space:]]*}"}"   # ltrim

# Nothing left to say (e.g. a turn that was only a diagram) — succeed quietly.
[[ -z "$text" ]] && exit 0

# Resolve engine.
if [[ -z "$engine" ]]; then
  if [[ -n "${ELEVENLABS_API_KEY:-}" ]]; then engine="elevenlabs"; else engine="say"; fi
fi

run() {
  if [[ "${SD_SAY_ASYNC:-0}" == "1" ]]; then "$@" >/dev/null 2>&1 & else "$@" >/dev/null 2>&1; fi
}

case "$engine" in
  elevenlabs)
    if [[ -z "${ELEVENLABS_API_KEY:-}" ]] || ! command -v curl >/dev/null 2>&1; then
      run say -v "$voice" "$text"; exit 0   # fall back to native
    fi
    el_resolve "$role"
    vid="$_RID"
    out="$(mktemp -t sd-speak).mp3"
    if command -v jq >/dev/null 2>&1; then body="$(jq -Rn --arg t "$text" '{text:$t, model_id:"eleven_turbo_v2_5"}')"
    else body="{\"text\":\"$(printf '%s' "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')\",\"model_id\":\"eleven_turbo_v2_5\"}"; fi
    if curl -sS -X POST "https://api.elevenlabs.io/v1/text-to-speech/${vid}" \
         -H "xi-api-key: ${ELEVENLABS_API_KEY}" -H "Content-Type: application/json" \
         -d "$body" --output "$out" && [[ -s "$out" ]]; then
      run afplay "$out"
    else
      run say -v "$voice" "$text"          # network/auth failure -> native
    fi
    ;;
  *)
    command -v say >/dev/null 2>&1 && run say -v "$voice" "$text"
    ;;
esac

exit 0
