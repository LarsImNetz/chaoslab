# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/DrakeW/${PN}"
EGO_VENDOR=(
	# Note: Keep EGO_VENDOR in sync with Gopkg.lock
	"github.com/chzyer/readline 2972be24d48e"
	"github.com/fatih/color v1.7.0"
	#"github.com/inconshreveable/mousetrap v1.0"
	#"github.com/mattn/go-colorable v0.0.9"
	#"github.com/mattn/go-isatty v0.0.3"
	"github.com/mitchellh/go-homedir 3864e76763d9"
	"github.com/spf13/cobra v0.0.3"
	"github.com/spf13/pflag v1.0.1"
	#"golang.org/x/sys c11f84a56e43 github.com/golang/sys"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A CLI workflow manager that helps with your repetitive command usages"
HOMEPAGE="https://github.com/DrakeW/corgi"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin corgi
	use debug && dostrip -x /usr/bin/corgi
	einstalldocs
}
