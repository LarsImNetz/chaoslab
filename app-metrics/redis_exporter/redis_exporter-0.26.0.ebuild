# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild:
GIT_COMMIT="bdb321677a309e525496ec3b786aa4c3745a546b"
EGO_PN="github.com/oliver006/${PN}"

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A server that export Redis metrics for Prometheus consumption"
HOMEPAGE="https://github.com/oliver006/redis_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie static"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has test ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "The test phase requires a Redis server running on default port"
		ewarn

		has network-sandbox ${FEATURES} && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

pkg_setup() {
	enewgroup redis_exporter
	enewuser redis_exporter -1 -1 -1 redis_exporter
}

src_prepare() {
	if use static; then
		use pie || export CGO_ENABLED=0
		use pie && append-ldflags -static
	fi
	default
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.VERSION=${PV}"
		-X "main.COMMIT_SHA1=${GIT_COMMIT}"
		-X "main.BUILD_DATE=$(date -u +%F-%T)"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin redis_exporter
	use debug && dostrip -x /usr/bin/redis_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /usr/share/redis_exporter
	doins -r contrib/*
	docompress -x /usr/share/redis_exporter

	diropts -o redis_exporter -g redis_exporter -m 0750
	keepdir /var/log/redis_exporter
}
