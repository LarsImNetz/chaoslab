# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/maximbaz/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="A tool that can detect when your YubiKey is waiting for a touch"
HOMEPAGE="https://github.com/maximbaz/yubikey-touch-detector"
SRC_URI="https://${EGO_PN}/releases/download/${PV}/${PN}-src.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie"

RDEPEND=">=sys-auth/pam_u2f-1.0.7"

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
	dobin yubikey-touch-detector
	use debug && dostrip -x /usr/bin/yubikey-touch-detector
	einstalldocs
}
