# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/${PN}/${PN}"
GIT_COMMIT="773c489" # Change this when you update the ebuild

inherit golang-vcs-snapshot

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.tools"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm"
IUSE="+btrfs test"
REQUIRED_USE="test? ( btrfs )"

DEPEND="btrfs? ( sys-fs/btrfs-progs )"
RDEPEND=">=app-emulation/runc-1.0.0_rc4
	sys-libs/libseccomp"

QA_PRESTRIPPED="usr/bin/containerd
	usr/bin/containerd-shim
	usr/bin/containerd-stress
	usr/bin/ctr"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	# shellcheck disable=SC2207
	local options=( $(usex !btrfs no_btrfs '') )
	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X ${EGO_PN}/version.Version=${PV}
			-X ${EGO_PN}/version.Revision=${GIT_COMMIT}
			-X ${EGO_PN}/version.Package=${EGO_PN}"
		-tags "${options[*]}"
	)

	# set !cgo and omit pie for a static shim
	local mygoargs2=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-extldflags '-static'
			-X ${EGO_PN}/version.Version=${PV}
			-X ${EGO_PN}/version.Revision=${GIT_COMMIT}
			-X ${EGO_PN}/version.Package=${EGO_PN}"
		-tags "${options[*]}"
	)

	go install "${mygoargs[@]}" \
		./cmd/{containerd{,-stress},ctr} || die

	CGO_ENABLED=0 go build "${mygoargs2[@]}" \
		./cmd/containerd-shim || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin containerd{,-shim,-stress} ctr
}
