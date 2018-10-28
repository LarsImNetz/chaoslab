# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="b46227dcb6" # Change this when you update the ebuild
EGO_PN="github.com/junegunn/fzf"
# Note: Keep EGO_VENDOR in sync with glide.lock
# Deps that are not needed:
# github.com/codegangsta/cli c6af8847eb
# github.com/gdamore/encoding b23993cbb6
# github.com/gdamore/tcell 0a0db94084
# github.com/lucasb-eyer/go-colorful c900de9dbb
# github.com/Masterminds/semver 15d8430ab8
# github.com/Masterminds/vcs 6f1c6d1505
# github.com/mitchellh/go-homedir b8bc1bf767
# golang.org/x/text 4ee4af5665
# gopkg.in/yaml.v2 287cf08546
EGO_VENDOR=(
	"github.com/mattn/go-isatty 66b8e73f3f"
	"github.com/mattn/go-runewidth 14207d285c"
	"github.com/mattn/go-shellwords 02e3cf038d"
	"golang.org/x/crypto 558b6879de github.com/golang/crypto"
	"golang.org/x/sys b90f89a1e7 github.com/golang/sys"
)

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A general-purpose command-line fuzzy finder"
HOMEPAGE="https://github.com/junegunn/fzf"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie tmux"

RDEPEND="tmux? ( app-misc/tmux )"

DOCS=( {CHANGELOG,README}.md )
QA_PRESTRIPPED="usr/bin/fzf"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X main.revision=${GIT_COMMIT:0:7}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./src{,/algo,/tui,/util} || die
}

src_install() {
	dobin fzf
	doman man/man1/fzf.1
	einstalldocs

	newbashcomp shell/completion.bash fzf

	insinto /usr/share/nvim/runtime/plugin
	doins plugin/fzf.vim

	insinto /usr/share/vim/vimfiles/plugin
	doins plugin/fzf.vim
	dodoc README-VIM.md

	insinto /usr/share/zsh/site-functions
	newins shell/completion.zsh _fzf
	insinto /usr/share/zsh/site-contrib/
	newins shell/key-bindings.zsh fzf.zsh

	if use tmux; then
		dobin bin/fzf-tmux
		doman man/man1/fzf-tmux.1
	fi
}
