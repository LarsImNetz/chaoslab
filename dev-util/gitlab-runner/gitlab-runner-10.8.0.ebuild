# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="079aad9" # Change this when you update the ebuild
EGO_PN="gitlab.com/gitlab-org/${PN}"
EGO_VENDOR=(
	"github.com/mitchellh/gox e05df8d"
	"github.com/kevinburke/go-bindata 2197b05"
)

inherit golang-vcs-snapshot linux-info systemd user

PREBUILT_SRC_URI="https://${PN}-downloads.s3.amazonaws.com/v${PV}/docker"
DESCRIPTION="The official GitLab Runner, written in Go"
HOMEPAGE="https://gitlab.com/gitlab-org/gitlab-runner"
SRC_URI="https://${EGO_PN}/repository/v${PV}/archive.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}
	!build-images? (
		${PREBUILT_SRC_URI}/prebuilt-x86_64.tar.xz -> ${P}-prebuilt-x86_64.tar.xz
		${PREBUILT_SRC_URI}/prebuilt-arm.tar.xz -> ${P}-prebuilt-arm.tar.xz
	)"
RESTRICT="mirror test"
# test requires tons of stuff, doesn't work with portage

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+build-images pie"

DEPEND="app-arch/xz-utils
	build-images? (
		app-emulation/docker
		app-emulation/qemu
	)"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/gitlab-runner"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

CONFIG_CHECK="~BINFMT_MISC"
ERROR_BINFMT_MISC="CONFIG_BINFMT_MISC: is required to build ARM images"

pkg_setup() {
	if use build-images; then
		linux-info_pkg_setup

		# shellcheck disable=SC2086
		if has network-sandbox $FEATURES; then
			ewarn ""
			ewarn "${CATEGORY}/${PN} requires internet access during"
			ewarn "compile phase, you must disable 'network-sandbox'"
			ewarn "in FEATURES (/etc/portage/make.conf)."
			ewarn ""
			die "'network-sandbox' is enabled in FEATURES"
		fi

		# Does portage have access to docker's socket?
		if getent group docker | grep &>/dev/null "\\bportage\\b"; then
			# Is docker running?
			if ! docker info &>/dev/null; then
				ewarn ""
				ewarn "Although portage is a member of the 'docker' group,"
				ewarn "docker must be running on your system during build time."
				ewarn ""
				die "docker doesn't seems to be properly running"
			fi
		else
			ewarn ""
			ewarn "In order for portage be able to build the docker images, you must"
			ewarn "add portage to the 'docker' group (e.g. usermod -aG docker portage)."
			ewarn "Also, docker must be running on your system during build time."
			ewarn ""
			die "portage doesn't seems to be a member of the 'docker' group"
		fi

		# Is 'arm' and 'armeb' registered?
		if [ ! -f /proc/sys/fs/binfmt_misc/arm ] && \
			[ ! -f /proc/sys/fs/binfmt_misc/armeb ]; then
			ewarn ""
			ewarn "You must enable support for ARM binaries through Qemu."
			ewarn ""
			ewarn "Please execute (as root) the script described here:"
			ewarn "https://${EGO_PN}/blob/v${PV}/docs/development/README.md#2-install-docker-engine"
			ewarn ""
			ewarn "Note: You probably don't need to modprobe or mount binfmt_misc,"
			ewarn "so comment out those parts in the aforementioned script."
			ewarn ""
			die "arm and armeb doesn't seems to be registered"
		fi
	fi

	enewgroup gitlab
	enewuser runner -1 -1 /var/lib/gitlab-runner gitlab
}

src_unpack() {
	# We only need to unpack main sources
	golang-vcs-snapshot_src_unpack
}

