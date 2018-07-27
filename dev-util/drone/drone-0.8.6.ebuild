# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="c481507" # Change this when you update the ebuild
EGO_PN="github.com/${PN}/${PN}"
EGO_VENDOR=(
	"github.com/drone/drone-ui e7597b5"
	"github.com/golang/protobuf 9eb2c01"
	"golang.org/x/net e514e69 github.com/golang/net"
)

inherit golang-vcs-snapshot user

DESCRIPTION="Drone is a Continuous Delivery platform built on Docker"
HOMEPAGE="https://drone.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/drone-agent
	usr/bin/drone-server"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup drone
	enewuser drone -1 -1 /var/lib/drone drone
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "${EGO_PN}/version.VersionDev=build.${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	# set !cgo and omit pie for a static shim
	local mygoargs2=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]} -extldflags '-static'"
	)
	go build "${mygoargs[@]}" ./cmd/drone-agent || die
	CGO_ENABLED=0 go build "${mygoargs2[@]}" ./cmd/drone-server || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin drone-{agent,server}
	einstalldocs

	newinitd "${FILESDIR}"/drone-server.initd drone-server
	newconfd "${FILESDIR}"/drone-server.confd drone-server
	newinitd "${FILESDIR}"/drone-agent.initd drone-agent
	newconfd "${FILESDIR}"/drone-agent.confd drone-agent

	diropts -o drone -g drone -m 0750
	keepdir /var/log/drone
}

pkg_postinst() {
	if [[ $(stat -c %a "${EROOT%/}/var/lib/drone") != "700" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/drone permissions"
		chown drone:drone "${EROOT%/}/var/lib/drone" || die
		chmod 0700 "${EROOT%/}/var/lib/drone" || die
	fi
}
