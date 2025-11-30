#!/usr/bin/env zsh

# Minimal typewritten-style prompt for zsh / oh-my-zsh

local return_status="%(?:%F{green}❯%f:%F{red}❯%f)"

ZSH_THEME_GIT_PROMPT_PREFIX="%F{blue} %f"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%F{cyan}%n%f at %F{magenta}%m%f in %F{yellow}%~%f $(git_prompt_info)
${return_status} '

RPROMPT='%F{242}%*%f'