src_prepare() {
	mkdir -p out/docker || die
	if ! use build-images; then
		ln -s "${DISTDIR}/${P}-prebuilt-x86_64.tar.xz" "${S}/out/docker/prebuilt-x86_64.tar.xz"
		ln -s "${DISTDIR}/${P}-prebuilt-arm.tar.xz" "${S}/out/docker/prebuilt-arm.tar.xz"
	fi
	default
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH" BUILT
	BUILT="$(date -u '+%Y-%m-%dT%H:%M:%S%:z')"
	local myldflags=( -s -w
		-X "${EGO_PN}/common.NAME=${PN}"
		-X "${EGO_PN}/common.VERSION=${PV}"
		-X "${EGO_PN}/common.REVISION=${GIT_COMMIT}"
		-X "${EGO_PN}/common.BUILT=${BUILT}"
		-X "${EGO_PN}/common.BRANCH=non-git"
	)
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)

	if use build-images; then
		# Build gox locally
		go install ./vendor/github.com/mitchellh/gox || die

		ebegin "Building gitlab-runner-prebuilt-x86_64-${GIT_COMMIT}"
		# Building gitlab-runner-helper
		gox -osarch=linux/amd64 \
			-ldflags "${myldflags[*]}" \
			-output="dockerfiles/build/gitlab-runner-helper" \
			./apps/gitlab-runner-helper || die

		# Build docker images
		docker build -t gitlab/gitlab-runner-helper:x86_64-${GIT_COMMIT} \
			-f dockerfiles/build/Dockerfile.x86_64 dockerfiles/build || die
		docker create --name=gitlab-runner-prebuilt-x86_64-${GIT_COMMIT} \
			gitlab/gitlab-runner-helper:x86_64-${GIT_COMMIT} /bin/sh || die
		docker export -o out/docker/prebuilt-x86_64.tar gitlab-runner-prebuilt-x86_64-${GIT_COMMIT} || die
		docker rm -f gitlab-runner-prebuilt-x86_64-${GIT_COMMIT} || die
		xz -f -9 out/docker/prebuilt-x86_64.tar || die
		eend $?

		ebegin "Building gitlab-runner-prebuilt-arm-${GIT_COMMIT}"
		# Building gitlab-runner-helper
		gox -osarch=linux/arm \
			-ldflags "${myldflags[*]}" \
			-output="dockerfiles/build/gitlab-runner-helper" \
			./apps/gitlab-runner-helper || die

		# Build docker images
		docker build -t gitlab/gitlab-runner-helper:arm-${GIT_COMMIT} \
			-f dockerfiles/build/Dockerfile.arm dockerfiles/build || die
		docker create --name=gitlab-runner-prebuilt-arm-${GIT_COMMIT} \
			gitlab/gitlab-runner-helper:arm-${GIT_COMMIT} /bin/sh || die
		docker export -o out/docker/prebuilt-arm.tar gitlab-runner-prebuilt-arm-${GIT_COMMIT} || die
		docker rm -f gitlab-runner-prebuilt-arm-${GIT_COMMIT} || die
		xz -f -9 out/docker/prebuilt-arm.tar || die
		eend $?
	else
		ewarn "WARNING: prebuilt docker images will be embedded in gitlab-runner"
		ewarn "WARNING: it is NOT safe, as it may contain outdated code, to use"
		ewarn "WARNING: images compiled from your system, enable 'build-images'"
	fi

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die

	# Generating embedded data
	go-bindata \
		-pkg docker \
		-nocompress \
		-nomemcopy \
		-nometadata \
		-prefix out/docker/ \
		-o executors/docker/bindata.go \
		out/docker/prebuilt-x86_64.tar.xz \
		out/docker/prebuilt-arm.tar.xz || die
	go fmt executors/docker/bindata.go || die

	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gitlab-runner
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -m 0750 -o runner -g gitlab
	dodir /etc/gitlab-runner

	insinto /etc/gitlab-runner
	doins config.toml.example

	diropts -m 0750 -o runner -g gitlab
	keepdir /var/log/gitlab-runner
}

pkg_postinst() {
	if use build-images; then
		ewarn ""
		ewarn "As a security measure, you should remove portage from"
		ewarn "the 'docker' group (e.g. gpasswd -d portage docker)."
		ewarn ""
	fi
}
