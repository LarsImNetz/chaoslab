# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="code.gitea.io/gitea"
EGO_VENDOR=( "github.com/kevinburke/go-bindata 2197b05" )

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Gitea - Git with a cup of tea"
HOMEPAGE="https://gitea.io"
SRC_URI="https://github.com/go-gitea/gitea/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="memcached mysql openssh pam pie postgres redis sqlite tidb"

RDEPEND="dev-vcs/git[curl,threads]
	memcached? ( net-misc/memcached )
	mysql? ( virtual/mysql )
	openssh? ( net-misc/openssh )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql )
	redis? ( dev-db/redis )
	sqlite? ( dev-db/sqlite )
	tidb? ( dev-db/tidb )"

QA_PRESTRIPPED="usr/bin/gitea"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup git
	enewuser git -1 /bin/bash /var/lib/gitea git
}

src_prepare() {
	# The tarball isn't a proper git repository,
	# so let's silence the "fatal" message.
	sed -i "/LDFLAGS :=/d" Makefile || die

	sed -i \
		-e "s:^STATIC_ROOT_PATH =:STATIC_ROOT_PATH = ${EPREFIX}/usr/share/gitea:" \
		-e "s:^ROOT_PATH =:ROOT_PATH = ${EPREFIX}/var/log/gitea:" \
		custom/conf/app.ini.sample || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH"

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die
	# Generate embedded data
	emake generate

	# build up optional flags
	# shellcheck disable=SC2207
	local options=(
		$(usex pam pam '')
		$(usex sqlite sqlite '')
		$(usex tidb tidb '')
	)
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.Version=${PV/_/-}
			-X 'main.Tags=${options[*]}'"
		-tags "${options[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	# shellcheck disable=SC2046
	go test -v $(go list ./... | grep -v /integrations) || die
}

src_install() {
	dobin gitea

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_newtmpfilesd "${FILESDIR}/${PN}.tmpfilesd-r1" "${PN}.conf"

	insinto /var/lib/gitea/custom
	doins -r options

	insinto /var/lib/gitea/conf
	newins custom/conf/app.ini.sample app.ini.example
	dosym ../custom/options/locale /var/lib/gitea/conf/locale

	insinto /usr/share/gitea
	doins -r public templates

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	diropts -m 0750
	keepdir /var/lib/gitea/data /var/log/gitea
	fowners -R git:git /var/{lib,log}/gitea
}

pkg_postinst() {
	if [ ! -f "${EROOT%/}"/var/lib/gitea/conf/app.ini ]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT%/}"/var/lib/gitea/conf/app.ini{.example,} || die
	else
		elog "app.ini found, please check example file for possible changes"
	fi
}
