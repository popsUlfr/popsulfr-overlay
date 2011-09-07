# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/tesseract/tesseract-2.04-r1.ebuild,v 1.6 2010/04/16 18:53:16 hwoarang Exp $

EAPI="3"

inherit eutils

DESCRIPTION="An OCR Engine that was developed at HP and now at Google"
HOMEPAGE="http://code.google.com/p/tesseract-ocr/"
URI_PREFIX="http://tesseract-ocr.googlecode.com/files"
SRC_URI="${URI_PREFIX}/${P}.tar.gz
	${URI_PREFIX}/eng.traineddata.gz
	linguas_bg? ( ${URI_PREFIX}/bul.traineddata.gz )
	linguas_ca? ( ${URI_PREFIX}/cat.traineddata.gz )
	linguas_cs? ( ${URI_PREFIX}/ces.traineddata.gz )
	linguas_da? ( ${URI_PREFIX}/dan.traineddata.gz )
	linguas_de? ( ${URI_PREFIX}/deu.traineddata.gz )
	linguas_el? ( ${URI_PREFIX}/ell.traineddata.gz )
	linguas_es? ( ${URI_PREFIX}/spa.traineddata.gz )
	linguas_fi? ( ${URI_PREFIX}/fin.traineddata.gz )
	linguas_fr? ( ${URI_PREFIX}/fra.traineddata.gz )
	linguas_id? ( ${URI_PREFIX}/ind.traineddata.gz )
	linguas_it? ( ${URI_PREFIX}/ita.traineddata.gz )
	linguas_hu? ( ${URI_PREFIX}/hun.traineddata.gz )
	linguas_ja? ( ${URI_PREFIX}/jpn.traineddata.gz )
	linguas_ko? ( ${URI_PREFIX}/kor.traineddata.gz )
	linguas_lt? ( ${URI_PREFIX}/lit.traineddata.gz )
	linguas_lv? ( ${URI_PREFIX}/lav.traineddata.gz )
	linguas_nl? ( ${URI_PREFIX}/nld.traineddata.gz )
	linguas_nb? ( ${URI_PREFIX}/nor.traineddata.gz )
	linguas_pl? ( ${URI_PREFIX}/pol.traineddata.gz )
	linguas_pt? ( ${URI_PREFIX}/por.traineddata.gz )
	linguas_ro? ( ${URI_PREFIX}/ron.traineddata.gz )
	linguas_ru? ( ${URI_PREFIX}/rus.traineddata.gz )
	linguas_sl? ( ${URI_PREFIX}/slv.traineddata.gz )
	linguas_sk? ( ${URI_PREFIX}/slk.traineddata.gz )
	linguas_sr? ( ${URI_PREFIX}/srp.traineddata.gz )
	linguas_sv? ( ${URI_PREFIX}/swe.traineddata.gz )
	linguas_tl? ( ${URI_PREFIX}/tgl.traineddata.gz )
	linguas_tr? ( ${URI_PREFIX}/tur.traineddata.gz )
	linguas_uk? ( ${URI_PREFIX}/ukr.traineddata.gz )
	linguas_vi? ( ${URI_PREFIX}/vie.traineddata.gz )
	linguas_zh_CN? ( ${URI_PREFIX}/chi_sim.traineddata.gz )
	linguas_zh_TW? ( ${URI_PREFIX}/chi_tra.traineddata.gz )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="examples tiff linguas_bg linguas_ca linguas_cs linguas_da linguas_de
linguas_el linguas_es linguas_fi linguas_fr linguas_id linguas_it linguas_hu
linguas_ja linguas_ko linguas_lt linguas_lv linguas_nl linguas_nb linguas_pl
linguas_pt linguas_ro linguas_ru linguas_sl linguas_sk linguas_sr linguas_sv
linguas_tl linguas_tr linguas_uk linguas_vi linguas_zh_CN linguas_zh_TW"

RDEPEND="sys-libs/zlib
	media-libs/libpng
	virtual/jpeg
	tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}
	sys-devel/gettext"

# NOTES:
# english language files are always installed because they are used by default
#   that is a tesseract bug and if possible this workaround should be avoided
#   see bug 287373
# deu-f corresponds to an old german graphic style named fraktur
#   that's the same language (german, de)
# stuff in directory java/ seems useless...
# in testing/, there is a way to test accuracy, not usable for src_test()
# app-ocr/ would be a better category

src_prepare() {
	# remove obsolete makefile, install target only in uppercase Makefile
	rm "${S}/java/makefile" || die "remove obsolete java makefile failed"
}

src_configure() {
	econf $(use_with tiff libtiff) \
		--enable-gettext \
		--enable-graphics \
		--disable-dependency-tracking
}

src_install() {
	emake DESTDIR="${ED}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README ReleaseNotes || die "dodoc failed"

	# Copy training data
	mv "${WORKDIR}"/*.traineddata "${ED}"/usr/share/tessdata || die "moving training data failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins eurotext.tif phototest.tif || die "doins failed"
	fi
}
