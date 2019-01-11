# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# For docker-18.09.1
# https://github.com/docker/docker-ce/blob/v18.09.1/components/engine/hack/dockerfile/install/proxy.installer
# Change this when you update the ebuild:
GIT_COMMIT="2cfbf9b1f98162a55829a21cc603c76072a75382"
EGO_PN="github.com/docker/libnetwork"

inherit golang-vcs-snapshot-r1

DESCRIPTION="Docker container networking"
HOMEPAGE="https://github.com/docker/libnetwork"
SRC_URI="https://${EGO_PN}/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="debug"

DOCS=( {CHANGELOG,README,ROADMAP}.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-o docker-proxy
	)
	go build "${mygoargs[@]}" ./cmd/proxy || die
}

src_install() {
	dobin docker-proxy
	use debug && dostrip -x /usr/bin/docker-proxy
	einstalldocs
}
