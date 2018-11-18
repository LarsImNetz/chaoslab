# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Change this when you update the ebuild:
GIT_COMMIT="bf3f2d9ff07ed03ef16be56af20d58dc0300e60f"
EGO_PN="fortio.org/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/golang/protobuf aa810b61a9"
	"golang.org/x/net 26e67e76b6 github.com/golang/net"
	"golang.org/x/sys d0be0721c3 github.com/golang/sys"
	"golang.org/x/text f21a4dfb5e github.com/golang/text"
	"google.golang.org/genproto 36d5787dc5 github.com/google/go-genproto"
	"google.golang.org/grpc 8dea3dc473 github.com/grpc/grpc-go"
)

inherit golang-vcs-snapshot

DESCRIPTION="A load testing CLI, advanced echo server, and web UI in Go"
HOMEPAGE="https://fortio.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="daemon pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/fortio"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		if has test && has network-sandbox $FEATURES; then
			ewarn
			ewarn "The test phase requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi

	if use daemon; then
		enewgroup fortio
		enewuser fortio -1 -1 /var/lib/fortio fortio
	fi
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.defaultDataDir=."
		-X "${EGO_PN}/ui.resourcesDir=${EPREFIX}/usr/share/fortio"
		-X "'${EGO_PN}/version.buildInfo=$(date -u +'%Y-%m-%d %H:%M') ${GIT_COMMIT}'"
		-X "${EGO_PN}/version.gitstatus=0"
		-X "${EGO_PN}/version.tag=v${PV}"
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
	./cert-gen || die
	go test -timeout 90s -race ./... || die
}

src_install() {
	dobin fortio
	einstalldocs
	doman docs/fortio.1

	insinto /usr/share/fortio
	doins -r ui/{static,templates}

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		systemd_dounit "${FILESDIR}/${PN}.service"

		diropts -o fortio -g fortio -m 0750
		keepdir /var/log/fortio
	fi
}
