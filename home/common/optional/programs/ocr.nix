{
  lib,
  config,
  pkgs,
  ...
}:
{
  xdg.desktopEntries.ocr = {
    name = "OCR tesseract";
    exec = "${pkgs.writeScript "ocr" ''
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.tesseract}/bin/tesseract - - | wl-copy
    ''}";
  };
}
