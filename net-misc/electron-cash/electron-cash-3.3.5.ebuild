# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6} )
PYTHON_REQ_USE="ncurses?"

inherit distutils-r1 xdg-utils

DESCRIPTION="Lightweight Bitcoin Cash client"
HOMEPAGE="https://electroncash.org"
SRC_URI="https://github.com/fyookball/electrum/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="audio_modem cli cosign digitalbitbox email ncurses qrcode sync vkb l10n_es l10n_ja l10n_pt l10n_zh-CN"
REQUIRED_USE="|| ( cli ncurses )"

RDEPEND="
	dev-python/ecdsa[${PYTHON_USEDEP}]
	>=dev-python/jsonrpclib-0.3.1[${PYTHON_USEDEP}]
	dev-python/pbkdf2[${PYTHON_USEDEP}]
	dev-python/pyaes[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	dev-python/qrcode[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/tlslite[${PYTHON_USEDEP}]
	|| (
		dev-python/protobuf-python[${PYTHON_USEDEP}]
		dev-libs/protobuf[python,${PYTHON_USEDEP}]
	)
	virtual/python-dnspython[${PYTHON_USEDEP}]
	qrcode? ( media-gfx/zbar[v4l] )
	audio_modem? ( dev-python/amodem[${PYTHON_USEDEP}] )
	dev-python/PyQt5[gui,widgets,${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

DOCS=( AUTHORS README.rst RELEASE-NOTES )

S="${WORKDIR}/Electron-Cash-${PV}"

src_prepare() {
	eapply "${FILESDIR}/${PN}-3.3-no_user_root.patch"

	local wordlist=
	for wordlist in \
		$(usex l10n_ja '' japanese) \
		$(usex l10n_pt '' portuguese) \
		$(usex l10n_es '' spanish) \
		$(usex l10n_zh-CN '' chinese_simplified) \
	; do
		rm -f "lib/wordlist/${wordlist}.txt" || die
		sed -i "/${wordlist}\\.txt/d" lib/mnemonic.py || die
	done

	# Remove unrequested GUI implementations:
	local gui setup_py_gui
	for gui in \
		$(usex cli '' stdio) \
		kivy \
		$(usex ncurses '' text ) \
	; do
		rm gui/"${gui}"* -r || die
	done

	local plugin
	# trezor requires python trezorlib module
	# keepkey requires trezor
	for plugin in \
		$(usex audio_modem '' audio_modem ) \
		$(usex cosign '' cosigner_pool ) \
		$(usex digitalbitbox '' digitalbitbox ) \
		$(usex email '' email_requests ) \
		hw_wallet \
		ledger \
		keepkey \
		$(usex sync '' labels ) \
		trezor \
		$(usex vkb '' virtualkeyboard ) \
	; do
		rm -r plugins/"${plugin}"* || die
		sed -i "/${plugin}/d" setup.py || die
	done

	distutils-r1_src_prepare
}

src_compile() {
	pyrcc5 icons.qrc -o gui/qt/icons_rc.py || die

	# Compile the protobuf description file:
	protoc --proto_path=lib/ --python_out=lib/ lib/paymentrequest.proto || die

	distutils-r1_src_compile
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $? || die
	fi
	xdg_desktop_database_update
}

pkg_postrm() {
	update_caches
}

pkg_postinst() {
	update_caches
}
