# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MAKEFILE_GENERATOR="emake"
USE_RUBY="ruby23 ruby24 ruby25"

inherit cmake-utils flag-o-matic ruby-single systemd user

MY_PV="${PV/_/-}"
DESCRIPTION="An optimized HTTP server with support for HTTP/1.x and HTTP/2"
HOMEPAGE="https://h2o.examp1e.net/"
SRC_URI="https://github.com/h2o/h2o/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug libressl +mruby"

RDEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
"
DEPEND="${RDEPEND}
	mruby? (
		${RUBY_DEPS}
		dev-libs/oniguruma
		sys-devel/bison
		virtual/pkgconfig
	)
"
RDEPEND+=" app-misc/ca-certificates"

PATCHES=(
	"${FILESDIR}/${PN}-2.3.0-system_ca.patch"
	"${FILESDIR}/${PN}-2.3-mruby.patch"
)

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	cmake-utils_src_prepare

	if use mruby; then
		local ruby="ruby"
		for ruby in ${RUBY_TARGETS_PREFERENCE}; do
			if has_version "dev-lang/ruby:${ruby:4:1}.${ruby:5}"; then
				break
			fi
			ruby=
		done
		[[ -z ${ruby} ]] && die "no suitable ruby version found"
	fi

	sed -i \
		-e "/INSTALL/s:\\(/doc/h2o\\) :\\1/html :" \
		-e "/INSTALL/s:\\(/doc\\)/h2o:\\1/${PF}:" \
		-e "s: ruby: ${ruby}:" \
		./CMakeLists.txt || die

	sed -i "s:pkg-config:$(tc-getPKG_CONFIG):g" \
		./deps/mruby/lib/mruby/gem.rb || die

	tc-export CC
	LD="$(tc-getCC)"
	export LD
}

src_configure() {
	use debug || append-cflags -DNDEBUG
	# shellcheck disable=SC2191
	local mycmakeargs=(
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}"/etc/h2o
		-DWITH_MRUBY="$(usex mruby)"
		-DWITHOUT_LIBS=ON
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}"/h2o.initd h2o
	systemd_dounit "${FILESDIR}"/h2o.service

	insinto /etc/h2o
	newins "${FILESDIR}"/h2o.conf h2o.conf.example

	# Update docs path
	sed -i "s:@H2O_DOC@:${PF}:" "${ED%/}"/etc/h2o/h2o.conf.example || die

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/h2o.logrotate h2o

	diropts -m 0700
	keepdir /var/log/h2o
}

pkg_preinst() {
	enewgroup h2o
	enewuser h2o -1 -1 -1 h2o
}

pkg_postinst() {
	if [[ ! -e "${EROOT%/}/etc/h2o/h2o.conf" ]]; then
		elog "No h2o.conf found, copying the example over"
		cp "${EROOT%/}"/etc/h2o/h2o.conf{.example,} || die
	fi
}
