# factorio-mod-fake-new-rails
A mod for the game Factorio. Adds simple non-rail entities shaped like the upcoming Space Age / Factorio 2.0 rails, for players eager to tinker with the shapes of the new rails.

# Instructions
While the entities don't have names and are split into pairs to accommodate 2/4/8 directional rotation, it is strongly recommended to import and use some part of the [blueprint book](blueprint_book). It contains each rotation of each entity, arranged into sub-books and in an order that should feel similar to rotating a single entity. A recommended hotbar configuration of sub-books is as follows:

1. Low / Straight
2. Low / Curve
3. High / Straight
4. High / Curve
5. Ramp
6. Support

# Contributing
PRs are welcome! There is plenty of room for improvement, including but not limited to...

* entity definition logic
* icon and entity artwork
* entity names in locale files
* custom `r`/`R`/`f`/etc hotkey handlers to implement appropriate rotation and mirroring

If you modify [fake-new-rails.svg](graphics/entity/fake-new-rails.svg), you will need to run [export-sprites.sh](graphics/entity/export-sprites.sh) to re-generate all the separate sprite layers. This script requires [Inkscape](https://inkscape.org/) for rendering the layer images, and [ImageMagick convert](https://imagemagick.org/script/convert.php) for rotation and mirroring.