# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/shadowsocks/${PN}"
EGO_VENDOR=(
	"github.com/Yawning/chacha20 e3b1f96"
	"golang.org/x/crypto 9f005a0 github.com/golang/crypto"
)

inherit golang-vcs-snapshot user

DESCRIPTION="A Go port of Shadowsocks"
HOMEPAGE="https://shadowsocks.org"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DOCS=( CHANGELOG README.md )
QA_PRESTRIPPED="usr/bin/shadowsocks-httpget
	usr/bin/shadowsocks-local
	usr/bin/shadowsocks-server"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup shadowsocks-go
	enewuser shadowsocks-go -1 -1 -1 shadowsocks-go
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go install "${mygoargs[@]}" \
		./cmd/shadowsocks-{httpget,local,server} || die
}

src_install() {
	dobin bin/shadowsocks-{httpget,local,server}
	einstalldocs

	newinitd "${FILESDIR}/${PN}-local.initd" "${PN}-local"
	newinitd "${FILESDIR}/${PN}-server.initd" "${PN}-server"

	diropts -o shadowsocks-go -g shadowsocks-go -m 0700
	keepdir /{etc,var/log}/shadowsocks-go

	insinto /etc/shadowsocks-go
	newins "${FILESDIR}/${PN}-local.conf" local.json.example
	newins "${FILESDIR}/${PN}-server.conf" server.json.example
}
