# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# For docker-18.09.1
# https://github.com/docker/docker-ce/blob/v18.09.1/components/engine/hack/dockerfile/install/containerd.installer
# Change this when you update the ebuild:
GIT_COMMIT="9754871865f7fe2f4e74d43e2fc7ccd237edcbce"
EGO_PN="github.com/${PN}/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="A daemon to control runC"
HOMEPAGE="https://containerd.tools"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="test"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="apparmor +btrfs +cri debug +seccomp"

CDEPEND="seccomp? ( sys-libs/libseccomp )"
DEPEND="${CDEPEND}
	btrfs? ( sys-fs/btrfs-progs )
"
RDEPEND="${CDEPEND}
	>=app-emulation/runc-1.0.0_pre20181203
"

QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	local options=(
		"$(usex apparmor 'apparmor' '')"
		"$(usex !btrfs 'no_btrfs' '')"
		"$(usex !cri 'no_cri' '')"
		"$(usex seccomp 'seccomp' '')"
	)

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${EGO_PN}/version.Version=${PV}"
		-X "${EGO_PN}/version.Revision=${GIT_COMMIT}"
		-X "${EGO_PN}/version.Package=${EGO_PN}"
	)

	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "${options[*]}"
	)

	# set !cgo and omit pie for a static shim
	local mygoargs2=(
		-v -work -x
		"-buildmode=exe"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]} -extldflags '-static'"
		-tags "${options[*]}"
	)

	go install "${mygoargs[@]}" ./cmd/{containerd{,-stress},ctr} || die

	CGO_ENABLED=0 go install "${mygoargs2[@]}" ./cmd/containerd-shim || die
}

src_install() {
	dobin containerd{,-shim,-stress}
	dobin ctr
	use debug && dostrip -x /usr/bin/{containerd{,-shim,-stress},ctr}
}
