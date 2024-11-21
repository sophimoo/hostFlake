{ lib, config, ... }:

{

  options = {
    lf.enable = lib.mkEnableOption "enables lf";
  };

  config = lib.mkIf config.lf.enable {
    programs = {
      lf = {
        enable = true;
        settings = {
          drawbox = true;
          hidden = true;
          preview = true;
        };
        extraConfig = {
          set previewer ctpv
          set cleaner ctpvclear
          &ctpv -s $id
          &ctpvquit $id
        };
      };
      ctpv.enable = true;
    };
  };
}

