# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# For docker-18.09.2
# https://github.com/docker/docker-ce/blob/v18.09.2/components/engine/hack/dockerfile/install/runc.installer
# Change this when you update the ebuild:
GIT_COMMIT="96ec2177ae841256168fcf76954f7177af9446eb"
EGO_PN="github.com/opencontainers/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot-r1

DESCRIPTION="CLI tool for spawning and running containers"
HOMEPAGE="http://runc.io"
SRC_URI="https://${EGO_PN}/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test" # needs dockerd

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="+ambient apparmor debug +kmem +seccomp"

DEPEND="dev-util/go-md2man"
RDEPEND="
	!app-emulation/docker-runc
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( sys-libs/libseccomp )
"

PATCHES=( "${FILESDIR}/${PN}-fix-cve.patch" )

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	local options=(
		"$(usex ambient 'ambient' '')"
		"$(usex apparmor 'apparmor' '')"
		"$(usex !kmem 'nokmem' '')"
		"$(usex seccomp 'seccomp' '')"
	)

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.gitCommit=${GIT_COMMIT}"
		-X "main.version=${PV}"
	)

	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "${options[*]}"
	)
	go build "${mygoargs[@]}" || die

	# build man pages
	man/md2man-all.sh -q || die
}

src_install() {
	dobin runc
	use debug && dostrip -x /usr/bin/runc
	einstalldocs

	doman man/man8/*
	dobashcomp contrib/completions/bash/runc
}
