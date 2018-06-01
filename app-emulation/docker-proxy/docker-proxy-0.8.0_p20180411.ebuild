# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# For docker-18.05.0
# https://github.com/docker/docker-ce/blob/v18.05.0-ce/components/engine/hack/dockerfile/install/proxy.installer

EGO_PN="github.com/docker/libnetwork"
GIT_COMMIT="c15b372ef22125880d378167dde44f4b134e1a77"

inherit golang-vcs-snapshot

DESCRIPTION="Docker container networking"
HOMEPAGE="https://github.com/docker/libnetwork"
SRC_URI="https://${EGO_PN}/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm"
IUSE=""

DOCS=( {CHANGELOG,README,ROADMAP}.md )
QA_PRESTRIPPED="usr/bin/docker-proxy"

RESTRICT="test" # needs dockerd

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-o docker-proxy
	)
	go build "${mygoargs[@]}" ./cmd/proxy || die
}

src_install() {
	dobin docker-proxy
	einstalldocs
}
