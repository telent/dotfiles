if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

source ~/.local-paths

LS_COLOURS=":ex=1;34:*README=30;46:*.o=33:*.gz=31:*.zip=31"
LESSOPEN="|gzip -cdf --stdout %s"
AUTHORCOPY=$HOME/Mail/sent
VISUAL=vi
EDITOR=$VISUAL
export LS_COLOURS LESSOPEN PATH LESSCHARSET AUTHORCOPY REPLYTO TEXINPUTS VISUAL EDITOR GEM_HOME

umask 002

if [ x$TERM = xxterm ] || [ x$TERM = xxterm-color ] ; then
  export PS1='\[\e]0;\u@\h:\w/\007\]\[\e[1;32m\]:;\[\e[0m\] '
else
  export  PS1="$ "
fi

function e { 	emacsclient $* ; }
function bx { bundle exec $*; }

function xp { kvm -net user -net nic,model=e1000 -smb /big/ -soundhw es1370,ac97  -m 512 -hdc ~/xp.qcow2  -hdd ~/drived.qcow ; }

test -f /etc/profile.d/chruby.sh && . /etc/profile.d/chruby.sh
