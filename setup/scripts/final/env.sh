# export LD_LIBRARY_PATH=$(realpath $TOOLS/klayout/*/ )

#FIXME Fix warning when KLayout starts, maybe there is a cleaner solution
export XDG_RUNTIME_DIR=/tmp/runtime-default
export ATALANTA_MAN=/usr/local/share/atalanta

# export PDK_ROOT=/foss/pdk # set in dockerfile
# export TOOLS=/foss/tools # set in dockerfile
# export DESIGNS=/foss/designs # set in dockerfile
export PDK=sky130A
export PDKPATH=$PDK_ROOT/$PDK
export STD_CELL_LIBRARY=sky130_fd_sc_hd
export OPENLANE_ROOT=$TOOLS/openlane

export EDITOR='gedit'

#FIXME this is a WA until better solution is found for OpenLane version check
export MISMATCHES_OK=1

#----------------------------------------
# Tool Aliases
#----------------------------------------

alias magic='magic -d XR -rcfile $PDKPATH/libs.tech/magic/$PDK.magicrc'

# alias k='klayout -c $SAK/klayout/tech/sky130A/sky130A.krc -nn $PDKPATH/libs.tech/klayout/sky130A.lyt -l $PDKPATH/libs.tech/klayout/sky130A.lyp'
# alias ke='klayout -e -c $SAK/klayout/tech/sky130A/sky130A.krc -nn $PDKPATH/libs.tech/klayout/sky130A.lyt -l $PDKPATH/libs.tech/klayout/sky130A.lyp'
# alias kf='klayout -c $SAK/klayout/tech/sky130A/sky130A.krc -nn $PDKPATH/libs.tech/klayout/sky130A.lyt -l $PDKPATH/libs.tech/klayout/sky130A-fom.lyp'

alias xschem='xschem --rcfile $PDKPATH/libs.tech/xschem/xschemrc'

alias tt='cd /foss/tools'
alias dd='cd /foss/designs'
alias pp='cd /foss/pdk'
alias destroy='sudo \rm -rf'
alias cp='cp -i'
alias egrep='egrep '
alias fgrep='fgrep '
alias grep='grep '
alias l.='ls -d .* '
alias ll='ls -l'
alias la='ls -al '
alias llt='ls -lt'
alias llta='ls -alt'
alias du='du -skh'
alias mv='mv -i'
alias rm='rm -i'
alias vrc='vi ~/.bashrc'
alias dux='du -sh* | sort -h'
alias shs='md5sum'
alias h='history'
alias hh='history | grep'
alias rc='source ~/.bashrc'
alias m='less'

#----------------------------------------
# Git
#----------------------------------------

alias gcl='git clone'
alias gcll='git clone --single-branch --depth=1'
alias ga='git add'
alias gc='git commit -a'
alias gps='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gss='git status'
alias gr='git remote -v'
alias gl='git log'
alias gln='git log --name-status'
alias gsss='git submodule status'

# From libnss_wrapper.sh
# source $STARTUPDIR/scripts/generate_container_user

# Change default directory
cd /asic/designs

echo "Sourced .bashrc"