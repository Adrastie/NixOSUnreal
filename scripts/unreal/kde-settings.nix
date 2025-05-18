   { pkgs, lib, utils }:

   pkgs.writeScriptBin "kde-wayland-settings" ''
     #!${pkgs.stdenv.shell}
     ${lib.banners.colorTheWorld}
     clear
     print_banner "KDE Wayland Settings for Unreal Engine"
     echo
     print_base "For keyboard input to work properly in Unreal Engine popup windows,"
     print_base "you need to change a specific KDE setting:"
     echo
     print_base "1. Open System Settings"
     print_base "2. Navigate to Security"
     print_base "3. Find 'Legacy X11 App Support'"
     echo
     print_info "Explanation:"
     print_base "- In Wayland, applications don't normally have access to all keystrokes for security reasons"
     print_base "- Unreal Engine uses X11, which needs this legacy access for popup dialogs to work"
     echo
     print_info "Security Note:"
     print_error "- This setting allows X11 applications to read all keyboard input"
     print_warning "- Only enable this if you trust all running X11 applications"
     print_warning "- Consider disabling this setting when not using Unreal Engine"
     echo
     print_info "More Information:"
     print_base "- Wayland provides better security by isolating applications input"
     print_base "- This issue occurs specifically with the Blueprint Editor in Unreal Engine"
     print_base "- No workaround seem currently available that maintains Wayland's security model"
     echo
     print_warning "Press any key to continue..."
     read -n 1 -s
     refresh-env
   ''