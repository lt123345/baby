#!/bin/bash
# Stop hook：结束回答前确保改动已 commit & push（CLAUDE.md「信息自动记录」约定）。
# 退出码语义：0=放行，2=阻止结束并把 stderr 反馈给 Claude。

input=$(cat)

# 防死循环：本轮已因本 hook 续过一次，就不再拦第二次，
# 避免提交失败（如 pull -r 冲突）时反复阻塞。
active=$(printf '%s' "$input" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active", False))' 2>/dev/null)
if [ "$active" = "True" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR" || exit 0

if [ -n "$(git status --porcelain)" ]; then
  echo "未提交改动：$(git status --porcelain | head -5)。按 CLAUDE.md「信息自动记录」约定，现在执行 git add + commit + push（push 被拒先 git pull -r）。若是无关的临时文件则忽略本提示。" >&2
  exit 2
fi

upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
if [ -n "$upstream" ] && [ -n "$(git log "$upstream"..HEAD --oneline 2>/dev/null)" ]; then
  echo "有本地提交未 push：$(git log "$upstream"..HEAD --oneline | head -5)。现在执行 git push（被拒先 git pull -r）。" >&2
  exit 2
fi

exit 0
