# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV/_/-}"
CODENAME="tetedemoine"
EGO_PN="github.com/containous/${PN}"
EGO_VENDOR=( "github.com/containous/go-bindata e237f24" )

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A modern HTTP reverse proxy and load balancer made to deploy microservices"
HOMEPAGE="https://traefik.io"
SRC_URI="https://${EGO_PN}/releases/download/v${MY_PV}/${PN}-v${MY_PV}.src.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples pie"

DOCS=( {CHANGELOG,CONTRIBUTING,README}.md )
QA_PRESTRIPPED="usr/bin/traefik"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup traefik
	enewuser traefik -1 -1 -1 traefik
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH"
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X ${EGO_PN}/version.Version=${MY_PV}
			-X ${EGO_PN}/version.Codename=${CODENAME}
			-X '${EGO_PN}/version.BuildDate=$(date -u '+%Y-%m-%d_%I:%M:%S%p')'"
	)

	# Build go-bindata locally
	go install ./vendor/github.com/containous/go-bindata/go-bindata || die

	go generate || die
	go build "${mygoargs[@]}" ./cmd/traefik || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin traefik
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	insinto /etc/traefik
	newins traefik.sample.toml traefik.toml.example

	if use examples; then
		docinto examples
		dodoc -r examples/*
		docompress -x /usr/share/doc/${PF}/examples
	fi

	diropts -o traefik -g traefik -m 0750
	keepdir /var/log/traefik
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/${PN}/traefik.toml ]; then
		elog "No traefik.toml found, copying the example over"
		cp "${EROOT%/}"/etc/${PN}/traefik.toml{.example,} || die
	else
		elog "traefik.toml found, please check example file for possible changes"
	fi
}
