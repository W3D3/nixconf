{ inputs, ... }:
{
  flake.nixosModules.mimeapps =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.users.wedenigc =
        { ... }:
        {
          xdg.mimeApps = {
            enable = true;
            defaultApplications = {
              "text/html" = "com.google.Chrome.desktop";
              "x-scheme-handler/http" = "com.google.Chrome.desktop";
              "x-scheme-handler/https" = "com.google.Chrome.desktop";
              "x-scheme-handler/about" = "com.google.Chrome.desktop";
              "x-scheme-handler/unknown" = "com.google.Chrome.desktop";
              "x-scheme-handler/pie" = "httpie.desktop";
              "application/x-matroska" = "vlc.desktop";
              "video/3gp" = "vlc.desktop";
              "video/3gpp" = "vlc.desktop";
              "video/3gpp2" = "vlc.desktop";
              "video/avi" = "vlc.desktop";
              "video/divx" = "vlc.desktop";
              "video/dv" = "vlc.desktop";
              "video/fli" = "vlc.desktop";
              "video/flv" = "vlc.desktop";
              "video/mp2t" = "vlc.desktop";
              "video/mp4" = "vlc.desktop";
              "video/mp4v-es" = "vlc.desktop";
              "video/mpeg" = "vlc.desktop";
              "video/msvideo" = "vlc.desktop";
              "video/ogg" = "vlc.desktop";
              "video/quicktime" = "vlc.desktop";
              "video/vnd.divx" = "vlc.desktop";
              "video/vnd.mpegurl" = "vlc.desktop";
              "video/vnd.rn-realvideo" = "vlc.desktop";
              "video/webm" = "vlc.desktop";
              "video/x-avi" = "vlc.desktop";
              "video/x-flv" = "vlc.desktop";
              "video/x-m4v" = "vlc.desktop";
              "video/x-matroska" = "vlc.desktop";
              "video/x-mpeg2" = "vlc.desktop";
              "video/x-ms-asf" = "vlc.desktop";
              "video/x-ms-wmv" = "vlc.desktop";
              "video/x-ms-wmx" = "vlc.desktop";
              "video/x-msvideo" = "vlc.desktop";
              "video/x-ogm" = "vlc.desktop";
              "video/x-ogm+ogg" = "vlc.desktop";
              "video/x-theora" = "vlc.desktop";
              "video/x-theora+ogg" = "vlc.desktop";
            };
            associations.added = {
              "x-scheme-handler/pie" = "httpie.desktop";
              "application/x-matroska" = "vlc.desktop";
              "video/3gp" = "vlc.desktop";
              "video/3gpp" = "vlc.desktop";
              "video/3gpp2" = "vlc.desktop";
              "video/avi" = "vlc.desktop";
              "video/divx" = "vlc.desktop";
              "video/dv" = "vlc.desktop";
              "video/fli" = "vlc.desktop";
              "video/flv" = "vlc.desktop";
              "video/mp2t" = "vlc.desktop";
              "video/mp4" = "vlc.desktop";
              "video/mp4v-es" = "vlc.desktop";
              "video/mpeg" = "vlc.desktop";
              "video/msvideo" = "vlc.desktop";
              "video/ogg" = "vlc.desktop";
              "video/quicktime" = "vlc.desktop";
              "video/vnd.divx" = "vlc.desktop";
              "video/vnd.mpegurl" = "vlc.desktop";
              "video/vnd.rn-realvideo" = "vlc.desktop";
              "video/webm" = "vlc.desktop";
              "video/x-avi" = "vlc.desktop";
              "video/x-flv" = "vlc.desktop";
              "video/x-m4v" = "vlc.desktop";
              "video/x-matroska" = "vlc.desktop";
              "video/x-mpeg2" = "vlc.desktop";
              "video/x-ms-asf" = "vlc.desktop";
              "video/x-ms-wmv" = "vlc.desktop";
              "video/x-ms-wmx" = "vlc.desktop";
              "video/x-msvideo" = "vlc.desktop";
              "video/x-ogm" = "vlc.desktop";
              "video/x-ogm+ogg" = "vlc.desktop";
              "video/x-theora" = "vlc.desktop";
              "video/x-theora+ogg" = "vlc.desktop";
            };
          };
        };
    };
}
