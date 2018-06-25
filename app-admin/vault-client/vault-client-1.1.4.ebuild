# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/adfinis-sygroup/${PN}"
# Snapshot taken on 2018.06.22
EGO_VENDOR=(
	"github.com/armon/go-radix 1fca145"
	"github.com/bgentry/speakeasy 4aabc24"
	"github.com/fatih/color 2d68451"
	"github.com/hashicorp/go-multierror b7773ae"
	"github.com/hashicorp/vault ae72826"
	"github.com/mattn/go-isatty 6ca4dbf"
	"github.com/mitchellh/cli c48282d"
	"github.com/posener/complete e037c22"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A CLI to HashiCorp's Vault inspired by pass"
HOMEPAGE="https://github.com/adfinis-sygroup/vault-client"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bash-completion pie zsh-completion"

RDEPEND="zsh-completion? ( app-shells/zsh )"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/vc"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-o ./vc
	)
	go build "${mygoargs[@]}" ./src || die
}

src_install() {
	dobin vc
	einstalldocs

	if use bash-completion; then
		newbashcomp sample/vc-completion.bash vc
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins sample/vc-completion.zsh _vc
	fi
}
