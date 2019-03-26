pragma Singleton

import QtQuick 2.12

Item {
    id: fonts

// This conflicts with fontAwesomeSolid because they use the same font family name
//    readonly property FontLoader fontAwesomeRegular: FontLoader {
//        source: "qrc:///FontAwesome/FontAwesome-5-Free-Regular-400.otf"
//    }
    readonly property FontLoader fontAwesomeSolid: FontLoader {
        source: "qrc:///FontAwesome/FontAwesome-5-Free-Solid-900.otf"
    }
    readonly property FontLoader fontAwesomeBrands: FontLoader {
        source: "qrc:///FontAwesome/FontAwesome-5-Brands-Regular-400.otf"
    }

//    readonly property string regular: fonts.fontAwesomeRegular.name
    readonly property string solid: fonts.fontAwesomeSolid.name
    readonly property string brands: fonts.fontAwesomeBrands.name
}
