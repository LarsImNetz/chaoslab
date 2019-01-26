# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

inherit python-single-r1

ELECTRON_SLOT="3.1"
DESCRIPTION="Atom package manager"
HOMEPAGE="https://github.com/atom/apm"
SRC_URI="https://github.com/atom/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="net-libs/nodejs[npm]"
RDEPEND="${DEPEND}
	app-crypt/libsecret
	dev-nodejs/node-gyp
	dev-util/electron-bin:${ELECTRON_SLOT}
	dev-vcs/git
"

DOCS=( README.md )
PATCHES=(
	"${FILESDIR}/${PN}-use-system-npm-r0.patch"
	"${FILESDIR}/${PN}-no-scripts-r0.patch"
)

QA_PRESTRIPPED="usr/.*"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

src_prepare() {
	mkdir "${WORKDIR}/apm-build" || die

	# Use custom launcher
	rm bin/{apm{,.cmd},npm{,.cmd}} || die
	rm src/cli.coffee || die
	cp "${FILESDIR}"/apm.js bin/apm || die
	chmod +x bin/apm || die

	sed -i \
		-e "s|{{ATOM_PATH}}|${EPREFIX}/usr/libexec/atom|" \
		-e "s|{{ELECTRON_PATH}}|${EPREFIX}/opt/electron-${ELECTRON_SLOT}|" \
		bin/apm || die

	# Don't download binary Node
	rm BUNDLED_NODE_VERSION script/* || die

	# Make sure python-interceptor.sh use python2.*
	sed -i "s|exec python|exec ${PYTHON}|g" bin/python-interceptor.sh || die

	default
}

src_compile() {
	npm install coffeescript || die
	npx coffee -c --no-header -o lib src/*.coffee || die
	rm -r node_modules || die
	npm install -g --prefix="${WORKDIR}"/apm-build/usr "$(npm pack | tail -1)" || die
}

src_install() {
	local install_dir
	install_dir="${EPREFIX}/usr/$(get_libdir)/node_modules/atom-package-manager"
	einstalldocs

	cp -r "${WORKDIR}"/apm-build/* "${ED}" || die

	# Remove occurrences of ${S}
	find "${ED}" -name "package.json" \
		-exec sed -e "s|${WORKDIR}/apm-build||" \
			-e "s|${S}|${install_dir}|" \
			-i '{}' \; || die

	# Remove useless stuff
	find "${ED}/usr/$(get_libdir)" \
		-name ".*" -prune -exec rm -r '{}' \; \
		-or -name "*.a" -exec rm '{}' \; \
		-or -name "*.bat" -exec rm '{}' \; \
		-or -name "*.mk" -exec rm '{}' \; \
		-or -path "*/git-utils/binding.gyp" -exec rm '{}' \; \
		-or -path "*/git-utils/src" -prune -exec rm -r '{}' \; \
		-or -path "*/keytar/binding.gyp" -exec rm '{}' \; \
		-or -path "*/keytar/src" -prune -exec rm -r '{}' \; \
		-or -path "*/oniguruma/binding.gyp" -exec rm '{}' \; \
		-or -path "*/oniguruma/src" -prune -exec rm -r '{}' \; \
		-or -name "appveyor.yml" -exec rm '{}' \; \
		-or -name "benchmark" -prune -exec rm -r '{}' \; \
		-or -name "binding.Makefile" -exec rm '{}' \; \
		-or -name "config.gypi" -exec rm '{}' \; \
		-or -name "deps" -prune -exec rm -r '{}' \; \
		-or -name "doc" -prune -exec rm -r '{}' \; \
		-or -name "html" -prune -exec rm -r '{}' \; \
		-or -name "Makefile" -exec rm '{}' \; \
		-or -name "man" -prune -exec rm -r '{}' \; \
		-or -name "obj.target" -prune -exec rm -r '{}' \; \
		-or -name "samples" -prune -exec rm -r '{}' \; \
		-or -name "scripts" -prune -exec rm -r '{}' \; \
		-or -name "test" -prune -exec rm -r '{}' \; \
		-or -name "tests" -prune -exec rm -r '{}' \; || die
}
