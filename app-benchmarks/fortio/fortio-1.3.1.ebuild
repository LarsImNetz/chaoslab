# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild:
GIT_COMMIT="fd8f4a7177e9ea509f27105ae4e55e6c68ece6f7"
EGO_PN="fortio.org/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/golang/protobuf v1.2.0"
	"golang.org/x/net 26e67e76b6 github.com/golang/net"
	"golang.org/x/sys d0be0721c3 github.com/golang/sys"
	"golang.org/x/text v0.3.0 github.com/golang/text"
	"google.golang.org/genproto 36d5787dc5 github.com/google/go-genproto"
	"google.golang.org/grpc v1.15.0 github.com/grpc/grpc-go"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A load testing CLI, advanced echo server, and web UI in Go"
HOMEPAGE="https://fortio.org/"
ARCHIVE_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="daemon debug pie static"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		(has test ${FEATURES} && has network-sandbox ${FEATURES}) && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

pkg_setup() {
	if use daemon; then
		enewgroup fortio
		enewuser fortio -1 -1 /var/lib/fortio fortio
	fi
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.defaultDataDir=."
		-X "${EGO_PN}/ui.resourcesDir=${EPREFIX}/usr/share/fortio"
		-X "'${EGO_PN}/version.buildInfo=$(date -u +'%Y-%m-%d %H:%M') ${GIT_COMMIT}'"
		-X "${EGO_PN}/version.gitstatus=0"
		-X "${EGO_PN}/version.tag=v${PV}"
	)

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
	)

	go build "${mygoargs[@]}" || die
}

src_test() {
	./cert-gen || die
	go test -timeout 90s -race ./... || die
}

src_install() {
	dobin fortio
	use debug && dostrip -x /usr/bin/fortio

	insinto /usr/share/fortio
	doins -r ui/{static,templates}

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		systemd_dounit "${FILESDIR}/${PN}.service"

		diropts -o fortio -g fortio -m 0750
		keepdir /var/log/fortio
	fi

	einstalldocs
	doman docs/fortio.1
}
