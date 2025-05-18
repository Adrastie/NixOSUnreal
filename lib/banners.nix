{ pkgs, colors }:

{
   # Colors are pretty
   colorTheWorld = ''
     RED="${colors.RED}"
     BRED="${colors.BRED}"
     YELLOW="${colors.YELLOW}"
     GREEN="${colors.GREEN}"
     LGREEN="${colors.LGREEN}"
     BYELLOW="${colors.YELLOW}"
     LBLUE="${colors.LBLUE}"
     DARKGREY="${colors.DARKGREY}"
     BGREY="${colors.BGREY}"
     WHITE="${colors.WHITE}"
     NC="${colors.NC}"

     # Function layout
     colorize1() {
       local text1="$2"
       local color1="$1"
       echo -e "''${!color1}$text1''${NC}"
     }

     colorize2() {
       local text1="$3"
       local text2="$4"
       local color1="$1"
       local color2="$2"
       echo -e "''${!color1}$text1''${NC} ''${!color2}$text2''${NC}"
     }

     colorize3() {
       local text1="$4"
       local text2="$5"
       local text3="$6"
       local color1="$1"
       local color2="$2"
       local color3="$3"
       echo -e "''${!color1}$text1''${NC} ''${!color2}$text2''${NC} ''${!color3}$text3''${NC}"
     }

     # Header layout
     print_header() {
       echo -e "''${YELLOW}===== $1 =====''${NC}"
     }

     # Banner layout
     print_banner() {
       echo -e "''${BGREY}════════════════════════ ''${BRED}♥♥♥''${NC}''${YELLOW} $1 ''${NC}''${BRED}♥♥♥''${NC} ''${BGREY}════════════════════════''${NC}"
     }

     # Banner layout
     print_core() {
       echo -e "''${BRED}♥♥♥''${NC} $1 ''${NC}''${BRED}♥♥♥''${NC}"
     }



     # Info layout
     print_info() {
       echo -e "''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}!''${NC}''${YELLOW}''${BRED}!''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}♥''${NC}''${YELLOW} $1 ''${NC}''${BRED}♥''${NC}''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}!''${BYELLOW}!''${BRED}!''${NC}''${YELLOW}''${NC}"
     }

     # Success layout
     print_success() {
       echo -e "''${GREEN}$1''${NC}"
     }

     # Error layout
     print_error() {
       echo -e "''${RED}$1''${NC}"
     }

     # Warning layout
     print_warning() {
       echo -e "''${BYELLOW}$1''${NC}"
     }

     # Warning layout
     print_base() {
       echo -e "''${NC}$1''${NC}"
     }
   '';
}

