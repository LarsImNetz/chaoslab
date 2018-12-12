# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/xyproto/${PN}"

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="Pure Go web server with Lua, Markdown, QUIC and Pongo2 support"
HOMEPAGE="http://algernon.roboticoverlords.org"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug examples mysql pie postgres redis"

RDEPEND="
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql:* )
	redis? ( dev-db/redis )
"

DOCS=( ChangeLog.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup algernon
	enewuser algernon -1 -1 -1 algernon
}

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

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin algernon
	dobin desktop/mdview
	use debug && dostrip -x /usr/bin/algernon

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/algernon
	doins system/serverconf.lua

	if use examples; then
		docinto examples
		dodoc -r samples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	keepdir /var/www/algernon
	diropts  -m 0700 -o algernon -g algernon
	keepdir /var/log/algernon

	einstalldocs
}
