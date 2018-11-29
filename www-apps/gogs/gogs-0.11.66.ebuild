# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

GIT_COMMIT="3a4c981" # Change this when you update the ebuild
EGO_PN="github.com/${PN}/${PN}"

inherit fcaps golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A painless self-hosted Git service"
HOMEPAGE="https://gogs.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cert memcached mysql openssh pam pie postgres redis sqlite"

RDEPEND="
	dev-vcs/git[curl,threads]
	memcached? ( net-misc/memcached )
	mysql? ( virtual/mysql )
	openssh? ( net-misc/openssh )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql )
	redis? ( dev-db/redis )
	sqlite? ( dev-db/sqlite )
"

FILECAPS=( cap_net_bind_service+ep usr/bin/gogs )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup gogs
	enewuser gogs -1 /bin/bash /var/lib/gogs gogs
}

src_prepare() {
	sed -i \
		-e "s:^RUN_USER =.*:RUN_USER = gogs:" \
		-e "s:^STATIC_ROOT_PATH =:STATIC_ROOT_PATH = ${EPREFIX}/usr/share/gogs:" \
		-e "s:^ROOT_PATH =:ROOT_PATH = ${EPREFIX}/var/log/gogs:" \
		conf/app.ini || die

	default
}

src_compile() {
	export GOPATH="${G}"

	# Build up optional flags
	local opts
	use cert && opts+=" cert"
	use pam && opts+=" pam"
	use sqlite && opts+=" sqlite"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "'${EGO_PN}/pkg/setting.BuildTime=$(date -u '+%Y-%m-%d %I:%M:%S %Z')'"
		-X "${EGO_PN}/pkg/setting.BuildGitHash=${GIT_COMMIT}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "${opts/ /}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v -cover -race ./... || die
}

src_install() {
	dobin gogs
	use debug && dostrip -x /usr/bin/gogs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /var/lib/gogs/conf
	newins conf/app.ini app.ini.example

	insinto /usr/share/gogs
	doins -r templates

	insinto /usr/share/gogs/public
	doins -r public/{assets,css,img,js,plugins}

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate-r1" "${PN}"

	diropts -o gogs -g gogs -m 0750
	keepdir /var/log/gogs
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [[ ! -e "${EROOT}/var/lib/gogs/conf/app.ini" ]]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT}"/var/lib/gogs/conf/app.ini{.example,} || die
	else
		elog "app.ini found, please check example file for possible changes"
	fi

	if ! use filecaps; then
		ewarn
		ewarn "'filecaps' USE flag is disabled"
		ewarn "${PN} will fail to listen on port < 1024"
		ewarn "please either change port to > 1024 or re-enable 'filecaps'"
		ewarn
	fi
}
