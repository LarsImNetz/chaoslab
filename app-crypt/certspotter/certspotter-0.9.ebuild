# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="software.sslmate.com/src/${PN}"
EGO_VENDOR=(
	"github.com/mreiferson/go-httpclient 31f0106"
	"golang.org/x/net dfa909b github.com/golang/net"
	"golang.org/x/text 5c1cf69 github.com/golang/text"
)

inherit golang-vcs-snapshot

DESCRIPTION="A Certificate Transparency log monitor from SSLMate"
HOMEPAGE="https://sslmate.com/certspotter"
SRC_URI="https://github.com/SSLMate/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( NEWS README )
QA_PRESTRIPPED="usr/bin/certspotter"

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
	go build "${mygoargs[@]}" ./cmd/certspotter|| die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin certspotter
	einstalldocs
}
