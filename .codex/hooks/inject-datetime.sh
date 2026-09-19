#!/bin/bash
# UserPromptSubmit hook：每轮注入当前时间，避免长会话/跨天用陈旧日期。
# stdout 会被加进 Claude 的上下文；exit 0 放行。
cat >/dev/null   # 吃掉 stdin，避免上游写管道时 EPIPE
week=(日 一 二 三 四 五 六)
printf '当前时间：%s 周%s（会话开头注入的 currentDate 可能已过期，以本行为准）\n' \
  "$(date '+%Y-%m-%d %H:%M')" "${week[$(date +%w)]}"
exit 0
