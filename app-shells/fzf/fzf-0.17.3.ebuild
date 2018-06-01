# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="390b496" # Change this when you update the ebuild
EGO_PN="github.com/junegunn/fzf"
# Note: Keep EGO_VENDOR in sync with glide.lock
# Deps that are not needed:
# github.com/bjwbell/gensimd 06eb182
# github.com/codegangsta/cli c6af884
# github.com/gdamore/encoding b23993c
# github.com/gdamore/tcell 0a0db94
# github.com/lucasb-eyer/go-colorful c900de9
# github.com/Masterminds/semver 15d8430
# github.com/Masterminds/vcs 6f1c6d1
# github.com/mengzhuo/intrinsic 34b8008
# github.com/mitchellh/go-homedir b8bc1bf
# github.com/gopherjs/gopherjs 444abdf
# github.com/jtolds/gls 77f1821
# github.com/smartystreets/assertions 0b37b35
# github.com/smartystreets/goconvey e5b2b7c
# golang.org/x/net a8b9294
# golang.org/x/sys b90f89a
# golang.org/x/text 4ee4af5
# golang.org/x/tools 0444735
# gopkg.in/yaml.v2 287cf08
EGO_VENDOR=(
	"github.com/mattn/go-isatty 66b8e73"
	"github.com/mattn/go-runewidth 14207d2"
	"github.com/mattn/go-shellwords 02e3cf0"
	"golang.org/x/crypto e1a4589 github.com/golang/crypto"
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
IUSE="bash-completion fish-completion neovim tmux vim zsh-completion"

RDEPEND="fish-completion? ( app-shells/fish )
	neovim? ( app-editors/neovim )
	tmux? ( app-misc/tmux )
	vim? ( app-editors/vim )
	zsh-completion? ( app-shells/zsh )"

DOCS=( {CHANGELOG,README}.md )
QA_PRESTRIPPED="usr/bin/fzf"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X main.revision=${GIT_COMMIT}"
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

	if use bash-completion; then
		newbashcomp shell/completion.bash fzf
		insinto /etc/profile.d/
		newins shell/key-bindings.bash fzf.sh
	fi

	if use fish-completion; then
		insinto /usr/share/fish/functions/
		newins shell/key-bindings.fish fzf_key_bindings.fish
	fi

	if use neovim; then
		insinto /usr/share/nvim/runtime/plugin
		doins plugin/fzf.vim
	fi

	if use tmux; then
		dobin bin/fzf-tmux
		doman man/man1/fzf-tmux.1
	fi

	if use vim; then
		insinto /usr/share/vim/vimfiles/plugin
		doins plugin/fzf.vim
		dodoc README-VIM.md
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins shell/completion.zsh _fzf
		insinto /usr/share/zsh/site-contrib/
		newins shell/key-bindings.zsh fzf.zsh
	fi
}
