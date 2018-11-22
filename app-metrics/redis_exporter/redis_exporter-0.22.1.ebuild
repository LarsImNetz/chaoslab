# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Change this when you update the ebuild:
GIT_COMMIT="77c2c783e074db2b1cc0e3531a55444d5d97a889"
EGO_PN="github.com/oliver006/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A server that export Redis metrics for Prometheus consumption"
HOMEPAGE="https://github.com/oliver006/redis_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/redis_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has test ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "The test phase requires a Redis server running on default port"
		ewarn

		(has network-sandbox ${FEATURES}) && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

pkg_setup() {
	enewgroup redis_exporter
	enewuser redis_exporter -1 -1 -1 redis_exporter
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.VERSION=${PV}"
		-X "main.COMMIT_SHA1=${GIT_COMMIT}"
		-X "main.BUILD_DATE=$(date -u +%F-%T)"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin redis_exporter
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
