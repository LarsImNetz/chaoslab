# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="d3aaf8f5dbe5032734aeaea9c44eb79ef61eeaec"
EGO_PN="github.com/sosedoff/${PN}"

inherit golang-vcs-snapshot-r1 systemd user

DESCRIPTION="Web-based PostgreSQL database browser written in Go"
HOMEPAGE="https://sosedoff.github.io/pgweb/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug +daemon pie"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has test ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		has network-sandbox ${FEATURES} && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"

		ewarn
		ewarn "The tests requires a PostgreSQL server running on default port"
		ewarn
		sleep 5
	fi
}

pkg_setup() {
	if use daemon; then
		enewgroup pgweb
		enewuser pgweb -1 -1 -1 pgweb
	fi
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "'${EGO_PN}/pkg/command.BuildTime=$(date -u +'%Y-%m-%dT%H:%M:%SZ')'"
		-X "${EGO_PN}/pkg/command.GitCommit=${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./pkg/... || die
}

src_install() {
	dobin pgweb
	use debug && dostrip -x /usr/bin/pgweb
	einstalldocs

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		systemd_dounit "${FILESDIR}/${PN}.service"

		diropts -o pgweb -g pgweb -m 0750
		keepdir /var/log/pgweb
	fi
}
