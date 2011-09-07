# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit versionator toolchain-funcs eutils autotools

DESCRIPTION="Light-weight 'standard library' of C functions."
HOMEPAGE="https://launchpad.net/libnih"
SRC_URI="http://launchpad.net/${PN}/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="dbus static-libs test +threads"

RDEPEND="dbus? ( dev-libs/expat
	>=sys-apps/dbus-1.2.16 )"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig
	test? ( dev-util/valgrind )"

src_prepare() {
	epatch "${FILESDIR}/optional-dbus.patch"
	eautoreconf
}

src_configure() {
	econf \
		$(use_with dbus) \
		$(use_enable static-libs static) \
		$(use_enable threads) \
		$(use_enable threads threading)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	gen_usr_ldscript -a nih
	use static-libs || rm "${D}"/usr/lib*/*.la

	dodoc AUTHORS ChangeLog HACKING NEWS README TODO
}
