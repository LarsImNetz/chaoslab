# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# For docker-18.09.0
# https://github.com/docker/docker-ce/blob/v18.09.0/components/engine/hack/dockerfile/install/containerd.installer
EGO_PN="github.com/${PN}/${PN}"
GIT_COMMIT="468a545b9e" # Change this when you update the ebuild

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
RDEPEND="
	>=app-emulation/runc-1.0.0_rc4
	sys-libs/libseccomp
"

QA_PRESTRIPPED="
	usr/bin/containerd
	usr/bin/containerd-shim
	usr/bin/containerd-stress
	usr/bin/ctr
"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local myldflags=( -s -w
		-X "${EGO_PN}/version.Version=${PV}"
		-X "${EGO_PN}/version.Revision=${GIT_COMMIT}"
		-X "${EGO_PN}/version.Package=${EGO_PN}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex !btrfs 'no_btrfs' '')"
	)
	# set !cgo and omit pie for a static shim
	local mygoargs2=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]} -extldflags '-static'"
		-tags "$(usex !btrfs 'no_btrfs' '')"
	)

	go install "${mygoargs[@]}" ./cmd/{containerd{,-stress},ctr} || die

	CGO_ENABLED=0 go install "${mygoargs2[@]}" ./cmd/containerd-shim || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin containerd{,-shim,-stress}
	dobin ctr
}
