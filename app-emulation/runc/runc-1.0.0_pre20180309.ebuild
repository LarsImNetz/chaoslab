# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# For docker-18.09.0
# https://github.com/docker/docker-ce/blob/v18.09.0/components/engine/hack/dockerfile/install/runc.installer

EGO_PN="github.com/opencontainers/${PN}"
GIT_COMMIT="69663f0bd4b60df09991c08812a60108003fa340"

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="CLI tool for spawning and running containers"
HOMEPAGE="http://runc.io"
SRC_URI="https://${EGO_PN}/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test" # needs dockerd

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="+ambient apparmor bash-completion hardened +seccomp"

DEPEND="dev-util/go-md2man"
RDEPEND="
	!app-emulation/docker-runc
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( sys-libs/libseccomp )
"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/runc"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local CGO_CFLAGS CGO_LDFLAGS
	CGO_CFLAGS="-I${ROOT}/usr/include"
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '') -L${ROOT}/usr/$(get_libdir)"

	local myldflags=( -s -w
		-X "main.gitCommit=${GIT_COMMIT}"
		-X "main.version=${PV}"
	)

	# build up optional flags
	local opts
	use ambient && opts+=" ambient"
	use apparmor && opts+=" apparmor"
	use seccomp && opts+=" seccomp"

	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "${opts/ /}"
	)
	go build "${mygoargs[@]}" || die

	# build man pages
	man/md2man-all.sh -q || die
}

src_install() {
	dobin runc
	einstalldocs

	doman man/man8/*

	use bash-completion && dobashcomp contrib/completions/bash/runc
}
