# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/DrakeW/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/inconshreveable/mousetrap
# github.com/mattn/go-colorable
# github.com/mattn/go-isatty
# golang.org/x/sys
EGO_VENDOR=(
	"github.com/chzyer/readline 2972be2"
	"github.com/fatih/color 5b77d2a"
	"github.com/mitchellh/go-homedir 3864e76"
	"github.com/spf13/cobra ef82de7"
	"github.com/spf13/pflag 583c0c0"
)

inherit golang-vcs-snapshot

DESCRIPTION="A CLI workflow manager that helps with your repetitive command usages"
HOMEPAGE="https://github.com/DrakeW/corgi"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/corgi"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin corgi
	einstalldocs
}
