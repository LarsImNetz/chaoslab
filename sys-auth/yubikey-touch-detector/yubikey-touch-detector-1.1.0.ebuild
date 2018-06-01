# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/maximbaz/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="A tool that can detect when your YubiKey is waiting for a touch"
HOMEPAGE="https://github.com/maximbaz/yubikey-touch-detector"
SRC_URI="https://${EGO_PN}/releases/download/${PV}/${PN}-src.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

RDEPEND=">=sys-auth/pam_u2f-1.0.7"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/yubikey-touch-detector"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin yubikey-touch-detector
	einstalldocs
}
