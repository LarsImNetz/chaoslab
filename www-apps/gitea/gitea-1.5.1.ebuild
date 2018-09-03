# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="code.gitea.io/gitea"
EGO_VENDOR=( "github.com/kevinburke/go-bindata 06af60a" )

inherit fcaps golang-vcs-snapshot systemd user

DESCRIPTION="Gitea - Git with a cup of tea"
HOMEPAGE="https://gitea.io"
SRC_URI="https://github.com/go-gitea/gitea/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="memcached mysql openssh pam pie postgres redis sqlite tidb"

RDEPEND="
	dev-vcs/git[curl,threads]
	memcached? ( net-misc/memcached )
	mysql? ( virtual/mysql )
	openssh? ( net-misc/openssh )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql )
	redis? ( dev-db/redis )
	sqlite? ( dev-db/sqlite )
	tidb? ( dev-db/tidb )
"

FILECAPS=( cap_net_bind_service+ep usr/bin/gitea )
QA_PRESTRIPPED="usr/bin/gitea"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup git
	enewuser git -1 /bin/bash /var/lib/gitea git
}

src_prepare() {
	# The tarball isn't a proper git repository,
	# so let's silence the "fatal" error message.
	sed -i "/GITEA_VERSION :=/d" Makefile || die

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
	local opts
	use pam && opts+=" pam"
	use sqlite && opts+=" sqlite"
	use tidb && opts+=" tidb"

	local myldflags=( -s -w
		-X "main.Version=${PV/_/-}"
		-X "'main.Tags=${opts/ /}'"
	)

	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "${opts/ /}"
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

	insinto /var/lib/gitea/custom
	doins -r options

	insinto /var/lib/gitea/conf
	newins custom/conf/app.ini.sample app.ini.example
	dosym ../custom/options/locale /var/lib/gitea/conf/locale

	insinto /usr/share/gitea
	doins -r public templates

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	diropts -o git -g git -m 0750
	keepdir /var/log/gitea
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [[ $(stat -c %a "${EROOT%/}/var/lib/gitea") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/gitea permissions"
		chown -R git:git "${EROOT%/}/var/lib/gitea" || die
		chmod 0750 "${EROOT%/}/var/lib/gitea" || die
	fi

	if [[ ! -e "${EROOT%/}/var/lib/gitea/conf/app.ini" ]]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT%/}"/var/lib/gitea/conf/app.ini{.example,} || die
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
