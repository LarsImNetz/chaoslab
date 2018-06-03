# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Generated with:
# curl -s 'https://raw.githubusercontent.com/lotabout/skim/v0.4.0/Cargo.lock' | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.4
ansi_term-0.10.2
atty-0.2.3
bitflags-1.0.1
byteorder-1.2.3
bytes-0.4.8
cfg-if-0.1.3
clap-2.28.0
env_logger-0.4.3
gcc-0.3.54
iovec-0.1.2
kernel32-sys-0.2.2
lazy_static-0.2.11
libc-0.2.42
log-0.3.8
memchr-2.0.1
nix-0.10.0
redox_syscall-0.1.32
redox_termios-0.1.1
regex-0.2.3
regex-syntax-0.4.1
shlex-0.1.1
strsim-0.6.0
termion-1.5.1
textwrap-0.9.0
thread_local-0.3.4
time-0.1.38
unicode-width-0.1.4
unreachable-1.0.0
utf8-ranges-1.0.0
vec_map-0.8.0
void-1.0.2
winapi-0.2.8
winapi-build-0.1.1
"

inherit bash-completion-r1 cargo

DESCRIPTION="Fuzzy finder in Rust"
HOMEPAGE="https://github.com/lotabout/skim"
# shellcheck disable=SC2086
SRC_URI="https://github.com/lotabout/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion tmux vim zsh-completion"

DEPEND=">=virtual/rust-1.23.0"
RDEPEND="tmux? ( app-misc/tmux )
	vim? ( || ( app-editors/vim app-editors/gvim ) )
	zsh-completion? ( app-shells/zsh )"

DOCS=( CHANGELOG.md README.md )

src_test() {
	cargo test || die "tests failed"
}

src_install() {
	cargo_src_install
	einstalldocs

	use tmux && dobin bin/sk-tmux

	if use bash-completion; then
		newbashcomp shell/completion.bash skim
		insinto /etc/profile.d/
		newins shell/key-bindings.bash skim.sh
fi

	if use vim; then
		insinto /usr/share/vim/vimfiles/plugin
		doins plugin/skim.vim
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins shell/completion.zsh _skim
		insinto /usr/share/zsh/site-contrib/
		newins shell/key-bindings.zsh skim.zsh
	fi
}
